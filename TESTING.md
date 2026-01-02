# Testing Guide for AAC Communication Cards System

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Setting Up Test Environment](#setting-up-test-environment)
3. [Testing API Endpoints](#testing-api-endpoints)
4. [Testing Translation System](#testing-translation-system)
5. [Testing ML Service](#testing-ml-service)
6. [Testing Celery Tasks](#testing-celery-tasks)
7. [Integration Testing](#integration-testing)
8. [Manual Testing Checklist](#manual-testing-checklist)

## Prerequisites

Before testing, ensure you have:
- Django backend running on `http://localhost:8000`
- PostgreSQL database set up and migrated
- Redis running (for Celery)
- ML service running on `http://localhost:8001` (optional for full testing)
- A test user account created

## Setting Up Test Environment

### 1. Create Test User and Get Token

```bash
# Create superuser
cd backend
python manage.py createsuperuser

# Or create user via Django shell
python manage.py shell
```

```python
from django.contrib.auth.models import User
from rest_framework.authtoken.models import Token

# Create user
user = User.objects.create_user('testuser', 'test@example.com', 'testpass123')
user.save()

# Create token
token = Token.objects.create(user=user)
print(f"Token: {token.key}")
```

### 2. Seed Test Data

```bash
# Seed categories and cards
python ../scripts/seed_database.py
python ../scripts/seed_translations.py
```

## Testing API Endpoints

### Using cURL

#### 1. Get Authentication Token

```bash
# Method 1: Using Django REST Framework token endpoint (if available)
curl -X POST http://localhost:8000/api/v1/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "testpass123"}'

# Method 2: Get token from Django admin or shell (see above)
# Then use it in headers:
export TOKEN="your-token-here"
```

#### 2. Test Cards Endpoints

```bash
# List all cards
curl http://localhost:8000/api/v1/cards/ \
  -H "Authorization: Token $TOKEN"

# Search cards
curl "http://localhost:8000/api/v1/cards/?search=яблоко" \
  -H "Authorization: Token $TOKEN"

# Filter by category
curl "http://localhost:8000/api/v1/cards/?category=<category_id>" \
  -H "Authorization: Token $TOKEN"

# Generate a new card
curl -X POST http://localhost:8000/api/v1/cards/generate/ \
  -H "Authorization: Token $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "word": "книга",
    "source_lang": "ru"
  }'

# Track card usage
curl -X POST http://localhost:8000/api/v1/cards/<card_id>/use/ \
  -H "Authorization: Token $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"language": "ru"}'

# Toggle favorite
curl -X POST http://localhost:8000/api/v1/cards/<card_id>/toggle-favorite/ \
  -H "Authorization: Token $TOKEN"

# Get popular cards
curl http://localhost:8000/api/v1/cards/popular/ \
  -H "Authorization: Token $TOKEN"

# Get favorites
curl http://localhost:8000/api/v1/cards/favorites/ \
  -H "Authorization: Token $TOKEN"
```

#### 3. Test Categories Endpoints

```bash
# List all categories
curl http://localhost:8000/api/v1/categories/ \
  -H "Authorization: Token $TOKEN"

# Get category details
curl http://localhost:8000/api/v1/categories/<category_id>/ \
  -H "Authorization: Token $TOKEN"
```

#### 4. Test Analytics Endpoints

```bash
# Get user statistics
curl http://localhost:8000/api/v1/analytics/stats/ \
  -H "Authorization: Token $TOKEN"

# Get activity chart (last 7 days)
curl "http://localhost:8000/api/v1/analytics/activity/?days=7" \
  -H "Authorization: Token $TOKEN"

# Get popular cards for user
curl http://localhost:8000/api/v1/analytics/popular/ \
  -H "Authorization: Token $TOKEN"

# Get category breakdown
curl http://localhost:8000/api/v1/analytics/categories/ \
  -H "Authorization: Token $TOKEN"

# Get recommendations
curl http://localhost:8000/api/v1/analytics/recommendations/ \
  -H "Authorization: Token $TOKEN"

# Get translation stats
curl http://localhost:8000/api/v1/translator-stats/ \
  -H "Authorization: Token $TOKEN"
```

#### 5. Test User Endpoints

```bash
# Get user profile
curl http://localhost:8000/api/v1/users/me/ \
  -H "Authorization: Token $TOKEN"

# Update language preference
curl -X PATCH http://localhost:8000/api/v1/users/language/ \
  -H "Authorization: Token $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"language": "kk"}'
```

### Using Python Requests

Create a test script `test_api.py`:

```python
import requests
import json

BASE_URL = "http://localhost:8000/api/v1"
TOKEN = "your-token-here"

headers = {
    "Authorization": f"Token {TOKEN}",
    "Content-Type": "application/json"
}

# Test 1: List cards
response = requests.get(f"{BASE_URL}/cards/", headers=headers)
print(f"List Cards: {response.status_code}")
print(json.dumps(response.json(), indent=2, ensure_ascii=False))

# Test 2: Generate card
data = {
    "word": "солнце",
    "source_lang": "ru"
}
response = requests.post(f"{BASE_URL}/cards/generate/", headers=headers, json=data)
print(f"\nGenerate Card: {response.status_code}")
print(json.dumps(response.json(), indent=2, ensure_ascii=False))

# Test 3: Get analytics
response = requests.get(f"{BASE_URL}/analytics/stats/", headers=headers)
print(f"\nAnalytics: {response.status_code}")
print(json.dumps(response.json(), indent=2, ensure_ascii=False))
```

Run it:
```bash
python test_api.py
```

### Using Postman

1. **Import Collection**: Create a Postman collection with all endpoints
2. **Set Environment Variables**:
   - `base_url`: `http://localhost:8000/api/v1`
   - `token`: Your authentication token
3. **Test Each Endpoint**: Use Postman's test scripts to verify responses

## Testing Translation System

### Test Offline Dictionary

```python
# In Django shell: python manage.py shell
from apps.ml_integration.offline_dictionary import get_offline_translation

# Test Russian to other languages
result = get_offline_translation("яблоко", source_lang="ru")
print(result)  # Should return: ('яблоко', 'алма', 'apple', 'Food')

# Test Kazakh to other languages
result = get_offline_translation("алма", source_lang="kk")
print(result)  # Should return: ('яблоко', 'алма', 'apple', 'Food')
```

### Test Hybrid Translator

```python
# In Django shell
from apps.ml_integration.translator import HybridTranslator

translator = HybridTranslator()

# Test with offline dictionary word
word_ru, word_kk, word_en, category = translator.translate("яблоко", source_lang="ru")
print(f"RU: {word_ru}, KK: {word_kk}, EN: {word_en}, Category: {category}")

# Test with database word (if exists)
word_ru, word_kk, word_en, category = translator.translate("дом", source_lang="ru")
print(f"RU: {word_ru}, KK: {word_kk}, EN: {word_en}, Category: {category}")

# Test with Google Translate (requires internet)
word_ru, word_kk, word_en, category = translator.translate("электромобиль", source_lang="ru")
print(f"RU: {word_ru}, KK: {word_kk}, EN: {word_en}, Category: {category}")

# Get translation stats
stats = translator.get_translation_stats()
print(stats)
```

### Test Translation via API

```bash
# Generate a card (this uses translation)
curl -X POST http://localhost:8000/api/v1/cards/generate/ \
  -H "Authorization: Token $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "word": "телефон",
    "source_lang": "ru"
  }'

# Check the response - should have word_ru, word_kk, word_en
```

## Testing ML Service

### Health Check

```bash
curl http://localhost:8001/health
```

Expected response:
```json
{
  "status": "healthy",
  "model_loaded": true
}
```

### Generate Image

```bash
curl -X POST http://localhost:8001/generate \
  -H "Content-Type: application/json" \
  -d '{
    "word": "apple",
    "prompt": "apple, simple icon, flat design, minimalist, white background",
    "num_inference_steps": 20,
    "guidance_scale": 7.5
  }'
```

Expected response:
```json
{
  "image_url": "https://...",
  "thumbnail_url": "https://...",
  "generation_params": {...}
}
```

### Test ML Service Integration

```python
# In Django shell
from apps.ml_integration.client import MLServiceClient

client = MLServiceClient()

# Health check
is_healthy = client.health_check()
print(f"ML Service healthy: {is_healthy}")

# Generate image (requires ML service running)
try:
    result = client.generate_image("apple")
    print(f"Image URL: {result['image_url']}")
except Exception as e:
    print(f"Error: {e}")
```

## Testing Celery Tasks

### Start Celery Worker

```bash
cd backend
celery -A config worker --loglevel=info
```

### Test Task Execution

```python
# In Django shell
from apps.cards.models import Card
from apps.cards.tasks import generate_card_image_task

# Create a test card
card = Card.objects.create(
    word_ru="тест",
    word_kk="тест",
    word_en="test",
    generation_status=Card.GenerationStatus.PENDING
)

# Trigger task
generate_card_image_task.delay(str(card.card_id))

# Check task status (in another terminal, watch Celery logs)
# Or check card status after a few seconds
card.refresh_from_db()
print(f"Status: {card.generation_status}")
print(f"Image URL: {card.image_url}")
```

### Monitor Celery Tasks

```bash
# In Celery worker terminal, you should see:
# [INFO] Task apps.cards.tasks.generate_card_image_task[<task_id>] received
# [INFO] Generating image for word: test
# [INFO] Successfully generated image for card <card_id>
```

## Integration Testing

### Full Card Generation Workflow

```python
# test_integration.py
import requests
import time

BASE_URL = "http://localhost:8000/api/v1"
TOKEN = "your-token-here"

headers = {
    "Authorization": f"Token {TOKEN}",
    "Content-Type": "application/json"
}

# Step 1: Generate card
print("1. Generating card...")
response = requests.post(
    f"{BASE_URL}/cards/generate/",
    headers=headers,
    json={"word": "книга", "source_lang": "ru"}
)
card_data = response.json()
card_id = card_data['card_id']
print(f"Card created: {card_id}")
print(f"Status: {card_data['generation_status']}")

# Step 2: Wait for image generation (if ML service is running)
if card_data['generation_status'] == 'pending':
    print("2. Waiting for image generation...")
    for i in range(30):  # Wait up to 30 seconds
        time.sleep(1)
        response = requests.get(f"{BASE_URL}/cards/{card_id}/", headers=headers)
        card_data = response.json()
        if card_data['generation_status'] == 'completed':
            print(f"Image generated: {card_data['image_url']}")
            break
        elif card_data['generation_status'] == 'failed':
            print(f"Generation failed: {card_data.get('generation_error')}")
            break

# Step 3: Track usage
print("3. Tracking usage...")
response = requests.post(
    f"{BASE_URL}/cards/{card_id}/use/",
    headers=headers,
    json={"language": "ru"}
)
print(f"Usage tracked: {response.status_code}")

# Step 4: Add to favorites
print("4. Adding to favorites...")
response = requests.post(
    f"{BASE_URL}/cards/{card_id}/toggle-favorite/",
    headers=headers
)
print(f"Favorite status: {response.json()['is_favorite']}")

# Step 5: Check analytics
print("5. Checking analytics...")
response = requests.get(f"{BASE_URL}/analytics/stats/", headers=headers)
print(f"Total usage: {response.json()['total_usage']}")
```

## Manual Testing Checklist

### Authentication
- [ ] Create user account
- [ ] Get authentication token
- [ ] Access protected endpoints with token
- [ ] Verify unauthorized access is blocked

### Cards
- [ ] List all cards
- [ ] Search cards by word
- [ ] Filter cards by category
- [ ] Generate new card (Russian word)
- [ ] Generate new card (Kazakh word)
- [ ] Verify translations are correct
- [ ] Track card usage
- [ ] Toggle favorite status
- [ ] View popular cards
- [ ] View favorite cards

### Categories
- [ ] List all categories
- [ ] Verify category names are localized
- [ ] Get cards in a category

### Analytics
- [ ] View user statistics
- [ ] View activity chart (7 days)
- [ ] View activity chart (30 days)
- [ ] View popular cards for user
- [ ] View category breakdown
- [ ] View recommendations
- [ ] Verify statistics update after usage

### Translation
- [ ] Test offline dictionary words
- [ ] Test database translations
- [ ] Test Google Translate fallback (if enabled)
- [ ] View translation statistics

### ML Service
- [ ] Health check returns OK
- [ ] Image generation works
- [ ] Images are uploaded to S3
- [ ] Thumbnails are created
- [ ] Error handling works

### Celery
- [ ] Tasks are queued
- [ ] Tasks are processed
- [ ] Card status updates correctly
- [ ] Errors are handled gracefully

## Automated Testing (Future)

To add automated tests, create test files:

```python
# backend/apps/cards/tests.py
from django.test import TestCase
from django.contrib.auth.models import User
from rest_framework.test import APIClient
from apps.cards.models import Card, Category

class CardAPITestCase(TestCase):
    def setUp(self):
        self.user = User.objects.create_user('testuser', 'test@example.com', 'testpass')
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)
    
    def test_list_cards(self):
        response = self.client.get('/api/v1/cards/')
        self.assertEqual(response.status_code, 200)
    
    def test_generate_card(self):
        data = {'word': 'яблоко', 'source_lang': 'ru'}
        response = self.client.post('/api/v1/cards/generate/', data)
        self.assertEqual(response.status_code, 201)
        self.assertIn('card_id', response.json())
```

Run tests:
```bash
python manage.py test
```

## Troubleshooting Tests

### Common Issues

1. **401 Unauthorized**: Check token is valid and included in headers
2. **404 Not Found**: Verify endpoint URLs are correct
3. **500 Server Error**: Check Django logs for details
4. **ML Service Timeout**: Ensure ML service is running and accessible
5. **Celery Tasks Not Processing**: Check Redis is running and Celery worker is active

### Debug Tips

```python
# Enable Django debug logging
import logging
logging.basicConfig(level=logging.DEBUG)

# Check database state
from apps.cards.models import Card
print(Card.objects.count())

# Check Celery task status
from celery.result import AsyncResult
result = AsyncResult('task-id')
print(result.state)
```

## Performance Testing

### Load Testing with Apache Bench

```bash
# Test cards endpoint
ab -n 100 -c 10 -H "Authorization: Token $TOKEN" \
  http://localhost:8000/api/v1/cards/
```

### Monitor Performance

- Check response times in Django logs
- Monitor database query count
- Check Celery task processing time
- Monitor ML service response time

