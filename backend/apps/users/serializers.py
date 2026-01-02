"""
Serializers for users app.
"""
from rest_framework import serializers
from django.contrib.auth.models import User

from apps.users.models import UserProfile


class UserProfileSerializer(serializers.ModelSerializer):
    """Serializer for UserProfile."""
    
    class Meta:
        model = UserProfile
        fields = ['language', 'timezone', 'created_at', 'updated_at']
        read_only_fields = ['created_at', 'updated_at']


class UserSerializer(serializers.ModelSerializer):
    """Serializer for User with profile."""
    profile = UserProfileSerializer(read_only=True)
    
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'profile']
        read_only_fields = ['id', 'username']


class LanguageUpdateSerializer(serializers.Serializer):
    """Serializer for updating user language."""
    language = serializers.ChoiceField(
        choices=UserProfile.Language.choices,
        required=True
    )

