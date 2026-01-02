"""
Views for users app.
"""
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth.models import User

from apps.users.models import UserProfile
from apps.users.serializers import (
    UserSerializer,
    UserProfileSerializer,
    LanguageUpdateSerializer,
)

class UserViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for users."""
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Return only current user."""
        return User.objects.filter(id=self.request.user.id)
    
    @action(detail=False, methods=['get', 'patch'])
    def me(self, request):
        """Get or update current user profile."""
        if request.method == 'GET':
            serializer = UserSerializer(request.user, context={'request': request})
            return Response(serializer.data)
        else:
            # Update profile
            profile, created = UserProfile.objects.get_or_create(user=request.user)
            serializer = UserProfileSerializer(profile, data=request.data, partial=True)
            serializer.is_valid(raise_exception=True)
            serializer.save()
            return Response(serializer.data)
    
    @action(detail=False, methods=['patch'], url_path='language')
    def update_language(self, request):
        """Update user's language preference."""
        serializer = LanguageUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        profile, created = UserProfile.objects.get_or_create(user=request.user)
        profile.language = serializer.validated_data['language']
        profile.save(update_fields=['language'])
        
        return Response({'language': profile.language})

