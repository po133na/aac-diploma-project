from fastapi import FastAPI, HTTPException, Depends, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime, timedelta
from io import BytesIO
import base64

from huggingface_hub import InferenceClient

from app.config import settings
from app.schemas import (
    UserCreate, UserLogin, UserResponse, Token,
    CategoryCreate, CategoryResponse, CategoryListResponse,
    CardCreate, CardUpdate, CardResponse, CardListResponse,
    TTSRequest, TTSResponse,
    PhraseCreate, PhraseResponse, PhraseListResponse, PhraseWithCardsResponse
)
from app.database import init_db, get_session
from app.models import User, Category, Card, Phrase
from app.translation import translate_to_english
from app.auth import (
    get_password_hash, verify_password, create_access_token, get_current_user
)
from app.tts import text_to_speech

app = FastAPI(
    title="AAC Image Generator API",
    description="API для генерации карточек с изображениями для AAC приложения",
    version="2.0.0"
)

# CORS для iOS приложения
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Hugging Face клиент
hf_client = InferenceClient(token=settings.HUGGINGFACE_API_TOKEN)


@app.on_event("startup")
async def startup():
    await init_db()
    # Создаём системные категории при первом запуске
    async for session in get_session():
        await create_default_categories(session)
        break


async def create_default_categories(session: AsyncSession):
    """Создаёт стандартные категории если их нет"""
    result = await session.execute(select(Category).where(Category.user_id == None))
    if result.first() is None:
        default_categories = [
            {"name": "Еда", "name_kk": "Тамақ", "name_en": "Food", "icon": "🍎"},
            {"name": "Животные", "name_kk": "Жануарлар", "name_en": "Animals", "icon": "🐱"},
            {"name": "Действия", "name_kk": "Әрекеттер", "name_en": "Actions", "icon": "🏃"},
            {"name": "Эмоции", "name_kk": "Эмоциялар", "name_en": "Emotions", "icon": "😊"},
            {"name": "Семья", "name_kk": "Отбасы", "name_en": "Family", "icon": "👨‍👩‍👧"},
            {"name": "Места", "name_kk": "Орындар", "name_en": "Places", "icon": "🏠"},
            {"name": "Предметы", "name_kk": "Заттар", "name_en": "Objects", "icon": "📦"},
            {"name": "Цвета", "name_kk": "Түстер", "name_en": "Colors", "icon": "🎨"},
        ]
        for cat_data in default_categories:
            category = Category(**cat_data)
            session.add(category)
        await session.commit()


@app.get("/")
async def root():
    return {
        "status": "running",
        "service": "AAC Image Generator",
        "version": "2.0.0"
    }


@app.get("/health")
async def health_check():
    return {"status": "healthy"}


# ==================== АВТОРИЗАЦИЯ ====================

@app.post("/auth/register", response_model=UserResponse)
async def register(user_data: UserCreate, session: AsyncSession = Depends(get_session)):
    """Регистрация нового пользователя"""
    # Проверяем, существует ли пользователь
    result = await session.execute(select(User).where(User.email == user_data.email))
    if result.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Email already registered")
    
    # Создаём пользователя
    user = User(
        email=user_data.email,
        username=user_data.username,
        hashed_password=get_password_hash(user_data.password)
    )
    session.add(user)
    await session.commit()
    await session.refresh(user)
    
    return user


@app.post("/auth/login", response_model=Token)
async def login(user_data: UserLogin, session: AsyncSession = Depends(get_session)):
    """Вход в систему"""
    result = await session.execute(select(User).where(User.email == user_data.email))
    user = result.scalar_one_or_none()
    
    if not user or not verify_password(user_data.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Incorrect email or password")
    
    access_token = create_access_token(data={"sub": str(user.id)})
    return Token(access_token=access_token)


@app.get("/auth/me", response_model=UserResponse)
async def get_me(current_user: User = Depends(get_current_user)):
    """Получить данные текущего пользователя"""
    return current_user


# ==================== КАТЕГОРИИ ====================

@app.get("/categories", response_model=CategoryListResponse)
async def get_categories(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Получить все категории (системные + пользовательские)"""
    result = await session.execute(
        select(Category).where(
            (Category.user_id == None) | (Category.user_id == current_user.id)
        ).order_by(Category.name)
    )
    categories = result.scalars().all()
    return CategoryListResponse(categories=categories, total=len(categories))


@app.post("/categories", response_model=CategoryResponse)
async def create_category(
    category_data: CategoryCreate,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Создать пользовательскую категорию"""
    category = Category(
        **category_data.model_dump(),
        user_id=current_user.id
    )
    session.add(category)
    await session.commit()
    await session.refresh(category)
    return category


@app.delete("/categories/{category_id}")
async def delete_category(
    category_id: int,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Удалить пользовательскую категорию"""
    result = await session.execute(
        select(Category).where(
            Category.id == category_id,
            Category.user_id == current_user.id  # Только свои категории
        )
    )
    category = result.scalar_one_or_none()
    
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    
    await session.delete(category)
    await session.commit()
    return {"status": "deleted", "id": category_id}


# ==================== КАРТОЧКИ ====================

@app.post("/cards", response_model=CardResponse)
async def create_card(
    card_data: CardCreate,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Создать карточку: слово → перевод → генерация изображения → сохранение"""
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
            image_base64=image_base64,
            category_id=card_data.category_id,
            user_id=current_user.id
        )
        session.add(card)
        await session.commit()
        await session.refresh(card)
        
        return card
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/cards", response_model=CardListResponse)
async def get_cards(
    category_id: int = Query(None, description="Фильтр по категории"),
    favorites_only: bool = Query(False, description="Только избранные"),
    search: str = Query(None, description="Поиск по слову"),
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Получить карточки пользователя с фильтрами"""
    query = select(Card).where(Card.user_id == current_user.id)
    
    if category_id:
        query = query.where(Card.category_id == category_id)
    
    if favorites_only:
        query = query.where(Card.is_favorite == True)
    
    if search:
        query = query.where(Card.word.ilike(f"%{search}%"))
    
    query = query.order_by(Card.usage_count.desc(), Card.created_at.desc())
    
    result = await session.execute(query)
    cards = result.scalars().all()
    
    return CardListResponse(cards=cards, total=len(cards))


@app.get("/cards/{card_id}", response_model=CardResponse)
async def get_card(
    card_id: int,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Получить карточку по ID"""
    result = await session.execute(
        select(Card).where(Card.id == card_id, Card.user_id == current_user.id)
    )
    card = result.scalar_one_or_none()
    
    if not card:
        raise HTTPException(status_code=404, detail="Card not found")
    
    return card


@app.patch("/cards/{card_id}", response_model=CardResponse)
async def update_card(
    card_id: int,
    card_data: CardUpdate,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Обновить карточку (избранное, категория)"""
    result = await session.execute(
        select(Card).where(Card.id == card_id, Card.user_id == current_user.id)
    )
    card = result.scalar_one_or_none()
    
    if not card:
        raise HTTPException(status_code=404, detail="Card not found")
    
    if card_data.is_favorite is not None:
        card.is_favorite = card_data.is_favorite
    
    if card_data.category_id is not None:
        card.category_id = card_data.category_id
    
    await session.commit()
    await session.refresh(card)
    
    return card


@app.post("/cards/{card_id}/use", response_model=CardResponse)
async def use_card(
    card_id: int,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Увеличить счётчик использования карточки"""
    result = await session.execute(
        select(Card).where(Card.id == card_id, Card.user_id == current_user.id)
    )
    card = result.scalar_one_or_none()
    
    if not card:
        raise HTTPException(status_code=404, detail="Card not found")
    
    card.usage_count += 1
    await session.commit()
    await session.refresh(card)
    
    return card


@app.delete("/cards/{card_id}")
async def delete_card(
    card_id: int,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Удалить карточку"""
    result = await session.execute(
        select(Card).where(Card.id == card_id, Card.user_id == current_user.id)
    )
    card = result.scalar_one_or_none()
    
    if not card:
        raise HTTPException(status_code=404, detail="Card not found")
    
    await session.delete(card)
    await session.commit()
    
    return {"status": "deleted", "id": card_id}


# ==================== ОЗВУЧКА (TTS) ====================

@app.post("/tts", response_model=TTSResponse)
async def speak(
    tts_data: TTSRequest,
    current_user: User = Depends(get_current_user)
):
    """Преобразовать текст в речь"""
    try:
        audio_base64 = await text_to_speech(tts_data.text, tts_data.language)
        return TTSResponse(audio_base64=audio_base64)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==================== ФРАЗЫ ====================

@app.post("/phrases", response_model=PhraseResponse)
async def create_phrase(
    phrase_data: PhraseCreate,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Создать фразу из карточек"""
    # Проверяем что все карточки принадлежат пользователю
    for card_id in phrase_data.card_ids:
        result = await session.execute(
            select(Card).where(Card.id == card_id, Card.user_id == current_user.id)
        )
        if not result.scalar_one_or_none():
            raise HTTPException(status_code=404, detail=f"Card {card_id} not found")
    
    # Сохраняем ID карточек как строку
    card_ids_str = ",".join(map(str, phrase_data.card_ids))
    
    phrase = Phrase(
        name=phrase_data.name,
        card_ids=card_ids_str,
        user_id=current_user.id
    )
    session.add(phrase)
    await session.commit()
    await session.refresh(phrase)
    
    # Возвращаем с преобразованием card_ids обратно в список
    return PhraseResponse(
        id=phrase.id,
        name=phrase.name,
        card_ids=phrase_data.card_ids,
        user_id=phrase.user_id,
        usage_count=phrase.usage_count,
        created_at=phrase.created_at
    )


@app.get("/phrases", response_model=PhraseListResponse)
async def get_phrases(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Получить все фразы пользователя"""
    result = await session.execute(
        select(Phrase)
        .where(Phrase.user_id == current_user.id)
        .order_by(Phrase.usage_count.desc(), Phrase.created_at.desc())
    )
    phrases = result.scalars().all()
    
    phrase_responses = []
    for phrase in phrases:
        card_ids = [int(x) for x in phrase.card_ids.split(",") if x]
        phrase_responses.append(PhraseResponse(
            id=phrase.id,
            name=phrase.name,
            card_ids=card_ids,
            user_id=phrase.user_id,
            usage_count=phrase.usage_count,
            created_at=phrase.created_at
        ))
    
    return PhraseListResponse(phrases=phrase_responses, total=len(phrase_responses))


@app.get("/phrases/{phrase_id}", response_model=PhraseWithCardsResponse)
async def get_phrase(
    phrase_id: int,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Получить фразу с полными данными карточек"""
    result = await session.execute(
        select(Phrase).where(Phrase.id == phrase_id, Phrase.user_id == current_user.id)
    )
    phrase = result.scalar_one_or_none()
    
    if not phrase:
        raise HTTPException(status_code=404, detail="Phrase not found")
    
    # Получаем карточки
    card_ids = [int(x) for x in phrase.card_ids.split(",") if x]
    cards = []
    for card_id in card_ids:
        result = await session.execute(select(Card).where(Card.id == card_id))
        card = result.scalar_one_or_none()
        if card:
            cards.append(card)
    
    return PhraseWithCardsResponse(
        id=phrase.id,
        name=phrase.name,
        cards=cards,
        usage_count=phrase.usage_count,
        created_at=phrase.created_at
    )


@app.post("/phrases/{phrase_id}/use", response_model=PhraseResponse)
async def use_phrase(
    phrase_id: int,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Использовать фразу (увеличить счётчик)"""
    result = await session.execute(
        select(Phrase).where(Phrase.id == phrase_id, Phrase.user_id == current_user.id)
    )
    phrase = result.scalar_one_or_none()
    
    if not phrase:
        raise HTTPException(status_code=404, detail="Phrase not found")
    
    phrase.usage_count += 1
    await session.commit()
    await session.refresh(phrase)
    
    card_ids = [int(x) for x in phrase.card_ids.split(",") if x]
    return PhraseResponse(
        id=phrase.id,
        name=phrase.name,
        card_ids=card_ids,
        user_id=phrase.user_id,
        usage_count=phrase.usage_count,
        created_at=phrase.created_at
    )


@app.post("/phrases/{phrase_id}/speak", response_model=TTSResponse)
async def speak_phrase(
    phrase_id: int,
    language: str = Query("ru", description="Язык озвучки: ru, kk, en"),
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Озвучить всю фразу"""
    result = await session.execute(
        select(Phrase).where(Phrase.id == phrase_id, Phrase.user_id == current_user.id)
    )
    phrase = result.scalar_one_or_none()
    
    if not phrase:
        raise HTTPException(status_code=404, detail="Phrase not found")
    
    # Собираем слова из карточек
    card_ids = [int(x) for x in phrase.card_ids.split(",") if x]
    words = []
    for card_id in card_ids:
        result = await session.execute(select(Card).where(Card.id == card_id))
        card = result.scalar_one_or_none()
        if card:
            words.append(card.word)
    
    # Озвучиваем
    text = " ".join(words)
    audio_base64 = await text_to_speech(text, language)
    
    return TTSResponse(audio_base64=audio_base64)


@app.delete("/phrases/{phrase_id}")
async def delete_phrase(
    phrase_id: int,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Удалить фразу"""
    result = await session.execute(
        select(Phrase).where(Phrase.id == phrase_id, Phrase.user_id == current_user.id)
    )
    phrase = result.scalar_one_or_none()
    
    if not phrase:
        raise HTTPException(status_code=404, detail="Phrase not found")
    
    await session.delete(phrase)
    await session.commit()
    
    return {"status": "deleted", "id": phrase_id}