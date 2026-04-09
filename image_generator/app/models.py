from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean, ForeignKey, Date
from sqlalchemy.orm import relationship, declarative_base
from datetime import datetime, timezone

def utcnow():
    return datetime.utcnow()

Base = declarative_base()


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    username = Column(String(100), nullable=False)
    hashed_password = Column(String(255), nullable=False)
    avatar_base64 = Column(Text, nullable=True)
    created_at = Column(DateTime, default=utcnow)

    cards = relationship("Card", back_populates="owner")
    phrases = relationship("Phrase", back_populates="owner")
    settings = relationship("UserSettings", back_populates="owner", uselist=False)


class Category(Base):
    __tablename__ = "categories"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)  # Название на русском
    name_kk = Column(String(100), nullable=True)  # Название на казахском
    name_en = Column(String(100), nullable=True)  # Название на английском
    icon = Column(String(50), nullable=True)  # Иконка (emoji или название)
    cover_image_base64 = Column(Text, nullable=True)  # Обложка категории
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)  # None = системная категория
    created_at = Column(DateTime, default=utcnow)
    updated_at = Column(DateTime, default=utcnow, onupdate=utcnow)

    cards = relationship("Card", back_populates="category")


class Card(Base):
    __tablename__ = "cards"

    id = Column(Integer, primary_key=True, index=True)
    word = Column(String(255), nullable=False)
    language = Column(String(10), nullable=False)
    translated_word = Column(String(255), nullable=False)
    image_base64 = Column(Text, nullable=False)
    is_favorite = Column(Boolean, default=False)
    usage_count = Column(Integer, default=0)  # Счётчик использований

    category_id = Column(Integer, ForeignKey("categories.id"), nullable=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)  # None = системная карточка

    created_at = Column(DateTime, default=utcnow)
    updated_at = Column(DateTime, default=utcnow, onupdate=utcnow)

    category = relationship("Category", back_populates="cards")
    owner = relationship("User", back_populates="cards")


class Phrase(Base):
    __tablename__ = "phrases"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    card_ids = Column(String(500), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    usage_count = Column(Integer, default=0)
    created_at = Column(DateTime, default=utcnow)
    updated_at = Column(DateTime, default=utcnow, onupdate=utcnow)

    owner = relationship("User", back_populates="phrases")


class DeletedItem(Base):
    """Лог удалённых объектов — чтобы iOS знал что удалить локально при синке"""
    __tablename__ = "deleted_items"

    id = Column(Integer, primary_key=True, index=True)
    entity_type = Column(String(20), nullable=False)   # "card", "category", "phrase"
    entity_id = Column(Integer, nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)  # None = системный объект
    deleted_at = Column(DateTime, default=utcnow, index=True)


class UserSettings(Base):
    __tablename__ = "user_settings"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    voice = Column(String(20), default="female")        # male, female, child
    language = Column(String(10), default="ru")         # ru, kk, en
    appearance = Column(String(10), default="auto")     # light, dark, auto
    grid_size = Column(String(10), default="standard")  # standard, large

    owner = relationship("User", back_populates="settings")


class DailyUsage(Base):
    __tablename__ = "daily_usage"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    date = Column(Date, nullable=False)
    cards_used = Column(Integer, default=0)

    owner = relationship("User")


class UserCardUsage(Base):
    """Трекинг использования системных карточек конкретным пользователем"""
    __tablename__ = "user_card_usage"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    card_id = Column(Integer, ForeignKey("cards.id"), nullable=False)
    usage_count = Column(Integer, default=1)

    user = relationship("User")
    card = relationship("Card")


class PasswordResetToken(Base):
    __tablename__ = "password_reset_tokens"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    token = Column(String(255), unique=True, nullable=False, index=True)
    expires_at = Column(DateTime, nullable=False)
    used = Column(Boolean, default=False)
    created_at = Column(DateTime, default=utcnow)

    user = relationship("User")