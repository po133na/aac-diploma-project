from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean, ForeignKey
from sqlalchemy.orm import relationship, declarative_base
from datetime import datetime

Base = declarative_base()


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    username = Column(String(100), nullable=False)
    hashed_password = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    cards = relationship("Card", back_populates="owner")


class Category(Base):
    __tablename__ = "categories"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)  # Название на русском
    name_kk = Column(String(100), nullable=True)  # Название на казахском
    name_en = Column(String(100), nullable=True)  # Название на английском
    icon = Column(String(50), nullable=True)  # Иконка (emoji или название)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)  # None = системная категория
    created_at = Column(DateTime, default=datetime.utcnow)

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
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    created_at = Column(DateTime, default=datetime.utcnow)

    category = relationship("Category", back_populates="cards")
    owner = relationship("User", back_populates="cards")