from sqlmodel import SQLModel, Field


class Review(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    title: str = Field(..., min_length=10, max_length=255)
    content: str = Field(..., min_length=10, max_length=1024)
    rating: int = Field(ge=1, le=5)
