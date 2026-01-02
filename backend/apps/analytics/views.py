"""
Views for analytics app.
"""
from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from apps.analytics.services import SimpleAnalyticsService
from apps.ml_integration.translator import HybridTranslator


class AnalyticsViewSet(viewsets.ViewSet):
    """ViewSet for analytics."""
    permission_classes = [IsAuthenticated]
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.service = SimpleAnalyticsService()
    
    @action(detail=False, methods=['get'], url_path='stats')
    def stats(self, request):
        """Get user statistics."""
        stats = self.service.get_user_statistics(request.user)
        return Response(stats)
    
    @action(detail=False, methods=['get'], url_path='activity')
    def activity(self, request):
        """Get activity chart data."""
        days = int(request.query_params.get('days', 7))
        chart_data = self.service.get_activity_chart(request.user, days=days)
        return Response({'days': days, 'data': chart_data})
    
    @action(detail=False, methods=['get'], url_path='popular')
    def popular(self, request):
        """Get user's most used cards."""
        limit = int(request.query_params.get('limit', 10))
        popular = self.service.get_popular_cards(request.user, limit=limit)
        return Response(popular)
    
    @action(detail=False, methods=['get'], url_path='categories')
    def categories(self, request):
        """Get usage breakdown by category."""
        breakdown = self.service.get_category_breakdown(request.user)
        return Response(breakdown)
    
    @action(detail=False, methods=['get'], url_path='recommendations')
    def recommendations(self, request):
        """Get card recommendations."""
        limit = int(request.query_params.get('limit', 10))
        recommendations = self.service.get_recommendations(request.user, limit=limit)
        return Response(recommendations)


class TranslatorStatsViewSet(viewsets.ViewSet):
    """ViewSet for translation system statistics."""
    permission_classes = [IsAuthenticated]
    
    def translator_stats(self, request):
        """Get translation system statistics."""
        translator = HybridTranslator()
        stats = translator.get_translation_stats()
        return Response(stats)

