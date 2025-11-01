from typing import Annotated

from fastapi import APIRouter, Depends, Path, HTTPException
from pydantic import BaseModel, field_validator, model_validator
from sqlmodel import Session, select

from backend.reviews.models import Review
from backend.session import get_session

router = APIRouter(prefix="/reviews", tags=["reviews"])


class ReviewRead(BaseModel):
    id: int
    title: str
    content: str
    rating: int


class ReviewCreate(BaseModel):
    title: str
    content: str
    rating: int

    @field_validator("rating", mode="after")
    def validate_rating(cls, value: int) -> int:
        if 1 <= value <= 5:
            return value
        else:
            raise ValueError("invalid rating")

    @model_validator(mode="after")
    def validate_text(self):
        if not any((self.title, self.content)) or len(self.title) <= 5 or len(self.content) <= 5:
            raise ValueError("title or content too short")
        return self


@router.post("/", response_model=ReviewRead)
def add_review(input_data: ReviewCreate, session: Session = Depends(get_session)):
    review = Review(**input_data.model_dump())
    session.add(review)
    session.commit()
    session.refresh(review)
    return review


@router.get("/", response_model=list[ReviewRead])
def get_all_reviews(session: Session = Depends(get_session)):
    return list(session.exec(select(Review)).all())


@router.get("/{review_id}", response_model=ReviewRead)
def get_review_by_id(
    review_id: Annotated[int, Path(title="The ID of the review to get")],
    session: Session = Depends(get_session),
):
    review = session.exec(select(Review).where(Review.id.is_(review_id))).one_or_none()  # type: ignore
    if review is None:
        raise HTTPException(status_code=404, detail="not found")
    return review
