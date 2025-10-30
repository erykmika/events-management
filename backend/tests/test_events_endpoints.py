from datetime import datetime

from fastapi.testclient import TestClient
from sqlmodel import Session, SQLModel, create_engine

from backend.main import app
import backend.events.endpoints as events_endpoints


TEST_DB_URL = "sqlite:///:memory:"


def create_test_engine():
    return create_engine(TEST_DB_URL, connect_args={"check_same_thread": False})


def setup_test_client():
    engine = create_test_engine()
    # Create tables for all SQLModel models
    SQLModel.metadata.create_all(engine)

    def get_test_session():
        with Session(engine) as session:
            yield session

    app.dependency_overrides[events_endpoints.get_session] = get_test_session
    client = TestClient(app)
    return client, engine


def teardown_test_client(client):
    # Remove dependency override
    app.dependency_overrides.pop(events_endpoints.get_session, None)
    client.close()


def test_create_get_list_and_get_by_id():
    client, engine = setup_test_client()

    payload = {
        "title": "Test Event",
        "description": "A test event",
        "date": "2025-12-01T09:00:00",
        "location": "Test Hall",
        "organizer": "QA Team",
        "max_participants": 42,
    }

    # Create event
    r = client.post("/events/", json=payload)
    assert r.status_code == 200, r.text
    created = r.json()
    assert created["id"] is not None
    assert created["title"] == payload["title"]
    assert created["description"] == payload["description"]

    event_id = created["id"]

    # List events
    r = client.get("/events/")
    assert r.status_code == 200, r.text
    items = r.json()
    assert isinstance(items, list)
    assert any(item["id"] == event_id for item in items)

    # Get by id
    r = client.get(f"/events/{event_id}")
    assert r.status_code == 200, r.text
    item = r.json()
    assert item["id"] == event_id
    assert item["title"] == payload["title"]

    teardown_test_client(client)
