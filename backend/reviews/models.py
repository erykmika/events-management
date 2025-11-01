from typing import Optional, List
from sqlmodel import SQLModel, Field, Relationship


class Review(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    title: str = Field(..., min_length=10, max_length=255)
    content: str = Field(..., min_length=10, max_length=1024)
    rating: int = Field(ge=1, le=5)
    event_id: int = Field(foreign_key="event.id")

    event: Optional["Event"] = Relationship(back_populates="reviews")

    assets: List["ReviewAsset"] = Relationship(back_populates="review")


class ReviewAsset(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    url: str = Field(..., description="External resource link for this review (e.g. image, video, document)")
    review_id: int = Field(foreign_key="review.id")

    review: Optional[Review] = Relationship(back_populates="assets")
