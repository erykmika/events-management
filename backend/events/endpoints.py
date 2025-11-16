from datetime import datetime

from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from sqlmodel import Session, select

from .models import Event
from ..session import get_session

router = APIRouter(prefix="/events", tags=["events"])


class EventCreate(BaseModel):
    title: str
    description: str
    date: datetime
    location: str
    organizer: str
    max_participants: int | None


class EventRead(EventCreate):
    id: int | None
    title: str
    description: str
    date: datetime
    location: str
    organizer: str
    max_participants: int | None


# todo: implement separation of concerns - db read/write and endpoints


@router.get("/", response_model=list[EventRead])
async def get_events(session: Session = Depends(get_session)):
    """Get a list of all events"""
    statement = select(Event).order_by(Event.date)
    events = session.exec(statement).all()
    return [EventRead(**e.model_dump()) for e in events]


@router.get("/{event_id}", response_model=EventRead)
async def get_event(event_id: int, session: Session = Depends(get_session)):
    """Get an event by its ID"""
    event: Event | None = session.exec(select(Event).where(Event.id == event_id)).one_or_none()  # type: ignore
    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")
    return EventRead(**event.model_dump())


@router.post("/", response_model=EventRead)
async def create_event(event: EventCreate, session: Session = Depends(get_session)):
    """Create a new event"""
    db_event = Event(**event.model_dump())
    session.add(db_event)
    session.commit()
    session.refresh(db_event)
    return db_event
