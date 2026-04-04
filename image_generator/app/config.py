from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    HUGGINGFACE_API_TOKEN: str
    GOOGLE_API_KEY: str = ""
    SECRET_KEY: str
    DATABASE_URL: str = "sqlite+aiosqlite:///./cards.db"

    class Config:
        env_file = ".env"


settings = Settings()