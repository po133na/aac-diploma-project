"""
Admin configuration for cards app.
"""
from django.contrib import admin
from apps.cards.models import Card, Category, UserCard, CardUsageLog


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ['name_en', 'name_ru', 'name_kk', 'order', 'created_at']
    list_filter = ['created_at']
    search_fields = ['name_en', 'name_ru', 'name_kk']
    ordering = ['order', 'name_en']


@admin.register(Card)
class CardAdmin(admin.ModelAdmin):
    list_display = ['word_en', 'word_ru', 'word_kk', 'category', 'generation_status', 'usage_count', 'created_at']
    list_filter = ['generation_status', 'is_custom', 'is_approved', 'category', 'created_at']
    search_fields = ['word_en', 'word_ru', 'word_kk']
    readonly_fields = ['card_id', 'created_at', 'updated_at', 'generated_at']
    ordering = ['-created_at']


@admin.register(UserCard)
class UserCardAdmin(admin.ModelAdmin):
    list_display = ['user', 'card', 'is_favorite', 'created_at']
    list_filter = ['is_favorite', 'created_at']
    search_fields = ['user__username', 'card__word_en']


@admin.register(CardUsageLog)
class CardUsageLogAdmin(admin.ModelAdmin):
    list_display = ['user', 'card', 'language', 'used_at']
    list_filter = ['language', 'used_at']
    search_fields = ['user__username', 'card__word_en']
    readonly_fields = ['used_at']
    ordering = ['-used_at']

