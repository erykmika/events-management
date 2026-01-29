from fastapi import APIRouter
from logging import getLogger

logger = getLogger(__name__)

router = APIRouter(prefix="/minio", tags=["minio"])
