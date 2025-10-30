from datetime import datetime
from fastapi import APIRouter, HTTPException, Depends
from sqlmodel import Session, select
from ..db import engine
from .models import Event


router = APIRouter(prefix="/events", tags=["events"])


def get_session():
    with Session(engine) as session:
        yield session


@router.get("/", response_model=list[Event])
async def get_events(session: Session = Depends(get_session)):
    """Get a list of all events"""
    statement = select(Event).order_by(Event.date)
    events = session.exec(statement).all()
    return events


@router.get("/{event_id}", response_model=Event)
async def get_event(event_id: int, session: Session = Depends(get_session)):
    """Get an event by its ID"""
    event = session.get(Event, event_id)
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    return event


@router.post("/", response_model=Event)
async def create_event(event: Event, session: Session = Depends(get_session)):
    """Create a new event"""
    db_event = Event.from_orm(event)
    session.add(db_event)
    session.commit()
    session.refresh(db_event)
    return db_event
