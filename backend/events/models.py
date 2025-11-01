from datetime import datetime
from typing import Optional

from sqlmodel import SQLModel, Field, Relationship


class Event(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    title: str
    description: str
    date: datetime
    location: str
    organizer: str
    max_participants: Optional[int] = None

    reviews: list["Review"] = Relationship(back_populates="event")  # noqa
