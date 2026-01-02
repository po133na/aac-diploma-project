"""
Celery tasks for cards app.
"""
import logging
from celery import shared_task
from django.conf import settings

from apps.cards.models import Card
from apps.ml_integration.client import MLServiceClient

logger = logging.getLogger(__name__)


@shared_task(bind=True, max_retries=3)
def generate_card_image_task(self, card_id: str):
    """
    Generate image for a card using ML service.
    
    Args:
        card_id: UUID of the card
    """
    try:
        card = Card.objects.get(card_id=card_id)
        
        # Update status to processing
        card.generation_status = Card.GenerationStatus.PROCESSING
        card.save(update_fields=['generation_status'])
        
        # Call ML service
        ml_client = MLServiceClient()
        result = ml_client.generate_image(
            word_en=card.word_en,
            prompt_override=card.generation_prompt if card.generation_prompt else None
        )
        
        # Update card with image URLs
        card.mark_generated(
            image_url=result['image_url'],
            thumbnail_url=result.get('thumbnail_url')
        )
        
        # Save generation parameters
        if 'generation_params' in result:
            card.generation_params = result['generation_params']
            card.save(update_fields=['generation_params'])
        
        logger.info(f"Successfully generated image for card {card_id}")
        
        # TODO: Send push notification to iOS app
        
    except Card.DoesNotExist:
        logger.error(f"Card {card_id} not found")
    except Exception as e:
        logger.error(f"Failed to generate image for card {card_id}: {e}")
        
        # Mark as failed
        try:
            card = Card.objects.get(card_id=card_id)
            card.mark_failed(str(e))
        except Card.DoesNotExist:
            pass
        
        # Retry with exponential backoff
        raise self.retry(exc=e, countdown=60 * (2 ** self.request.retries))

