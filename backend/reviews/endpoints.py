import uuid
import json
from typing import Annotated, List

from fastapi import APIRouter, Depends, Path, HTTPException, UploadFile
from pydantic import BaseModel, model_validator, field_validator
from sqlmodel import Session, select
import boto3

from backend.events.models import Event
from backend.reviews.models import Review, ReviewAsset
from backend.s3 import generate_presigned_url, upload_to_s3, get_bucket_name
from backend.session import get_session
from backend.settings import get_settings

router = APIRouter(prefix="/reviews", tags=["reviews"])

from logging import getLogger

logger = getLogger(__name__)


class ReviewRead(BaseModel):
    id: int
    title: str
    content: str
    rating: int
    event_id: int


class ReviewCreate(BaseModel):
    title: str
    content: str
    rating: int
    event_id: int

    @field_validator("rating", mode="after")
    def validate_rating(cls, value: int) -> int:
        if 1 <= value <= 5:
            return value
        raise ValueError("invalid rating")

    @model_validator(mode="after")
    def validate_text(self):
        if (
            not any((self.title, self.content))
            or len(self.title) <= 5
            or len(self.content) <= 5
        ):
            raise ValueError("title or content too short")
        return self


class ReviewAssetRead(BaseModel):
    id: int
    url: str
    review_id: int


@router.post("/", response_model=ReviewRead)
def add_review(input_data: ReviewCreate, session: Session = Depends(get_session)):
    # Ensure the event exists
    event = session.get(Event, input_data.event_id)
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")

    review = Review(**input_data.model_dump())
    session.add(review)
    session.commit()
    session.refresh(review)
    return review


@router.get("/", response_model=List[ReviewRead])
def get_all_reviews(session: Session = Depends(get_session)):
    return list(session.exec(select(Review)).all())


@router.get("/{review_id}", response_model=ReviewRead)
def get_review_by_id(
    review_id: Annotated[int, Path(title="The ID of the review to get")],
    session: Session = Depends(get_session),
):
    review = session.get(Review, review_id)
    if not review:
        raise HTTPException(status_code=404, detail="Review not found")
    return review


@router.get("/event/{event_id}", response_model=List[ReviewRead])
def get_reviews_for_event(event_id: int, session: Session = Depends(get_session)):
    event = session.get(Event, event_id)
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    return event.reviews


@router.post("/{review_id}/assets", response_model=ReviewAssetRead)
def add_review_asset(
    review_id: int, asset_data: UploadFile, session: Session = Depends(get_session)
):
    review = session.get(Review, review_id)
    if not review:
        raise HTTPException(status_code=404, detail="Review not found")

    key = f"{uuid.uuid4()}_{asset_data.filename}"

    # Upload to S3
    upload_to_s3(file=asset_data.file, key=key)

    # Invoke Lambda function to process the image
    try:
        lambda_client = boto3.client("lambda")
        payload = {
            "Records": [
                {
                    "s3": {
                        "bucket": {"name": get_bucket_name()},
                        "object": {"key": key},
                    }
                }
            ]
        }
        logger.info(f"Invoking Lambda with payload: {payload}")
        response = lambda_client.invoke(
            FunctionName=get_settings().LAMBDA_ARN,
            InvocationType="Event",
            Payload=json.dumps(payload),
        )
        logger.info(
            f"Lambda invoked successfully with status code: {response['StatusCode']}"
        )
    except Exception as e:
        logger.error(f"Failed to invoke Lambda: {e}")
        raise HTTPException(status_code=500, detail="Failed to process image")

    # Store asset record in database
    asset = ReviewAsset(url=key, review_id=review_id)
    session.add(asset)
    session.commit()
    session.refresh(asset)
    return asset


@router.get("/{review_id}/assets", response_model=List[ReviewAssetRead])
def get_assets_for_review(review_id: int, session: Session = Depends(get_session)):
    review = session.get(Review, review_id)
    if not review:
        raise HTTPException(status_code=404, detail="Review not found")

    assets_with_urls = []
    for asset in review.assets:
        presigned_url = generate_presigned_url(asset.url)
        assets_with_urls.append(
            ReviewAssetRead(id=asset.id, review_id=asset.review_id, url=presigned_url)
        )
    return assets_with_urls


@router.get("/assets/{asset_id}", response_model=ReviewAssetRead)
def get_asset_by_id(asset_id: int, session: Session = Depends(get_session)):
    asset = session.get(ReviewAsset, asset_id)
    if not asset:
        raise HTTPException(status_code=404, detail="Asset not found")

    presigned_url = generate_presigned_url(asset.url)
    return ReviewAssetRead(id=asset.id, review_id=asset.review_id, url=presigned_url)
