from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime
from io import BytesIO
import base64

from huggingface_hub import InferenceClient

from app.config import settings
from app.schemas import (
    GenerationRequest, 
    GenerationResponse, 
    CardCreate, 
    CardResponse, 
    CardListResponse
)
from app.database import init_db, get_session
from app.models import Card
from app.translation import translate_to_english

app = FastAPI(
    title="AAC Image Generator API",
    description="API для генерации карточек с изображениями для AAC приложения",
    version="1.0.0"
)

# CORS для iOS приложения
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # В продакшене заменить на конкретные домены
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Hugging Face клиент
hf_client = InferenceClient(token=settings.HUGGINGFACE_API_TOKEN)


@app.on_event("startup")
async def startup():
    await init_db()


@app.get("/")
async def root():
    return {
        "status": "running",
        "service": "AAC Image Generator",
        "version": "1.0.0"
    }


@app.get("/health")
async def health_check():
    return {"status": "healthy"}


# === Карточки AAC ===

@app.post("/cards", response_model=CardResponse)
async def create_card(
    card_data: CardCreate,
    session: AsyncSession = Depends(get_session)
):
    """
    Создать карточку: слово → перевод → генерация изображения → сохранение
    """
    try:
        # 1. Перевод на английский
        translated = await translate_to_english(card_data.word, card_data.language)
        
        # 2. Генерация изображения
        prompt = f"simple illustration of {translated}, clear icon style, white background, child-friendly"
        
        image = hf_client.text_to_image(
            prompt=prompt,
            model="black-forest-labs/FLUX.1-schnell",
        )
        
        # 3. Конвертация в base64
        buffer = BytesIO()
        image.save(buffer, format="PNG")
        image_base64 = base64.b64encode(buffer.getvalue()).decode("utf-8")
        
        # 4. Сохранение в БД
        card = Card(
            word=card_data.word,
            language=card_data.language,
            translated_word=translated,
            image_base64=image_base64
        )
        session.add(card)
        await session.commit()
        await session.refresh(card)
        
        return card
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/cards", response_model=CardListResponse)
async def get_cards(session: AsyncSession = Depends(get_session)):
    """
    Получить все карточки
    """
    result = await session.execute(select(Card).order_by(Card.created_at.desc()))
    cards = result.scalars().all()
    
    return CardListResponse(cards=cards, total=len(cards))


@app.get("/cards/{card_id}", response_model=CardResponse)
async def get_card(card_id: int, session: AsyncSession = Depends(get_session)):
    """
    Получить карточку по ID
    """
    result = await session.execute(select(Card).where(Card.id == card_id))
    card = result.scalar_one_or_none()
    
    if not card:
        raise HTTPException(status_code=404, detail="Card not found")
    
    return card


@app.delete("/cards/{card_id}")
async def delete_card(card_id: int, session: AsyncSession = Depends(get_session)):
    """
    Удалить карточку
    """
    result = await session.execute(select(Card).where(Card.id == card_id))
    card = result.scalar_one_or_none()
    
    if not card:
        raise HTTPException(status_code=404, detail="Card not found")
    
    await session.delete(card)
    await session.commit()
    
    return {"status": "deleted", "id": card_id}


# === Старый эндпоинт генерации (для совместимости) ===

@app.post("/generate", response_model=GenerationResponse)
async def generate_image(request: GenerationRequest):
    """
    Прямая генерация изображения по промпту (без сохранения)
    """
    try:
        image = hf_client.text_to_image(
            prompt=request.prompt,
            model="black-forest-labs/FLUX.1-schnell",
        )

        buffer = BytesIO()
        image.save(buffer, format="PNG")
        image_base64 = base64.b64encode(buffer.getvalue()).decode("utf-8")
        image_url = f"data:image/png;base64,{image_base64}"

        return GenerationResponse(
            image_url=image_url,
            created_at=datetime.now()
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))