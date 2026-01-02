"""
User profile models for AAC Communication Cards.
"""
from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver


class UserProfile(models.Model):
    """Extended user profile with language preferences."""
    
    class Language(models.TextChoices):
        RUSSIAN = 'ru', 'Russian (Русский)'
        KAZAKH = 'kk', 'Kazakh (Қазақша)'
        ENGLISH = 'en', 'English'

    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='profile',
        primary_key=True
    )
    language = models.CharField(
        max_length=2,
        choices=Language.choices,
        default=Language.RUSSIAN,
        help_text='Preferred language for card display'
    )
    timezone = models.CharField(max_length=50, default='UTC')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'User Profile'
        verbose_name_plural = 'User Profiles'

    def __str__(self):
        return f"{self.user.username} ({self.get_language_display()})"


@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    """Create user profile when user is created."""
    if created:
        UserProfile.objects.create(user=instance)

