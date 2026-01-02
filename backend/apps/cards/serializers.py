"""
Serializers for cards app.
"""
from rest_framework import serializers
from django.contrib.auth.models import User

from apps.cards.models import Card, Category, UserCard, CardUsageLog
from apps.users.models import UserProfile


class CategorySerializer(serializers.ModelSerializer):
    """Serializer for Category model."""
    
    class Meta:
        model = Category
        fields = ['category_id', 'name_ru', 'name_kk', 'name_en', 'icon', 'order']
    
    def to_representation(self, instance):
        """Return localized category name based on user language."""
        data = super().to_representation(instance)
        
        # Get user language from request context
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                language = request.user.profile.language
                data['name'] = instance.get_name(language)
            except UserProfile.DoesNotExist:
                data['name'] = instance.name_en
        else:
            data['name'] = instance.name_en
        
        return data


class CardSerializer(serializers.ModelSerializer):
    """Serializer for Card model."""
    category = CategorySerializer(read_only=True)
    category_id = serializers.UUIDField(write_only=True, required=False, allow_null=True)
    word = serializers.SerializerMethodField()
    is_favorite = serializers.SerializerMethodField()
    
    class Meta:
        model = Card
        fields = [
            'card_id', 'word_ru', 'word_kk', 'word_en', 'word',
            'category', 'category_id',
            'image_url', 'thumbnail_url',
            'is_custom', 'is_approved',
            'generation_status',
            'usage_count', 'like_count',
            'is_favorite',
            'created_at', 'updated_at', 'generated_at',
        ]
        read_only_fields = [
            'card_id', 'image_url', 'thumbnail_url',
            'generation_status', 'usage_count', 'like_count',
            'created_at', 'updated_at', 'generated_at',
        ]
    
    def get_word(self, obj):
        """Get word in user's language."""
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                language = request.user.profile.language
                return obj.get_word(language)
            except UserProfile.DoesNotExist:
                return obj.word_en
        return obj.word_en
    
    def get_is_favorite(self, obj):
        """Check if card is user's favorite."""
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                user_card = UserCard.objects.get(user=request.user, card=obj)
                return user_card.is_favorite
            except UserCard.DoesNotExist:
                return False
        return False


class CardGenerateSerializer(serializers.Serializer):
    """Serializer for card generation request."""
    word = serializers.CharField(max_length=200, required=True)
    category_id = serializers.UUIDField(required=False, allow_null=True)
    source_lang = serializers.ChoiceField(
        choices=['ru', 'kk'],
        default='ru',
        required=False
    )


class CardUsageSerializer(serializers.ModelSerializer):
    """Serializer for card usage log."""
    card = CardSerializer(read_only=True)
    
    class Meta:
        model = CardUsageLog
        fields = ['card', 'used_at', 'language']


class PopularCardSerializer(serializers.ModelSerializer):
    """Serializer for popular cards."""
    word = serializers.SerializerMethodField()
    category = CategorySerializer(read_only=True)
    
    class Meta:
        model = Card
        fields = [
            'card_id', 'word', 'word_ru', 'word_kk', 'word_en',
            'category', 'image_url', 'thumbnail_url',
            'usage_count', 'like_count',
        ]
    
    def get_word(self, obj):
        """Get word in user's language."""
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                language = request.user.profile.language
                return obj.get_word(language)
            except UserProfile.DoesNotExist:
                return obj.word_en
        return obj.word_en

