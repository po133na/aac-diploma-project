"""
Analytics service for user statistics.
"""
import logging
from typing import Dict, List
from datetime import datetime, timedelta
from django.contrib.auth.models import User
from django.db.models import Count, Q
from django.utils import timezone

from apps.cards.models import Card, CardUsageLog, UserCard
from apps.users.models import UserProfile

logger = logging.getLogger(__name__)


class SimpleAnalyticsService:
    """Simple analytics service for user statistics."""
    
    def get_user_statistics(self, user: User) -> Dict:
        """Get comprehensive user statistics."""
        # Total usage
        total_usage = CardUsageLog.objects.filter(user=user).count()
        
        # Unique cards used
        unique_cards = CardUsageLog.objects.filter(user=user).values('card').distinct().count()
        
        # Vocabulary size (cards user has used)
        vocabulary_size = unique_cards
        
        # Favorite cards count
        favorite_count = UserCard.objects.filter(user=user, is_favorite=True).count()
        
        # Custom cards created
        custom_cards = Card.objects.filter(is_custom=True).count()  # Could filter by user if we add user field
        
        return {
            'total_usage': total_usage,
            'unique_cards': unique_cards,
            'vocabulary_size': vocabulary_size,
            'favorite_cards': favorite_count,
            'custom_cards': custom_cards,
        }
    
    def get_activity_chart(self, user: User, days: int = 7) -> List[Dict]:
        """Get daily activity chart for last N days."""
        end_date = timezone.now()
        start_date = end_date - timedelta(days=days)
        
        # Get usage logs grouped by date
        logs = CardUsageLog.objects.filter(
            user=user,
            used_at__gte=start_date,
            used_at__lte=end_date
        ).extra(
            select={'day': 'DATE(used_at)'}
        ).values('day').annotate(
            count=Count('id')
        ).order_by('day')
        
        # Create date range
        date_range = []
        current_date = start_date.date()
        end_date_only = end_date.date()
        
        while current_date <= end_date_only:
            date_range.append(current_date)
            current_date += timedelta(days=1)
        
        # Map logs to dates
        log_dict = {log['day']: log['count'] for log in logs}
        
        # Build chart data
        chart_data = [
            {
                'date': str(date),
                'count': log_dict.get(date, 0)
            }
            for date in date_range
        ]
        
        return chart_data
    
    def get_popular_cards(self, user: User, limit: int = 10) -> List[Dict]:
        """Get user's most used cards."""
        popular = CardUsageLog.objects.filter(
            user=user
        ).values(
            'card__card_id',
            'card__word_ru',
            'card__word_kk',
            'card__word_en',
            'card__image_url',
            'card__thumbnail_url',
        ).annotate(
            usage_count=Count('id')
        ).order_by('-usage_count')[:limit]
        
        # Get user language
        try:
            language = user.profile.language
        except UserProfile.DoesNotExist:
            language = 'ru'
        
        # Format results
        result = []
        for item in popular:
            word_field = f"card__word_{language}" if language in ['ru', 'kk'] else 'card__word_en'
            result.append({
                'card_id': item['card__card_id'],
                'word': item.get(word_field, item['card__word_en']),
                'word_ru': item['card__word_ru'],
                'word_kk': item['card__word_kk'],
                'word_en': item['card__word_en'],
                'image_url': item['card__image_url'],
                'thumbnail_url': item['card__thumbnail_url'],
                'usage_count': item['usage_count'],
            })
        
        return result
    
    def get_category_breakdown(self, user: User) -> List[Dict]:
        """Get usage breakdown by category."""
        breakdown = CardUsageLog.objects.filter(
            user=user
        ).values(
            'card__category__category_id',
            'card__category__name_ru',
            'card__category__name_kk',
            'card__category__name_en',
        ).annotate(
            usage_count=Count('id')
        ).order_by('-usage_count')
        
        # Get user language
        try:
            language = user.profile.language
        except UserProfile.DoesNotExist:
            language = 'ru'
        
        result = []
        for item in breakdown:
            name_field = f"card__category__name_{language}" if language in ['ru', 'kk'] else 'card__category__name_en'
            result.append({
                'category_id': item['card__category__category_id'],
                'name': item.get(name_field, item['card__category__name_en']),
                'name_ru': item['card__category__name_ru'],
                'name_kk': item['card__category__name_kk'],
                'name_en': item['card__category__name_en'],
                'usage_count': item['usage_count'],
            })
        
        return result
    
    def get_recommendations(self, user: User, limit: int = 10) -> List[Dict]:
        """Get simple recommendations (popular cards user hasn't tried)."""
        # Get cards user has used
        used_card_ids = CardUsageLog.objects.filter(
            user=user
        ).values_list('card_id', flat=True)
        
        # Get popular cards user hasn't used
        recommendations = Card.objects.filter(
            is_approved=True,
            generation_status=Card.GenerationStatus.COMPLETED
        ).exclude(
            card_id__in=used_card_ids
        ).order_by('-usage_count')[:limit]
        
        # Get user language
        try:
            language = user.profile.language
        except UserProfile.DoesNotExist:
            language = 'ru'
        
        result = []
        for card in recommendations:
            result.append({
                'card_id': str(card.card_id),
                'word': card.get_word(language),
                'word_ru': card.word_ru,
                'word_kk': card.word_kk,
                'word_en': card.word_en,
                'category': {
                    'category_id': str(card.category.category_id) if card.category else None,
                    'name': card.category.get_name(language) if card.category else None,
                } if card.category else None,
                'image_url': card.image_url,
                'thumbnail_url': card.thumbnail_url,
                'usage_count': card.usage_count,
            })
        
        return result

