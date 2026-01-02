"""
ML Service client for image generation.
"""
import logging
import requests
from typing import Optional, Dict
from django.conf import settings

logger = logging.getLogger(__name__)


class MLServiceClient:
    """Client for communicating with ML microservice."""
    
    def __init__(self):
        self.base_url = getattr(settings, 'ML_SERVICE_URL', 'http://localhost:8001')
        self.timeout = getattr(settings, 'ML_SERVICE_TIMEOUT', 300)
    
    def generate_image(
        self,
        word_en: str,
        prompt_override: Optional[str] = None,
        **kwargs
    ) -> Dict[str, str]:
        """
        Request image generation from ML service.
        
        Args:
            word_en: English word to generate image for
            prompt_override: Optional custom prompt
            **kwargs: Additional generation parameters
        
        Returns:
            Dict with 'image_url' and 'thumbnail_url'
        
        Raises:
            requests.RequestException: If request fails
        """
        url = f"{self.base_url}/generate"
        
        prompt = prompt_override or self._build_prompt(word_en)
        
        payload = {
            'word': word_en,
            'prompt': prompt,
            'model': 'stable-diffusion-v1-5',
            **kwargs
        }
        
        try:
            logger.info(f"Requesting image generation for: {word_en}")
            response = requests.post(url, json=payload, timeout=self.timeout)
            response.raise_for_status()
            
            data = response.json()
            return {
                'image_url': data.get('image_url'),
                'thumbnail_url': data.get('thumbnail_url', data.get('image_url')),
                'generation_params': data.get('generation_params', {}),
            }
        except requests.exceptions.RequestException as e:
            logger.error(f"ML service request failed: {e}")
            raise
    
    def _build_prompt(self, word_en: str) -> str:
        """Build prompt for Stable Diffusion."""
        return f"{word_en}, simple icon, flat design, minimalist, white background, high contrast, centered, clean illustration"
    
    def health_check(self) -> bool:
        """Check if ML service is healthy."""
        try:
            url = f"{self.base_url}/health"
            response = requests.get(url, timeout=5)
            return response.status_code == 200
        except Exception as e:
            logger.error(f"ML service health check failed: {e}")
            return False

