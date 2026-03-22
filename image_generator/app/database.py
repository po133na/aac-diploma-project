from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text
from app.models import Base
from app.config import settings

engine = create_async_engine(settings.DATABASE_URL, echo=False)

async_session = sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)


async def init_db():
    async with engine.begin() as conn:
        for table in Base.metadata.sorted_tables:
            try:
                await conn.run_sync(lambda c, t=table: t.create(c, checkfirst=True))
            except Exception:
                pass  # таблица или sequence уже существуют


async def get_session() -> AsyncSession:
    async with async_session() as session:
        yield session