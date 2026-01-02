"""
Views for cards app.
"""
import logging
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q, Count
from django.shortcuts import get_object_or_404

from apps.cards.models import Card, Category
from apps.cards.serializers import (
    CardSerializer,
    CategorySerializer,
    CardGenerateSerializer,
    PopularCardSerializer,
)
from apps.cards.services import CardService

logger = logging.getLogger(__name__)


class CategoryViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for categories."""
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Return categories ordered by display order."""
        return Category.objects.all().order_by('order', 'name_en')


class CardViewSet(viewsets.ModelViewSet):
    """ViewSet for cards."""
    queryset = Card.objects.filter(is_approved=True)
    serializer_class = CardSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = 'card_id'
    
    def get_queryset(self):
        """Filter cards based on query parameters."""
        queryset = Card.objects.filter(is_approved=True)
        
        # Filter by category
        category_id = self.request.query_params.get('category')
        if category_id:
            queryset = queryset.filter(category__category_id=category_id)
        
        # Search in all languages
        search = self.request.query_params.get('search')
        if search:
            queryset = queryset.filter(
                Q(word_ru__icontains=search) |
                Q(word_kk__icontains=search) |
                Q(word_en__icontains=search)
            )
        
        # Filter by generation status
        status_filter = self.request.query_params.get('status')
        if status_filter:
            queryset = queryset.filter(generation_status=status_filter)
        
        return queryset.order_by('-created_at')
    
    @action(detail=False, methods=['post'], url_path='generate')
    def generate(self, request):
        """Generate a new card with automatic translation."""
        serializer = CardGenerateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        service = CardService()
        card = service.create_card_with_translation(
            user=request.user,
            word=serializer.validated_data['word'],
            category_id=str(serializer.validated_data.get('category_id')) if serializer.validated_data.get('category_id') else None,
            source_lang=serializer.validated_data.get('source_lang', 'ru')
        )
        
        card_serializer = CardSerializer(card, context={'request': request})
        return Response(card_serializer.data, status=status.HTTP_201_CREATED)
    
    @action(detail=True, methods=['post'], url_path='use')
    def use_card(self, request, card_id=None):
        """Track card usage."""
        card = self.get_object()
        service = CardService()
        
        language = request.data.get('language')
        service.track_card_usage(request.user, card, language)
        
        card_serializer = CardSerializer(card, context={'request': request})
        return Response(card_serializer.data)
    
    @action(detail=True, methods=['post'], url_path='toggle-favorite')
    def toggle_favorite(self, request, card_id=None):
        """Toggle favorite status."""
        card = self.get_object()
        service = CardService()
        
        is_favorite = service.toggle_favorite(request.user, card)
        
        return Response({'is_favorite': is_favorite})
    
    @action(detail=False, methods=['get'], url_path='popular')
    def popular(self, request):
        """Get popular cards."""
        queryset = Card.objects.filter(
            is_approved=True,
            generation_status=Card.GenerationStatus.COMPLETED
        ).order_by('-usage_count')[:20]
        
        serializer = PopularCardSerializer(queryset, many=True, context={'request': request})
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'], url_path='favorites')
    def favorites(self, request):
        """Get user's favorite cards."""
        from apps.cards.models import UserCard
        
        favorite_cards = Card.objects.filter(
            user_cards__user=request.user,
            user_cards__is_favorite=True,
            is_approved=True
        ).order_by('-user_cards__updated_at')
        
        serializer = CardSerializer(favorite_cards, many=True, context={'request': request})
        return Response(serializer.data)

