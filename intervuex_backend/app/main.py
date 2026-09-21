import logging
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from app.core.config import settings
from app.api.v1.api import api_router

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s")
logger = logging.getLogger("intervuex")

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="IntervueX Backend - High-Caliber AI Interview Preparation Engine with Grok xAI Provider",
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup_event():
    logger.info("==================================================")
    logger.info(" Starting IntervueX Backend Engine")
    logger.info(f" Version: {settings.VERSION}")
    grok_key = settings.effective_grok_key
    if grok_key and len(grok_key.strip()) > 5:
        logger.info(f" AI Provider: Grok xAI ({settings.GROK_MODEL}) [ACTIVE]")
    else:
        logger.info(" AI Provider: MockAIService (Zero-Setup Dev & Offline Mode) [ACTIVE]")
        logger.info(" Tip: Set GROK_API_KEY in .env to connect directly to xAI's Grok API.")
    logger.info("==================================================")

@app.get("/")
async def root():
    return {
        "brand": "IntervueX",
        "tagline": "Your Personal AI Interview Preparation Coach",
        "status": "online",
        "version": settings.VERSION,
        "docs": "/docs"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "intervuex-backend"}

# Mount V1 APIs
app.include_router(api_router, prefix=settings.API_V1_STR)

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Global error on {request.url.path}: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"detail": "An internal error occurred in the IntervueX engine. Please try again."}
    )
