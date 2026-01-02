"""
URLs for analytics app.
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter

from apps.analytics.views import AnalyticsViewSet, TranslatorStatsViewSet

router = DefaultRouter()
router.register(r'analytics', AnalyticsViewSet, basename='analytics')

urlpatterns = [
    path('', include(router.urls)),
    path('translator-stats/', TranslatorStatsViewSet.as_view({'get': 'translator_stats'}), name='translator-stats'),
]

