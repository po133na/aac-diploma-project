"""
Admin configuration for ml_integration app.
"""
from django.contrib import admin
from apps.ml_integration.models import Translation


@admin.register(Translation)
class TranslationAdmin(admin.ModelAdmin):
    list_display = ['word_ru', 'word_kk', 'word_en', 'category', 'is_verified', 'created_at']
    list_filter = ['is_verified', 'category', 'created_at']
    search_fields = ['word_ru', 'word_kk', 'word_en']
    ordering = ['word_en']

