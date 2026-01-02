"""
Card service with business logic.
"""
import logging
from typing import Optional, Dict
from django.contrib.auth.models import User
from django.db import transaction

from apps.cards.models import Card, Category, UserCard, CardUsageLog
from apps.users.models import UserProfile
from apps.ml_integration.translator import HybridTranslator
from apps.ml_integration.client import MLServiceClient
from apps.cards.tasks import generate_card_image_task

logger = logging.getLogger(__name__)


class CardService:
    """Service for card business logic."""
    
    def __init__(self):
        self.translator = HybridTranslator()
        self.ml_client = MLServiceClient()
    
    def create_card_with_translation(
        self,
        user: User,
        word: str,
        category_id: Optional[str] = None,
        source_lang: str = 'ru'
    ) -> Card:
        """
        Create a card with automatic translation.
        
        Args:
            user: User creating the card
            word: Word in user's language (ru or kk)
            category_id: Optional category UUID
            source_lang: Source language ('ru' or 'kk')
        
        Returns:
            Created Card instance
        """
        # Get user's language preference
        try:
            profile = user.profile
            if not source_lang:
                source_lang = profile.language
        except UserProfile.DoesNotExist:
            source_lang = source_lang or 'ru'
        
        # Translate word to all languages
        word_ru, word_kk, word_en, category_name = self.translator.translate(
            word,
            source_lang=source_lang,
            category_hint=''
        )
        
        # Get or create category
        category = None
        if category_id:
            try:
                category = Category.objects.get(category_id=category_id)
            except Category.DoesNotExist:
                logger.warning(f"Category {category_id} not found")
        
        # Create card
        card = Card.objects.create(
            word_ru=word_ru,
            word_kk=word_kk,
            word_en=word_en,
            category=category,
            is_custom=True,
            generation_status=Card.GenerationStatus.PENDING,
        )
        
        # Trigger async image generation
        generate_card_image_task.delay(str(card.card_id))
        
        logger.info(f"Created card {card.card_id} for word: {word}")
        return card
    
    def track_card_usage(self, user: User, card: Card, language: Optional[str] = None) -> CardUsageLog:
        """Track card usage for analytics."""
        if not language:
            try:
                language = user.profile.language
            except UserProfile.DoesNotExist:
                language = 'ru'
        
        # Increment usage count
        card.usage_count += 1
        card.save(update_fields=['usage_count'])
        
        # Create usage log
        usage_log = CardUsageLog.objects.create(
            user=user,
            card=card,
            language=language
        )
        
        return usage_log
    
    def toggle_favorite(self, user: User, card: Card) -> bool:
        """Toggle favorite status for a card."""
        user_card, created = UserCard.objects.get_or_create(
            user=user,
            card=card
        )
        
        user_card.is_favorite = not user_card.is_favorite
        user_card.save(update_fields=['is_favorite'])
        
        return user_card.is_favorite
    
    def get_user_language(self, user: User) -> str:
        """Get user's preferred language."""
        try:
            return user.profile.language
        except UserProfile.DoesNotExist:
            return 'ru'
    
    def filter_cards_by_language(self, queryset, user: User):
        """Filter cards based on user's language preference (for search)."""
        # This is handled in views/serializers, but can be extended here
        return queryset

