from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import SecretStr

class Settings(BaseSettings):
    admin_email: str
    DATABASE_URL: str

    model_config = SettingsConfigDict(
        env_file=".env",
        extra="ignore",        # ignore les variables .env non définies dans Settings
        case_sensitive=False, # variables non sensibles à la casse
    )
    
settings = Settings()
