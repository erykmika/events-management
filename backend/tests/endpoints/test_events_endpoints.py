import pytest


@pytest.mark.parametrize(
    "payload",
    [
        {
            "title": "Tech Conference 2025",
            "description": "A technology conference for professionals.",
            "date": "2025-12-01T09:00:00",
            "location": "Innovation Center",
            "organizer": "Tech Corp",
            "max_participants": 100,
        },
        {
            "title": "Music Festival",
            "description": "An exciting music festival with local artists.",
            "date": "2025-07-15T18:00:00",
            "location": "City Park",
            "organizer": "City Events",
            "max_participants": 500,
        },
        {
            "title": "Workshop: AI for Beginners",
            "description": "Hands-on workshop introducing AI concepts.",
            "date": "2025-03-10T10:00:00",
            "location": "Learning Hub",
            "organizer": "QA Team",
            "max_participants": 25,
        },
    ],
)
def test_create_get_list_and_get_by_id(test_client, payload):
    client, _ = test_client

    # --- Create event ---
    r = client.post("/api/events/", json=payload)
    assert r.status_code == 200, r.text
    created = r.json()
    assert created["id"] is not None
    assert created["title"] == payload["title"]
    assert created["description"] == payload["description"]

    event_id = created["id"]

    # --- List events ---
    r = client.get("/api/events/")
    assert r.status_code == 200, r.text
    items = r.json()
    assert isinstance(items, list)
    assert any(item["id"] == event_id for item in items)

    # --- Get by ID ---
    r = client.get(f"/api/events/{event_id}")
    assert r.status_code == 200, r.text
    item = r.json()
    assert item["id"] == event_id
    assert item["title"] == payload["title"]
    assert item["organizer"] == payload["organizer"]
