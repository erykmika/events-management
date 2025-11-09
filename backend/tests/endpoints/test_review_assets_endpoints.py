import pytest


@pytest.fixture
def event_and_review(test_client):
    """Helper fixture that creates a test event and a review for it."""
    client, _ = test_client

    # Create event
    event_payload = {
        "title": "Test Event for Assets",
        "description": "Event with assets testing",
        "date": "2025-12-01T09:00:00",
        "location": "Main Hall",
        "organizer": "QA Team",
        "max_participants": 50,
    }
    event_resp = client.post("/api/events/", json=event_payload)
    assert event_resp.status_code == 200, event_resp.text
    event = event_resp.json()

    # Create review
    review_payload = {
        "title": "Amazing Event!",
        "content": "Had a great time.",
        "rating": 5,
        "event_id": event["id"],
    }
    review_resp = client.post("/api/reviews/", json=review_payload)
    assert review_resp.status_code == 200, review_resp.text
    review = review_resp.json()

    return event, review


def test_add_and_get_review_asset(test_client, event_and_review):
    client, _ = test_client
    _, review = event_and_review

    # Create asset
    asset_payload = {"url": "https://example.com/photo1.jpg"}
    create_resp = client.post(f"/api/reviews/{review['id']}/assets", json=asset_payload)
    assert create_resp.status_code == 200, create_resp.text

    created_asset = create_resp.json()
    assert created_asset["url"] == asset_payload["url"]
    assert created_asset["review_id"] == review["id"]
    assert "id" in created_asset

    asset_id = created_asset["id"]

    # Get asset by ID
    get_resp = client.get(f"/api/reviews/assets/{asset_id}")
    assert get_resp.status_code == 200, get_resp.text
    fetched = get_resp.json()
    assert fetched["id"] == asset_id
    assert fetched["url"] == asset_payload["url"]

    # Get all assets for review
    list_resp = client.get(f"/api/reviews/{review['id']}/assets")
    assert list_resp.status_code == 200, list_resp.text
    assets = list_resp.json()
    assert isinstance(assets, list)
    assert any(a["id"] == asset_id for a in assets)


def test_add_asset_to_nonexistent_review(test_client):
    client, _ = test_client
    payload = {"url": "https://example.com/ghost.jpg"}
    resp = client.post("/api/reviews/9999/assets", json=payload)
    assert resp.status_code == 404
    assert resp.json()["detail"] == "Review not found"


def test_get_nonexistent_asset(test_client):
    client, _ = test_client
    resp = client.get("/api/reviews/assets/9999")
    assert resp.status_code == 404
    assert resp.json()["detail"] == "Asset not found"
