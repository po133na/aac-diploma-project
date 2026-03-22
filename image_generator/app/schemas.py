from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional, Literal


# === Пользователи ===
class UserCreate(BaseModel):
    email: EmailStr
    username: str
    password: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    id: int
    email: str
    username: str
    avatar_base64: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    username: Optional[str] = None
    email: Optional[EmailStr] = None
    avatar_base64: Optional[str] = None


class UserStatsResponse(BaseModel):
    total_cards: int
    total_phrases: int
    total_card_uses: int
    total_phrase_uses: int
    top_cards: list[dict]
    top_phrases: list[dict]
    member_since: datetime
    this_week_cards: int
    current_streak: int


class UserSettingsResponse(BaseModel):
    voice: str
    language: str
    appearance: str
    grid_size: str

    class Config:
        from_attributes = True


class UserSettingsUpdate(BaseModel):
    voice: Optional[Literal["male", "female", "child"]] = None
    language: Optional[Literal["ru", "kk", "en"]] = None
    appearance: Optional[Literal["light", "dark", "auto"]] = None
    grid_size: Optional[Literal["standard", "large"]] = None


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


# === Сброс пароля ===
class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str


class ChangePasswordRequest(BaseModel):
    old_password: str
    new_password: str


class MessageResponse(BaseModel):
    message: str


# === Категории ===
class CategoryCreate(BaseModel):
    name: str
    name_kk: Optional[str] = None
    name_en: Optional[str] = None
    icon: Optional[str] = None


class CategoryResponse(BaseModel):
    id: int
    name: str
    name_kk: Optional[str]
    name_en: Optional[str]
    icon: Optional[str]
    user_id: Optional[int]
    created_at: datetime

    class Config:
        from_attributes = True


class CategoryListResponse(BaseModel):
    categories: list[CategoryResponse]
    total: int


# === Карточки ===
class CardCreate(BaseModel):
    word: str
    language: Literal["ru", "kk"] = "ru"
    category_id: Optional[int] = None


class CardUpload(BaseModel):
    word: str
    language: Literal["ru", "kk"] = "ru"
    category_id: Optional[int] = None
    image_base64: str  # base64 фото с камеры/галереи


class CardGenerateResponse(BaseModel):
    word: str
    language: str
    translated_word: str
    image_base64: str  # временная, ещё не сохранена


class CardSave(BaseModel):
    word: str
    language: Literal["ru", "kk"] = "ru"
    translated_word: str
    image_base64: str
    category_id: Optional[int] = None


class CardUpdate(BaseModel):
    is_favorite: Optional[bool] = None
    category_id: Optional[int] = None


class CardResponse(BaseModel):
    id: int
    word: str
    language: str
    translated_word: str
    image_base64: str
    is_favorite: bool
    usage_count: int
    category_id: Optional[int]
    user_id: int
    created_at: datetime

    class Config:
        from_attributes = True


class CardListResponse(BaseModel):
    cards: list[CardResponse]
    total: int


# === TTS (Text-to-Speech) ===
class TTSRequest(BaseModel):
    text: str
    language: Literal["ru", "kk", "en"] = "ru"


class TTSResponse(BaseModel):
    audio_base64: str
    format: str = "mp3"


# === Фразы ===
class PhraseCreate(BaseModel):
    name: str
    card_ids: list[int]  # [1, 5, 12, 8]


class PhraseResponse(BaseModel):
    id: int
    name: str
    card_ids: list[int]
    user_id: int
    usage_count: int
    created_at: datetime

    class Config:
        from_attributes = True


class PhraseListResponse(BaseModel):
    phrases: list[PhraseResponse]
    total: int


class PhraseWithCardsResponse(BaseModel):
    id: int
    name: str
    cards: list[CardResponse]  # Полные данные карточек
    usage_count: int
    created_at: datetime