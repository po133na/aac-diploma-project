from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    HUGGINGFACE_API_TOKEN: str

    class Config:
        env_file = ".env"


settings = Settings()