import logging
from app.core.config import settings
from app.services.ai.base import AIServiceBase
from app.services.ai.grok_service import GrokAIService
from app.services.ai.gemini_service import GeminiAIService
from app.services.ai.mock_ai_service import MockAIService

logger = logging.getLogger(__name__)

def get_ai_service() -> AIServiceBase:
    """Return configured AI Service. Defaults to Grok or Gemini if key is available, else mock."""
    grok_key = settings.effective_grok_key
    gemini_key = settings.GEMINI_API_KEY
    if grok_key and len(grok_key.strip()) > 5:
        logger.info(f"Using Grok (xAI) AI Service with model {settings.GROK_MODEL}")
        return GrokAIService(api_key=grok_key, model=settings.GROK_MODEL, base_url=settings.GROK_BASE_URL)
    elif gemini_key and len(gemini_key.strip()) > 5:
        logger.info("Using Google Gemini AI Service")
        return GeminiAIService(api_key=gemini_key)
    else:
        logger.info("No LLM API key found in environment (.env). Initializing high-fidelity dynamic MockAIService for local engine.")
        return MockAIService()

