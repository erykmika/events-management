import logging

from starlette.middleware.cors import CORSMiddleware

from backend.settings import get_settings
from fastapi import FastAPI, APIRouter

from .events.endpoints import router as events_router
from .reviews.endpoints import router as reviews_router

app = FastAPI()

settings = get_settings()
logging.basicConfig(level=settings.LOGGING_LEVEL)

api_router = APIRouter(prefix="/api")

api_router.include_router(events_router)
api_router.include_router(reviews_router)

app.include_router(api_router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://localhost:3000",
        "http://events-management-alb-1002585781.us-east-1.elb.amazonaws.com/",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def root():
    return {"message": "Hello World"}
