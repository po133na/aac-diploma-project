# AAC Image Generator — Backend API

Backend for a mobile AAC (Augmentative and Alternative Communication) application. AAC apps help people with speech and language difficulties communicate by using visual symbol cards.

## About the Project

The app allows users to:
- Browse a board of visual communication cards organized by categories
- Build sentences from cards and have them read aloud
- Generate new cards using AI by describing an image in Russian or Kazakh
- Upload photos from a camera or gallery as card images
- Track usage statistics and streaks

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | FastAPI |
| Database | PostgreSQL (via asyncpg) |
| ORM | SQLAlchemy 2.0 (async) |
| Auth | JWT (python-jose) + bcrypt |
| Image Generation | Hugging Face FLUX.1-schnell |
| Translation | deep-translator (Google Translate) |
| Text-to-Speech | Edge TTS (Microsoft Neural Voices) |
| Containerization | Docker + Docker Compose |

---

## Getting Started

### Prerequisites

- Docker and Docker Compose installed
- Hugging Face account with API token ([huggingface.co](https://huggingface.co))

### Setup

1. Clone the repository and go to the project folder:
   ```bash
   cd image_generator
   ```

2. Create a `.env` file based on the example:
   ```bash
   cp .env.example .env
   ```

3. Fill in the `.env` file:
   ```env
   HUGGINGFACE_API_TOKEN=hf_your_token_here
   SECRET_KEY=your_random_secret_key
   POSTGRES_USER=aac_user
   POSTGRES_PASSWORD=aac_password
   POSTGRES_DB=aac_db
   ```

4. Start the containers:
   ```bash
   docker compose up -d
   ```

5. The API will be available at `http://localhost:8000`

On first startup, the database is initialized automatically with default categories and pre-loaded Basics cards (I, You, Want, Need, Help, Yes, No, Please, Eat, Drink, Play, Sleep, Go, Read, Watch, Draw, Sing, Dance, Jump).

---

## API Reference

Interactive docs are available at `http://localhost:8000/docs`

### Auth

| Method | Endpoint | Description |
|---|---|---|
| POST | `/auth/register` | Register a new user |
| POST | `/auth/login` | Login, returns JWT token |
| GET | `/auth/me` | Get current user profile |
| PATCH | `/auth/me` | Update profile (name, email, avatar) |
| DELETE | `/auth/me` | Delete account |
| POST | `/auth/change-password` | Change password |
| POST | `/auth/forgot-password` | Request password reset token |
| POST | `/auth/reset-password` | Reset password using token |

All endpoints except register/login require `Authorization: Bearer <token>` header.

### Cards

| Method | Endpoint | Description |
|---|---|---|
| GET | `/cards` | Get cards (supports `category_id`, `favorites_only`, `search`) |
| GET | `/cards/{id}` | Get a single card |
| POST | `/cards/generate` | Generate an image with AI (not saved yet) |
| POST | `/cards/save` | Save a previously generated card |
| POST | `/cards/upload` | Create a card from a photo (base64) |
| PATCH | `/cards/{id}` | Update card (favorite, category) |
| POST | `/cards/{id}/use` | Increment usage counter + track daily streak |
| DELETE | `/cards/{id}` | Delete a card |

**Generate + Save flow** (used by the app):
```
POST /cards/generate  →  user sees the image  →  POST /cards/save
```

### Categories

| Method | Endpoint | Description |
|---|---|---|
| GET | `/categories` | Get all categories (system + user's own) |
| POST | `/categories` | Create a custom category |
| DELETE | `/categories/{id}` | Delete a custom category |

System categories (Basics, Food, Animals, Actions, Emotions, Family, Places, Objects, Colors) are shared across all users and cannot be deleted.

### Text-to-Speech

| Method | Endpoint | Description |
|---|---|---|
| POST | `/tts` | Convert text to speech (returns base64 MP3) |

Supported languages and voices:
- `ru` — Russian (Dmitry Neural)
- `kk` — Kazakh (Aigul Neural)
- `en` — English (Jenny Neural)

### Phrases

| Method | Endpoint | Description |
|---|---|---|
| GET | `/phrases` | Get all saved phrases |
| POST | `/phrases` | Save a phrase (list of card IDs + name) |
| GET | `/phrases/{id}` | Get phrase with full card data |
| POST | `/phrases/{id}/use` | Increment usage counter |
| POST | `/phrases/{id}/speak` | Speak the full phrase via TTS |
| DELETE | `/phrases/{id}` | Delete a phrase |

### User Settings

| Method | Endpoint | Description |
|---|---|---|
| GET | `/user/settings` | Get settings |
| PATCH | `/user/settings` | Update settings |

Settings fields:
- `voice`: `"male"` / `"female"` / `"child"`
- `language`: `"ru"` / `"kk"` / `"en"`
- `appearance`: `"light"` / `"dark"` / `"auto"`
- `grid_size`: `"standard"` / `"large"`

### Statistics

| Method | Endpoint | Description |
|---|---|---|
| GET | `/user/statistics` | Get usage statistics |

Response includes:
- `total_cards` — total cards created
- `total_card_uses` — total card taps
- `this_week_cards` — cards used in the last 7 days
- `current_streak` — consecutive days with activity
- `top_cards` / `top_phrases` — most used

---

## Project Structure

```
image_generator/
├── app/
│   ├── main.py          # All API endpoints
│   ├── models.py        # SQLAlchemy models (User, Card, Category, Phrase, UserSettings, DailyUsage)
│   ├── schemas.py       # Pydantic request/response schemas
│   ├── database.py      # DB engine and session
│   ├── config.py        # Environment settings
│   ├── auth.py          # JWT auth helpers
│   ├── tts.py           # Text-to-speech (Edge TTS)
│   └── translation.py   # Text translation (Google Translate)
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
└── .env
```

---

## Useful Commands

```bash
# Start all services
docker compose up -d

# View API logs
docker logs aac_api -f

# Restart only the API (after code changes)
docker compose build api && docker compose up -d api

# Connect to the database
docker exec -it aac_postgres psql -U aac_user -d aac_db

# Stop everything
docker compose down
```
