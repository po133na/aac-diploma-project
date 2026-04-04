from pydantic_settings import BaseSettings
from pydantic import ConfigDict


class Settings(BaseSettings):
    model_config = ConfigDict(env_file=".env", extra="ignore")

    HUGGINGFACE_API_TOKEN: str
    GOOGLE_API_KEY: str = ""
    SECRET_KEY: str
    DATABASE_URL: str = "sqlite+aiosqlite:///./cards.db"


settings = Settings()