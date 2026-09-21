from typing import Optional
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "IntervueX Backend"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # AI Provider: 'grok', 'gemini', or 'mock'
    AI_PROVIDER: str = "grok"
    
    # xAI / Grok API Keys & Base URL
    GROK_API_KEY: Optional[str] = None
    XAI_API_KEY: Optional[str] = None
    GROK_BASE_URL: str = "https://api.x.ai/v1"
    GROK_MODEL: str = "grok-2-latest"
    
    # Gemini API Key (optional alternative)
    GEMINI_API_KEY: Optional[str] = None
    
    # Supabase configuration (optional in dev mode)
    SUPABASE_URL: Optional[str] = None
    SUPABASE_ANON_KEY: Optional[str] = None
    SUPABASE_SERVICE_ROLE_KEY: Optional[str] = None
    
    # CORS
    BACKEND_CORS_ORIGINS: list[str] = ["*"]
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )

    @property
    def effective_grok_key(self) -> Optional[str]:
        return self.GROK_API_KEY or self.XAI_API_KEY

settings = Settings()
