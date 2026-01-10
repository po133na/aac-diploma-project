from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    HUGGINGFACE_API_TOKEN: str
    SECRET_KEY: str = "your-secret-key-change-in-production-abc123xyz"

    class Config:
        env_file = ".env"


settings = Settings()