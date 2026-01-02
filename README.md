# AAC Communication Cards System

A full-stack application for generating and managing AAC (Augmentative and Alternative Communication) cards for non-verbal autistic children. This system provides multilingual support (Russian, Kazakh, English) with automatic image generation using Stable Diffusion.

## System Architecture

### Components:
1. **Django Backend** (REST API) - User management, card CRUD, analytics
2. **ML Microservice** (FastAPI) - Image generation using Stable Diffusion 1.5
3. **PostgreSQL** - Database for cards, users, translations
4. **Redis** - Caching and Celery broker
5. **AWS S3 / MinIO** - Image storage

## Features

- **Multilingual Support**: Russian, Kazakh, and English translations
- **Hybrid Translation System**: Database → Offline Dictionary → Google Translate
- **Automatic Image Generation**: AI-generated simple icon-style images
- **User Analytics**: Usage statistics, activity charts, recommendations
- **Card Management**: CRUD operations, favorites, custom cards
- **Async Processing**: Celery tasks for non-blocking image generation

## Project Structure

```
aac-diploma-project/
├── backend/                 # Django backend
│   ├── config/              # Django settings
│   ├── apps/
│   │   ├── cards/           # Card management
│   │   ├── users/           # User profiles
│   │   ├── analytics/       # Analytics and statistics
│   │   └── ml_integration/  # ML service integration
│   └── manage.py
├── ml_service/              # FastAPI ML service
│   ├── main.py
│   ├── models/              # Stable Diffusion models
│   └── utils/               # Image processing, S3 upload
├── docker/                  # Dockerfiles
├── scripts/                  # Database seeding scripts
└── docker-compose.yml       # Docker Compose configuration
```

## Prerequisites

- Python 3.11+
- PostgreSQL 15+
- Redis
- Docker & Docker Compose (optional)
- CUDA-capable GPU (for ML service, or use Google Colab)

## Installation

### 1. Clone the repository

```bash
git clone <repository-url>
cd aac-diploma-project
```

### 2. Backend Setup

```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Set up environment variables
export DEBUG=True
export DB_NAME=aac_db
export DB_USER=postgres
export DB_PASSWORD=postgres
export DB_HOST=localhost
export DB_PORT=5432
export CELERY_BROKER_URL=redis://localhost:6379/0
export CELERY_RESULT_BACKEND=redis://localhost:6379/0
export ML_SERVICE_URL=http://localhost:8001

# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Seed database
python ../scripts/seed_database.py
python ../scripts/seed_translations.py
```

### 3. ML Service Setup

```bash
cd ml_service

# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Set environment variables (optional, for S3)
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
export AWS_STORAGE_BUCKET_NAME=aac-cards

# Run service
uvicorn main:app --host 0.0.0.0 --port 8001
```

**Note**: The ML service requires a GPU for optimal performance. For development/testing, you can:
- Use Google Colab with free T4 GPU
- Use ngrok to expose Colab service to your local network
- Run locally with CPU (much slower)

### 4. Start Celery Worker

```bash
cd backend
celery -A config worker --loglevel=info
```

### 5. Run Django Development Server

```bash
cd backend
python manage.py runserver
```

## Docker Setup (Alternative)

```bash
# Build and start all services
docker-compose up -d

# Run migrations
docker-compose exec backend python manage.py migrate

# Create superuser
docker-compose exec backend python manage.py createsuperuser

# Seed database
docker-compose exec backend python ../scripts/seed_database.py
docker-compose exec backend python ../scripts/seed_translations.py

# View logs
docker-compose logs -f
```

## API Endpoints

### Cards
- `GET /api/v1/cards/` - List cards (filtered by user language)
- `GET /api/v1/cards/?category={id}` - Filter by category
- `GET /api/v1/cards/?search={word}` - Search in all languages
- `POST /api/v1/cards/generate/` - Create custom card with auto-translation
- `POST /api/v1/cards/{id}/use/` - Track card usage
- `POST /api/v1/cards/{id}/toggle-favorite/` - Add/remove from favorites
- `GET /api/v1/cards/popular/` - Popular cards
- `GET /api/v1/cards/favorites/` - User's favorite cards

### Categories
- `GET /api/v1/categories/` - List categories (localized)
- `GET /api/v1/categories/{id}/` - Category details

### Analytics
- `GET /api/v1/analytics/stats/` - User statistics
- `GET /api/v1/analytics/activity/?days=7` - Activity chart
- `GET /api/v1/analytics/popular/` - User's most used cards
- `GET /api/v1/analytics/categories/` - Usage by category
- `GET /api/v1/analytics/recommendations/` - Simple recommendations
- `GET /api/v1/translator-stats/` - Translation system statistics

### Users
- `GET /api/v1/users/me/` - Get current user profile
- `PATCH /api/v1/users/me/` - Update user profile
- `PATCH /api/v1/users/language/` - Change language preference

### ML Service
- `POST /generate` - Generate image from English word
- `GET /health` - Health check

## Example API Usage

### Create a Card

```bash
curl -X POST http://localhost:8000/api/v1/cards/generate/ \
  -H "Authorization: Token YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "word": "яблоко",
    "category_id": "category-uuid",
    "source_lang": "ru"
  }'
```

### Track Card Usage

```bash
curl -X POST http://localhost:8000/api/v1/cards/{card_id}/use/ \
  -H "Authorization: Token YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"language": "ru"}'
```

### Get Analytics

```bash
curl http://localhost:8000/api/v1/analytics/stats/ \
  -H "Authorization: Token YOUR_TOKEN"
```

## Translation System

The system uses a 3-level hybrid translation approach:

1. **Database Lookup**: Verified translations stored in database
2. **Offline Dictionary**: ~200 common words (instant, no internet)
3. **Google Translate API**: Fallback for rare words (auto-saves to DB)

### Offline Dictionary Categories:
- Food items
- Actions
- Emotions
- Places
- People
- Animals
- Objects
- Colors, numbers, nature items

## Card Generation Workflow

1. User inputs word (Russian or Kazakh)
2. System auto-translates to all languages (ru/kk/en)
3. Card created in database with status "pending"
4. Celery task triggered asynchronously
5. ML Service generates image using English word
6. Image uploaded to S3/MinIO
7. Card updated with image URL and status "completed"
8. Push notification sent to iOS app (TODO)

## Development Notes

### Running Tests

```bash
cd backend
python manage.py test
```

### Database Migrations

```bash
# Create migration
python manage.py makemigrations

# Apply migration
python manage.py migrate
```

### ML Service on Google Colab

1. Upload `ml_service/` folder to Colab
2. Install dependencies: `!pip install -r requirements.txt`
3. Run service: `!uvicorn main:app --host 0.0.0.0 --port 8001`
4. Use ngrok to expose: `!ngrok http 8001`
5. Update `ML_SERVICE_URL` in Django settings to ngrok URL

## Performance Targets

- API response: < 200ms (without ML)
- ML generation: 3-10 seconds (Colab GPU)
- Translation: instant (DB/offline), <2s (Google API)
- Support: 1000+ cards in database

## Environment Variables

### Backend
- `DEBUG` - Debug mode (True/False)
- `SECRET_KEY` - Django secret key
- `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT` - Database config
- `CELERY_BROKER_URL` - Redis broker URL
- `CELERY_RESULT_BACKEND` - Redis result backend
- `ML_SERVICE_URL` - ML service endpoint
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` - S3 credentials
- `AWS_STORAGE_BUCKET_NAME` - S3 bucket name
- `AWS_S3_ENDPOINT_URL` - MinIO endpoint (optional)
- `GOOGLE_TRANSLATE_ENABLED` - Enable Google Translate (True/False)

### ML Service
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` - S3 credentials
- `AWS_STORAGE_BUCKET_NAME` - S3 bucket name
- `AWS_S3_ENDPOINT_URL` - MinIO endpoint (optional)

## Troubleshooting

### Database Connection Issues
- Ensure PostgreSQL is running
- Check database credentials in environment variables
- Verify database exists: `createdb aac_db`

### Celery Not Processing Tasks
- Ensure Redis is running
- Check Celery worker logs
- Verify broker URL in settings

### ML Service Not Responding
- Check if service is running on port 8001
- Verify GPU availability (for local setup)
- Check ML service logs for errors

### Translation Not Working
- Verify Google Translate API is enabled
- Check internet connection (for Google Translate)
- Review translation logs in Django

## Testing

See [TESTING.md](TESTING.md) for comprehensive testing guide.

### Quick Test

```bash
# Get authentication token (create user first)
python manage.py shell
# from django.contrib.auth.models import User
# from rest_framework.authtoken.models import Token
# user = User.objects.create_user('testuser', 'test@example.com', 'testpass')
# token = Token.objects.create(user=user)
# print(token.key)

# Set token and run tests
export API_TOKEN="your-token-here"
python test_api.py
```

### Manual Testing

1. **Test API Endpoints**: Use `test_api.py` or curl commands
2. **Test Translation**: Use Django shell to test translator
3. **Test ML Service**: Check health endpoint and generate test image
4. **Test Celery**: Generate a card and verify task processing

See [TESTING.md](TESTING.md) for detailed instructions.

## License

This project is part of a diploma thesis.

## Contributors

- Backend: Django team
- ML Service: FastAPI team
- iOS Frontend: (handled by another team)
