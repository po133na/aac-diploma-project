# Quick Start Guide

## Prerequisites
- Python 3.11+
- PostgreSQL 15+
- Redis
- (Optional) Docker & Docker Compose

## Quick Setup (5 minutes)

### 1. Backend Setup

```bash
# Navigate to backend
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Set environment variables (or create .env file)
export DEBUG=True
export DB_NAME=aac_db
export DB_USER=postgres
export DB_PASSWORD=postgres
export DB_HOST=localhost

# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Seed database
python ../scripts/seed_database.py
python ../scripts/seed_translations.py

# Start server
python manage.py runserver
```

### 2. Start Redis

```bash
# Using Docker
docker run -d -p 6379:6379 redis:7-alpine

# Or install locally
redis-server
```

### 3. Start Celery Worker

```bash
cd backend
celery -A config worker --loglevel=info
```

### 4. ML Service (Optional for testing)

The ML service requires a GPU. For development, you can:
- Skip it and test other features
- Use Google Colab with ngrok
- Run locally if you have a GPU

```bash
cd ml_service
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8001
```

## Testing the API

### 1. Get Authentication Token

```bash
# Create a user first via Django admin or:
python manage.py createsuperuser

# Then get token:
curl -X POST http://localhost:8000/api/v1/users/me/ \
  -u username:password
```

### 2. Create a Card

```bash
curl -X POST http://localhost:8000/api/v1/cards/generate/ \
  -H "Authorization: Token YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"word": "яблоко", "source_lang": "ru"}'
```

### 3. List Cards

```bash
curl http://localhost:8000/api/v1/cards/ \
  -H "Authorization: Token YOUR_TOKEN"
```

### 4. Get Analytics

```bash
curl http://localhost:8000/api/v1/analytics/stats/ \
  -H "Authorization: Token YOUR_TOKEN"
```

## Docker Quick Start

```bash
# Start all services
docker-compose up -d

# Run migrations
docker-compose exec backend python manage.py migrate

# Create superuser
docker-compose exec backend python manage.py createsuperuser

# Seed database
docker-compose exec backend python ../scripts/seed_database.py
```

## Common Issues

### Database Connection Error
- Ensure PostgreSQL is running
- Check credentials in environment variables
- Create database: `createdb aac_db`

### Celery Not Working
- Ensure Redis is running
- Check `CELERY_BROKER_URL` in settings

### ML Service Errors
- ML service requires GPU or Google Colab
- For testing, you can mock the ML service responses

## Next Steps

1. Read the full README.md for detailed documentation
2. Explore the API endpoints
3. Set up S3/MinIO for image storage
4. Configure Google Translate API (optional)

