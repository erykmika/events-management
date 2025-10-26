import logging
from backend.config import get_settings
from fastapi import FastAPI

app = FastAPI()

settings = get_settings()
logging.basicConfig(level=settings.LOGGING_LEVEL)


@app.get("/")
async def root():
    return {"message": "Hello World"}
