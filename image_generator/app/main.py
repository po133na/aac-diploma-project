from fastapi import FastAPI, HTTPException, Depends, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from datetime import datetime, timedelta, date
from io import BytesIO
import base64
import secrets
from PIL import Image

from huggingface_hub import InferenceClient

from app.config import settings
from app.schemas import (
    UserCreate, UserLogin, UserResponse, UserUpdate, UserStatsResponse, Token,
    UserSettingsResponse, UserSettingsUpdate,
    CategoryCreate, CategoryResponse, CategoryListResponse,
    CardCreate, CardUpload, CardGenerateResponse, CardSave, CardUpdate, CardResponse, CardListResponse,
    TTSRequest, TTSResponse,
    PhraseCreate, PhraseResponse, PhraseListResponse, PhraseWithCardsResponse,
    ForgotPasswordRequest, ResetPasswordRequest, ChangePasswordRequest, MessageResponse
)
from app.database import init_db, get_session
from app.models import User, Category, Card, Phrase, PasswordResetToken, UserSettings, DailyUsage
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


def _make_card_image(color: tuple) -> str:
    """Создаёт простое цветное 100x100 PNG и возвращает base64"""
    img = Image.new("RGB", (100, 100), color=color)
    buf = BytesIO()
    img.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode("utf-8")


async def create_default_categories(session: AsyncSession):
    """Создаёт стандартные категории и системные карточки Basics если их нет"""
    result = await session.execute(select(Category).where(Category.user_id == None))
    categories_exist = result.first() is not None

    if not categories_exist:
        default_categories = [
            {"name": "Основы", "name_kk": "Негіздер", "name_en": "Basics", "icon": "✨"},
            {"name": "Еда", "name_kk": "Тамақ", "name_en": "Food", "icon": "🍎"},
            {"name": "Животные", "name_kk": "Жануарлар", "name_en": "Animals", "icon": "🐱"},
            {"name": "Действия", "name_kk": "Әрекеттер", "name_en": "Actions", "icon": "🏃"},
            {"name": "Эмоции", "name_kk": "Эмоциялар", "name_en": "Emotions", "icon": "😊"},
            {"name": "Семья", "name_kk": "Отбасы", "name_en": "Family", "icon": "👨‍👩‍👧"},
            {"name": "Места", "name_kk": "Орындар", "name_en": "Places", "icon": "🏠"},
            {"name": "Предметы", "name_kk": "Заттар", "name_en": "Objects", "icon": "📦"},
            {"name": "Цвета", "name_kk": "Түстер", "name_en": "Colors", "icon": "🎨"},
        ]
        basics_category = None
        for cat_data in default_categories:
            category = Category(**cat_data)
            session.add(category)
            if cat_data["name_en"] == "Basics":
                basics_category = category

        await session.flush()  # получаем ID категорий

        # Предзагружаем карточки для Basics (системные, user_id=None)
        basics_words = [
            ("I", (173, 216, 230)),
            ("You", (144, 238, 144)),
            ("Want", (255, 255, 153)),
            ("Need", (255, 200, 150)),
            ("Help", (255, 182, 193)),
            ("Yes", (144, 238, 144)),
            ("No", (255, 160, 160)),
            ("Please", (200, 160, 220)),
            ("Listen", (160, 220, 220)),
            ("Eat", (255, 255, 153)),
            ("Drink", (173, 216, 230)),
            ("Play", (144, 238, 144)),
            ("Sleep", (200, 160, 220)),
            ("Go", (255, 200, 150)),
            ("Read", (173, 216, 230)),
            ("Watch", (144, 238, 144)),
            ("Draw", (255, 182, 193)),
            ("Sing", (255, 255, 153)),
            ("Dance", (255, 200, 150)),
            ("Jump", (160, 220, 220)),
        ]
        for word, color in basics_words:
            card = Card(
                word=word,
                language="en",
                translated_word=word,
                image_base64=_make_card_image(color),
                category_id=basics_category.id,
                user_id=None,
            )
            session.add(card)

        await session.commit()

    else:
        # Категории уже есть — проверяем отдельно наличие Basics
        basics_result = await session.execute(
            select(Category).where(Category.name_en == "Basics", Category.user_id == None)
        )
        if basics_result.scalars().first() is None:
            basics_category = Category(
                name="Основы", name_kk="Негіздер", name_en="Basics", icon="✨"
            )
            session.add(basics_category)
            await session.flush()

            basics_words = [
                ("I", (173, 216, 230)), ("You", (144, 238, 144)),
                ("Want", (255, 255, 153)), ("Need", (255, 200, 150)),
                ("Help", (255, 182, 193)), ("Yes", (144, 238, 144)),
                ("No", (255, 160, 160)), ("Please", (200, 160, 220)),
                ("Listen", (160, 220, 220)), ("Eat", (255, 255, 153)),
                ("Drink", (173, 216, 230)), ("Play", (144, 238, 144)),
                ("Sleep", (200, 160, 220)), ("Go", (255, 200, 150)),
                ("Read", (173, 216, 230)), ("Watch", (144, 238, 144)),
                ("Draw", (255, 182, 193)), ("Sing", (255, 255, 153)),
                ("Dance", (255, 200, 150)), ("Jump", (160, 220, 220)),
            ]
            for word, color in basics_words:
                session.add(Card(
                    word=word, language="en", translated_word=word,
                    image_base64=_make_card_image(color),
                    category_id=basics_category.id, user_id=None,
                ))
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


@app.patch("/auth/me", response_model=UserResponse)
async def update_me(
    data: UserUpdate,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Обновить профиль пользователя (имя, email, аватар)"""
    if data.username is not None:
        current_user.username = data.username

    if data.email is not None:
        result = await session.execute(
            select(User).where(User.email == data.email, User.id != current_user.id)
        )
        if result.scalar_one_or_none():
            raise HTTPException(status_code=400, detail="Email already taken")
        current_user.email = data.email

    if data.avatar_base64 is not None:
        current_user.avatar_base64 = data.avatar_base64

    await session.commit()
    await session.refresh(current_user)
    return current_user


@app.get("/user/statistics", response_model=UserStatsResponse)
async def get_statistics(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Статистика пользователя"""
    cards_result = await session.execute(
        select(Card).where(Card.user_id == current_user.id)
    )
    cards = cards_result.scalars().all()

    phrases_result = await session.execute(
        select(Phrase).where(Phrase.user_id == current_user.id)
    )
    phrases = phrases_result.scalars().all()

    total_card_uses = sum(c.usage_count for c in cards)
    total_phrase_uses = sum(p.usage_count for p in phrases)

    top_cards = sorted(cards, key=lambda c: c.usage_count, reverse=True)[:5]
    top_phrases = sorted(phrases, key=lambda p: p.usage_count, reverse=True)[:5]

    # Статистика за последние 7 дней
    today = date.today()
    week_ago = today - timedelta(days=6)
    weekly_result = await session.execute(
        select(func.sum(DailyUsage.cards_used)).where(
            DailyUsage.user_id == current_user.id,
            DailyUsage.date >= week_ago
        )
    )
    this_week_cards = weekly_result.scalar() or 0

    # Стрик — количество последовательных дней с использованием
    daily_result = await session.execute(
        select(DailyUsage).where(
            DailyUsage.user_id == current_user.id,
            DailyUsage.cards_used > 0
        )
    )
    daily_records = daily_result.scalars().all()
    used_dates = {r.date for r in daily_records}

    streak = 0
    start = today if today in used_dates else today - timedelta(days=1)
    check = start
    while check in used_dates:
        streak += 1
        check -= timedelta(days=1)

    return UserStatsResponse(
        total_cards=len(cards),
        total_phrases=len(phrases),
        total_card_uses=total_card_uses,
        total_phrase_uses=total_phrase_uses,
        top_cards=[{"id": c.id, "word": c.word, "usage_count": c.usage_count} for c in top_cards],
        top_phrases=[{"id": p.id, "name": p.name, "usage_count": p.usage_count} for p in top_phrases],
        member_since=current_user.created_at,
        this_week_cards=this_week_cards,
        current_streak=streak,
    )


@app.post("/auth/forgot-password", response_model=MessageResponse)
async def forgot_password(
    data: ForgotPasswordRequest,
    session: AsyncSession = Depends(get_session)
):
    """Запрос на сброс пароля — генерирует токен"""
    result = await session.execute(select(User).where(User.email == data.email))
    user = result.scalar_one_or_none()
    
    if not user:
        # Не раскрываем, существует ли email
        return MessageResponse(message="If email exists, reset token has been generated")
    
    # Генерируем токен
    token = secrets.token_urlsafe(32)
    expires_at = datetime.utcnow() + timedelta(hours=1)
    
    reset_token = PasswordResetToken(
        user_id=user.id,
        token=token,
        expires_at=expires_at
    )
    session.add(reset_token)
    await session.commit()
    
    # В реальном приложении здесь отправка email
    # Для разработки возвращаем токен
    return MessageResponse(message=f"Reset token: {token}")


@app.post("/auth/reset-password", response_model=MessageResponse)
async def reset_password(
    data: ResetPasswordRequest,
    session: AsyncSession = Depends(get_session)
):
    """Сброс пароля по токену"""
    result = await session.execute(
        select(PasswordResetToken).where(
            PasswordResetToken.token == data.token,
            PasswordResetToken.used == False,
            PasswordResetToken.expires_at > datetime.utcnow()
        )
    )
    reset_token = result.scalar_one_or_none()
    
    if not reset_token:
        raise HTTPException(status_code=400, detail="Invalid or expired token")
    
    # Обновляем пароль
    result = await session.execute(select(User).where(User.id == reset_token.user_id))
    user = result.scalar_one_or_none()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    user.hashed_password = get_password_hash(data.new_password)
    reset_token.used = True
    
    await session.commit()
    
    return MessageResponse(message="Password successfully reset")


@app.post("/auth/change-password", response_model=MessageResponse)
async def change_password(
    data: ChangePasswordRequest,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Смена пароля (для авторизованного пользователя)"""
    if not verify_password(data.old_password, current_user.hashed_password):
        raise HTTPException(status_code=400, detail="Incorrect old password")
    
    current_user.hashed_password = get_password_hash(data.new_password)
    await session.commit()
    
    return MessageResponse(message="Password successfully changed")


@app.delete("/auth/me", response_model=MessageResponse)
async def delete_account(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Удалить аккаунт пользователя"""
    await session.delete(current_user)
    await session.commit()
    return MessageResponse(message="Account deleted")


@app.get("/user/settings", response_model=UserSettingsResponse)
async def get_settings(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Получить настройки пользователя"""
    result = await session.execute(
        select(UserSettings).where(UserSettings.user_id == current_user.id)
    )
    settings_obj = result.scalar_one_or_none()
    if not settings_obj:
        # Создаём дефолтные настройки
        settings_obj = UserSettings(user_id=current_user.id)
        session.add(settings_obj)
        await session.commit()
        await session.refresh(settings_obj)
    return settings_obj


@app.patch("/user/settings", response_model=UserSettingsResponse)
async def update_settings(
    data: UserSettingsUpdate,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Обновить настройки пользователя"""
    result = await session.execute(
        select(UserSettings).where(UserSettings.user_id == current_user.id)
    )
    settings_obj = result.scalar_one_or_none()
    if not settings_obj:
        settings_obj = UserSettings(user_id=current_user.id)
        session.add(settings_obj)

    if data.voice is not None:
        settings_obj.voice = data.voice
    if data.language is not None:
        settings_obj.language = data.language
    if data.appearance is not None:
        settings_obj.appearance = data.appearance
    if data.grid_size is not None:
        settings_obj.grid_size = data.grid_size

    await session.commit()
    await session.refresh(settings_obj)
    return settings_obj


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

@app.post("/cards/generate", response_model=CardGenerateResponse)
async def generate_card(
    card_data: CardCreate,
    current_user: User = Depends(get_current_user)
):
    """Сгенерировать изображение без сохранения — юзер сам решает сохранить или нет"""
    try:
        translated = await translate_to_english(card_data.word, card_data.language)

        prompt = f"simple illustration of {translated}, clear icon style, white background, child-friendly"
        image = hf_client.text_to_image(
            prompt=prompt,
            model="black-forest-labs/FLUX.1-schnell",
        )

        buffer = BytesIO()
        image.save(buffer, format="PNG")
        image_base64 = base64.b64encode(buffer.getvalue()).decode("utf-8")

        return CardGenerateResponse(
            word=card_data.word,
            language=card_data.language,
            translated_word=translated,
            image_base64=image_base64
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/cards/save", response_model=CardResponse)
async def save_card(
    card_data: CardSave,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Сохранить карточку после того как юзер одобрил сгенерированное изображение"""
    card = Card(
        word=card_data.word,
        language=card_data.language,
        translated_word=card_data.translated_word,
        image_base64=card_data.image_base64,
        category_id=card_data.category_id,
        user_id=current_user.id
    )
    session.add(card)
    await session.commit()
    await session.refresh(card)
    return card


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


@app.post("/cards/upload", response_model=CardResponse)
async def upload_card(
    card_data: CardUpload,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Создать карточку с загруженным фото (с камеры или галереи)"""
    try:
        translated = await translate_to_english(card_data.word, card_data.language)

        card = Card(
            word=card_data.word,
            language=card_data.language,
            translated_word=translated,
            image_base64=card_data.image_base64,
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
    """Получить карточки пользователя с фильтрами (включая системные)"""
    query = select(Card).where(
        (Card.user_id == current_user.id) | (Card.user_id == None)
    )
    
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
        select(Card).where(
            Card.id == card_id,
            (Card.user_id == current_user.id) | (Card.user_id == None)
        )
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
    """Увеличить счётчик использования карточки и записать в DailyUsage"""
    result = await session.execute(
        select(Card).where(
            Card.id == card_id,
            (Card.user_id == current_user.id) | (Card.user_id == None)
        )
    )
    card = result.scalar_one_or_none()

    if not card:
        raise HTTPException(status_code=404, detail="Card not found")

    # Увеличиваем счётчик только для пользовательских карточек
    if card.user_id is not None:
        card.usage_count += 1

    # Трекаем ежедневное использование
    today = date.today()
    daily_result = await session.execute(
        select(DailyUsage).where(
            DailyUsage.user_id == current_user.id,
            DailyUsage.date == today
        )
    )
    daily = daily_result.scalar_one_or_none()
    if daily:
        daily.cards_used += 1
    else:
        session.add(DailyUsage(user_id=current_user.id, date=today, cards_used=1))

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