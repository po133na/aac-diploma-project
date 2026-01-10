from pydantic import BaseModel
from datetime import datetime
from typing import Optional, Literal


# === Генерация изображений (старое) ===
class GenerationRequest(BaseModel):
    prompt: str
    negative_prompt: Optional[str] = None


class GenerationResponse(BaseModel):
    image_url: str
    created_at: datetime


# === Карточки AAC ===
class CardCreate(BaseModel):
    word: str
    language: Literal["ru", "kk"] = "ru"  # русский или казахский


class CardResponse(BaseModel):
    id: int
    word: str
    language: str
    translated_word: str
    image_base64: str
    created_at: datetime

    class Config:
        from_attributes = True


class CardListResponse(BaseModel):
    cards: list[CardResponse]
    total: int