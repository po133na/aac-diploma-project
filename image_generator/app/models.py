from sqlalchemy import Column, Integer, String, Text, DateTime
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

Base = declarative_base()


class Card(Base):
    __tablename__ = "cards"

    id = Column(Integer, primary_key=True, index=True)
    word = Column(String(255), nullable=False)  # Оригинальное слово (рус/каз)
    language = Column(String(10), nullable=False)  # "ru" или "kk"
    translated_word = Column(String(255), nullable=False)  # Перевод на английский
    image_base64 = Column(Text, nullable=False)  # Base64 изображение
    created_at = Column(DateTime, default=datetime.utcnow)