from fastapi import FastAPI, HTTPException, Depends, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from datetime import datetime, timedelta, date, timezone
from io import BytesIO
import asyncio
import base64
import secrets
from PIL import Image

from huggingface_hub import InferenceClient

from app.config import settings
from app.schemas import (
    UserCreate, UserLogin, UserResponse, UserUpdate, UserStatsResponse, Token,
    UserSettingsResponse, UserSettingsUpdate,
    CategoryCreate, CategoryResponse, CategoryListResponse,
    CategoryCoverUpload, CategoryCoverGenerateRequest,
    CardCreate, CardUpload, CardGenerateResponse, CardSave, CardUpdate, CardResponse, CardListResponse,
    TTSRequest, TTSResponse,
    PhraseCreate, PhraseResponse, PhraseListResponse, PhraseWithCardsResponse,
    ForgotPasswordRequest, ResetPasswordRequest, ChangePasswordRequest, MessageResponse,
    SyncResponse, DeletedItemResponse
)
from app.database import init_db, get_session
from app.models import User, Category, Card, Phrase, PasswordResetToken, UserSettings, DailyUsage, DeletedItem, UserCardUsage, DailyCardLog
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

async def _generate_image(prompt: str) -> str:
    """Запускает синхронный HF-клиент в thread pool, возвращает base64 PNG."""
    image = await asyncio.to_thread(
        hf_client.text_to_image,
        prompt,
        model="black-forest-labs/FLUX.1-schnell",
    )
    buffer = BytesIO()
    image.save(buffer, format="PNG")
    return base64.b64encode(buffer.getvalue()).decode("utf-8")


# Системный стиль для всех генерируемых карточек
IMAGE_STYLE_PROMPT = (
    "3D cartoon style, soft rounded shapes, volumetric with gentle drop shadows, "
    "pastel-colored background, neutral beige and soft color accents, "
    "autism-friendly low contrast palette, no bright or saturated colors, "
    "no small details, no text, simple and clean, square format, child-friendly AAC card"
)


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
    uid = current_user.id

    total_cards, user_card_uses = (await session.execute(
        select(func.count(Card.id), func.coalesce(func.sum(Card.usage_count), 0))
        .where(Card.user_id == uid)
    )).one()

    system_card_uses = (await session.execute(
        select(func.coalesce(func.sum(UserCardUsage.usage_count), 0))
        .where(UserCardUsage.user_id == uid)
    )).scalar()

    total_card_uses = user_card_uses + system_card_uses

    total_phrases, total_phrase_uses = (await session.execute(
        select(func.count(Phrase.id), func.coalesce(func.sum(Phrase.usage_count), 0))
        .where(Phrase.user_id == uid)
    )).one()

    # Топ пользовательских карточек
    user_top_rows = (await session.execute(
        select(Card.id, Card.word, Card.usage_count)
        .where(Card.user_id == uid)
        .order_by(Card.usage_count.desc())
        .limit(5)
    )).all()

    # Топ системных карточек для этого пользователя
    system_top_rows = (await session.execute(
        select(Card.id, Card.word, UserCardUsage.usage_count)
        .join(UserCardUsage, UserCardUsage.card_id == Card.id)
        .where(UserCardUsage.user_id == uid)
        .order_by(UserCardUsage.usage_count.desc())
        .limit(5)
    )).all()

    all_top = sorted(
        [{"id": r[0], "word": r[1], "usage_count": r[2]} for r in user_top_rows + system_top_rows],
        key=lambda x: x["usage_count"],
        reverse=True
    )[:5]
    top_cards = all_top

    top_phrases_rows = (await session.execute(
        select(Phrase.id, Phrase.name, Phrase.usage_count)
        .where(Phrase.user_id == uid)
        .order_by(Phrase.usage_count.desc())
        .limit(5)
    )).all()
    top_phrases = [{"id": r[0], "name": r[1], "usage_count": r[2]} for r in top_phrases_rows]

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
        total_cards=total_cards,
        total_phrases=total_phrases,
        total_card_uses=total_card_uses,
        total_phrase_uses=total_phrase_uses,
        top_cards=top_cards,
        top_phrases=top_phrases,
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
    
    session.add(DeletedItem(entity_type="category", entity_id=category_id, user_id=current_user.id))
    await session.delete(category)
    await session.commit()
    return {"status": "deleted", "id": category_id}


@app.post("/categories/{category_id}/cover", response_model=CategoryResponse)
async def upload_category_cover(
    category_id: int,
    cover_data: CategoryCoverUpload,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Установить обложку категории из галереи или камеры (base64)"""
    result = await session.execute(
        select(Category).where(
            Category.id == category_id,
            Category.user_id == current_user.id
        )
    )
    category = result.scalar_one_or_none()

    if not category:
        raise HTTPException(status_code=404, detail="Category not found")

    category.cover_image_base64 = cover_data.image_base64
    await session.commit()
    await session.refresh(category)
    return category


@app.post("/categories/{category_id}/cover/generate", response_model=CategoryResponse)
async def generate_category_cover(
    category_id: int,
    body: CategoryCoverGenerateRequest,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Сгенерировать обложку категории через HuggingFace"""
    result = await session.execute(
        select(Category).where(
            Category.id == category_id,
            Category.user_id == current_user.id
        )
    )
    category = result.scalar_one_or_none()

    if not category:
        raise HTTPException(status_code=404, detail="Category not found")

    subject = body.prompt if body.prompt else (category.name_en or category.name)

    try:
        category.cover_image_base64 = await _generate_image(f"{subject}, {IMAGE_STYLE_PROMPT}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    await session.commit()
    await session.refresh(category)
    return category


# ==================== КАРТОЧКИ ====================

async def _get_or_create_generated_category(session: AsyncSession, user_id: int) -> Category:
    """Возвращает категорию 'Generated' пользователя, создаёт если нет."""
    result = await session.execute(
        select(Category).where(
            Category.name_en == "Generated",
            Category.user_id == user_id
        )
    )
    category = result.scalar_one_or_none()
    if not category:
        category = Category(
            name="Сгенерированные",
            name_kk="Жасалған",
            name_en="Generated",
            icon="🤖",
            user_id=user_id,
        )
        session.add(category)
        await session.flush()
    return category


@app.post("/cards/generate", response_model=CardResponse)
async def generate_card(
    card_data: CardCreate,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Генерирует изображение и сразу сохраняет в категорию Generated.
    iOS удаляет карточку если юзер отклонил, или переносит в нужную категорию если принял."""
    try:
        translated = await translate_to_english(card_data.word, card_data.language)
        image_base64 = await _generate_image(f"{translated}, {IMAGE_STYLE_PROMPT}")

        generated_cat = await _get_or_create_generated_category(session, current_user.id)
        target_category_id = card_data.category_id if card_data.category_id else generated_cat.id

        card = Card(
            word=card_data.word,
            language=card_data.language,
            translated_word=translated,
            image_base64=image_base64,
            category_id=target_category_id,
            user_id=current_user.id,
        )
        session.add(card)
        await session.commit()
        await session.refresh(card)
        return card

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
        image_base64 = await _generate_image(f"{translated}, {IMAGE_STYLE_PROMPT}")

        # 3. Сохранение в БД
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
    limit: int = Query(50, ge=1, le=200, description="Количество карточек"),
    offset: int = Query(0, ge=0, description="Смещение для пагинации"),
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Получить карточки пользователя с фильтрами (включая системные)"""
    base_filter = (Card.user_id == current_user.id) | (Card.user_id == None)

    count_query = select(func.count()).select_from(Card).where(base_filter)
    query = select(Card).where(base_filter)

    if category_id:
        query = query.where(Card.category_id == category_id)
        count_query = count_query.where(Card.category_id == category_id)

    if favorites_only:
        query = query.where(Card.is_favorite == True)
        count_query = count_query.where(Card.is_favorite == True)

    if search:
        query = query.where(Card.word.ilike(f"%{search}%"))
        count_query = count_query.where(Card.word.ilike(f"%{search}%"))

    total = (await session.execute(count_query)).scalar()
    query = query.order_by(Card.usage_count.desc(), Card.created_at.desc()).limit(limit).offset(offset)

    result = await session.execute(query)
    cards = result.scalars().all()

    return CardListResponse(cards=cards, total=total)


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
    
    if card_data.word is not None:
        card.word = card_data.word

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

    if card.user_id is not None:
        # Пользовательская карточка — обновляем счётчик напрямую
        card.usage_count += 1
    else:
        # Системная карточка — трекаем использование per-user
        usage_result = await session.execute(
            select(UserCardUsage).where(
                UserCardUsage.user_id == current_user.id,
                UserCardUsage.card_id == card_id
            )
        )
        user_card_usage = usage_result.scalar_one_or_none()
        if user_card_usage:
            user_card_usage.usage_count += 1
        else:
            session.add(UserCardUsage(user_id=current_user.id, card_id=card_id, usage_count=1))

    # Трекаем ежедневное использование — только уникальные карточки в день
    today = date.today()
    already_used_today = (await session.execute(
        select(DailyCardLog).where(
            DailyCardLog.user_id == current_user.id,
            DailyCardLog.date == today,
            DailyCardLog.card_id == card_id
        )
    )).scalar_one_or_none()

    if not already_used_today:
        session.add(DailyCardLog(user_id=current_user.id, date=today, card_id=card_id))
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
    
    session.add(DeletedItem(entity_type="card", entity_id=card_id, user_id=current_user.id))
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
    # Проверяем что все карточки принадлежат пользователю — одним запросом
    found_result = await session.execute(
        select(Card.id).where(
            Card.id.in_(phrase_data.card_ids),
            Card.user_id == current_user.id
        )
    )
    found_ids = {row[0] for row in found_result.all()}
    missing = set(phrase_data.card_ids) - found_ids
    if missing:
        raise HTTPException(status_code=404, detail=f"Cards not found: {sorted(missing)}")
    
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
    
    session.add(DeletedItem(entity_type="phrase", entity_id=phrase_id, user_id=current_user.id))
    await session.delete(phrase)
    await session.commit()
    return {"status": "deleted", "id": phrase_id}


# ==================== СИНХРОНИЗАЦИЯ ====================

@app.get("/sync", response_model=SyncResponse)
async def sync(
    since: datetime = Query(..., description="ISO8601 timestamp последней синхронизации"),
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """
    Возвращает всё что изменилось после `since`.
    iOS вызывает при запуске/восстановлении сети.
    Ответ содержит изменённые объекты и список удалённых ID.
    """
    uid = current_user.id

    # Карточки: пользовательские + системные изменённые после since
    cards_result = await session.execute(
        select(Card).where(
            ((Card.user_id == uid) | (Card.user_id == None)),
            Card.updated_at > since
        )
    )
    cards = cards_result.scalars().all()

    # Категории: пользовательские + системные изменённые после since
    cats_result = await session.execute(
        select(Category).where(
            ((Category.user_id == uid) | (Category.user_id == None)),
            Category.updated_at > since
        )
    )
    categories = cats_result.scalars().all()

    # Фразы пользователя изменённые после since
    phrases_result = await session.execute(
        select(Phrase).where(
            Phrase.user_id == uid,
            Phrase.updated_at > since
        )
    )
    raw_phrases = phrases_result.scalars().all()

    phrases = [
        PhraseResponse(
            id=p.id,
            name=p.name,
            card_ids=[int(x) for x in p.card_ids.split(",") if x],
            user_id=p.user_id,
            usage_count=p.usage_count,
            created_at=p.created_at,
            updated_at=p.updated_at,
        )
        for p in raw_phrases
    ]

    # Удалённые объекты пользователя после since
    deleted_result = await session.execute(
        select(DeletedItem).where(
            DeletedItem.user_id == uid,
            DeletedItem.deleted_at > since
        )
    )
    deleted = [
        DeletedItemResponse(
            entity_type=d.entity_type,
            entity_id=d.entity_id,
            deleted_at=d.deleted_at,
        )
        for d in deleted_result.scalars().all()
    ]

    return SyncResponse(
        cards=cards,
        categories=categories,
        phrases=phrases,
        deleted=deleted,
        synced_at=datetime.now(timezone.utc),
    )