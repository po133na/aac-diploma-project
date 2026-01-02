"""
Card models for AAC Communication Cards.
"""
import uuid
from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone


class Category(models.Model):
    """Category model with multilingual support."""
    category_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name_ru = models.CharField(max_length=100, verbose_name='Название (RU)')
    name_kk = models.CharField(max_length=100, verbose_name='Название (KK)')
    name_en = models.CharField(max_length=100, verbose_name='Название (EN)')
    icon = models.CharField(max_length=50, blank=True, help_text='Icon identifier')
    order = models.IntegerField(default=0, help_text='Display order')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Category'
        verbose_name_plural = 'Categories'
        ordering = ['order', 'name_en']

    def __str__(self):
        return f"{self.name_en} ({self.name_ru}/{self.name_kk})"

    def get_name(self, language: str = 'en') -> str:
        """Get category name in specified language."""
        lang_map = {'ru': 'name_ru', 'kk': 'name_kk', 'en': 'name_en'}
        return getattr(self, lang_map.get(language, 'name_en'))


class Card(models.Model):
    """Card model with multilingual word support."""
    
    class GenerationStatus(models.TextChoices):
        PENDING = 'pending', 'Pending'
        PROCESSING = 'processing', 'Processing'
        COMPLETED = 'completed', 'Completed'
        FAILED = 'failed', 'Failed'

    card_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Multilingual words
    word_ru = models.CharField(max_length=200, verbose_name='Слово (RU)')
    word_kk = models.CharField(max_length=200, verbose_name='Сөз (KK)')
    word_en = models.CharField(max_length=200, verbose_name='Word (EN)')
    
    # Category
    category = models.ForeignKey(
        Category,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='cards'
    )
    
    # Images
    image_url = models.URLField(max_length=500, blank=True, null=True)
    thumbnail_url = models.URLField(max_length=500, blank=True, null=True)
    
    # Flags
    is_custom = models.BooleanField(default=False, help_text='User-generated card')
    is_approved = models.BooleanField(default=True, help_text='Approved for public use')
    
    # Generation tracking
    generation_status = models.CharField(
        max_length=20,
        choices=GenerationStatus.choices,
        default=GenerationStatus.PENDING
    )
    generation_prompt = models.TextField(blank=True, help_text='Prompt used for generation')
    generation_model = models.CharField(max_length=100, blank=True, default='stable-diffusion-v1-5')
    generation_params = models.JSONField(default=dict, blank=True)
    generation_error = models.TextField(blank=True, help_text='Error message if generation failed')
    
    # Statistics
    usage_count = models.IntegerField(default=0)
    like_count = models.IntegerField(default=0)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    generated_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        verbose_name = 'Card'
        verbose_name_plural = 'Cards'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['category', 'is_approved']),
            models.Index(fields=['word_ru']),
            models.Index(fields=['word_kk']),
            models.Index(fields=['word_en']),
            models.Index(fields=['generation_status']),
        ]

    def __str__(self):
        return f"{self.word_en} ({self.word_ru}/{self.word_kk})"

    def get_word(self, language: str = 'en') -> str:
        """Get word in specified language."""
        lang_map = {'ru': 'word_ru', 'kk': 'word_kk', 'en': 'word_en'}
        return getattr(self, lang_map.get(language, 'word_en'))

    def mark_generated(self, image_url: str, thumbnail_url: str = None):
        """Mark card as generated with image URLs."""
        self.generation_status = self.GenerationStatus.COMPLETED
        self.image_url = image_url
        self.thumbnail_url = thumbnail_url or image_url
        self.generated_at = timezone.now()
        self.save(update_fields=['generation_status', 'image_url', 'thumbnail_url', 'generated_at'])

    def mark_failed(self, error: str):
        """Mark card generation as failed."""
        self.generation_status = self.GenerationStatus.FAILED
        self.generation_error = error
        self.save(update_fields=['generation_status', 'generation_error'])


class UserCard(models.Model):
    """User-specific card data (favorites, custom cards)."""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='user_cards')
    card = models.ForeignKey(Card, on_delete=models.CASCADE, related_name='user_cards')
    is_favorite = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ['user', 'card']
        verbose_name = 'User Card'
        verbose_name_plural = 'User Cards'
        indexes = [
            models.Index(fields=['user', 'is_favorite']),
        ]

    def __str__(self):
        return f"{self.user.username} - {self.card.word_en}"


class CardUsageLog(models.Model):
    """Log of card usage for analytics."""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='usage_logs')
    card = models.ForeignKey(Card, on_delete=models.CASCADE, related_name='usage_logs')
    used_at = models.DateTimeField(auto_now_add=True)
    language = models.CharField(max_length=2, default='ru', help_text='Language used (ru/kk)')

    class Meta:
        verbose_name = 'Card Usage Log'
        verbose_name_plural = 'Card Usage Logs'
        ordering = ['-used_at']
        indexes = [
            models.Index(fields=['user', 'used_at']),
            models.Index(fields=['card', 'used_at']),
            models.Index(fields=['used_at']),
        ]

    def __str__(self):
        return f"{self.user.username} used {self.card.word_en} at {self.used_at}"

