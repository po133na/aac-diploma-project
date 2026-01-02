"""
ML Integration models for translation dictionary.
"""
from django.db import models
import uuid


class Translation(models.Model):
    """Translation dictionary for verified translations."""
    translation_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    word_ru = models.CharField(max_length=200, db_index=True)
    word_kk = models.CharField(max_length=200, db_index=True)
    word_en = models.CharField(max_length=200, db_index=True)
    category = models.CharField(max_length=50, blank=True, help_text='Category hint')
    is_verified = models.BooleanField(default=False, help_text='Verified by moderator')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Translation'
        verbose_name_plural = 'Translations'
        unique_together = [['word_ru', 'word_kk', 'word_en']]
        indexes = [
            models.Index(fields=['word_ru']),
            models.Index(fields=['word_kk']),
            models.Index(fields=['word_en']),
        ]

    def __str__(self):
        return f"{self.word_ru} / {self.word_kk} / {self.word_en}"

