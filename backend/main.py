import logging
from backend.settings import get_settings
from fastapi import FastAPI
from .events.endpoints import router as events_router

app = FastAPI()

settings = get_settings()
logging.basicConfig(level=settings.LOGGING_LEVEL)

# Include routers
app.include_router(events_router)


@app.get("/")
async def root():
    return {"message": "Hello World"}
