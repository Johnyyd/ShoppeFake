from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DB_SERVER: str = "localhost"
    DB_PORT: int = 1433
    DB_USER: str = "sa"
    DB_PASSWORD: str = "SuperSecurePass123!"
    DB_NAME: str = "ShoppeDB"
    
    # Use sqlite in-memory or file for test fallback/testing environment if configured
    USE_TEST_SQLITE: bool = False
    
    JWT_SECRET_KEY: str = "super-secret-dopamine-key-change-in-prod-2026"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440

    class Config:
        env_file = ".env"
        extra = "ignore"

settings = Settings()
