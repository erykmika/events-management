
def test_create_get_list_and_get_by_id(test_client):
    client, engine = test_client

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
    assert item["organizer"] == payload["organizer"]