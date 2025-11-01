import pytest


@pytest.fixture
def sample_event(test_client):
    client, _ = test_client
    event_data = {
        "title": "Sample Event",
        "description": "A test event for reviews",
        "date": "2025-12-01T09:00:00",
        "location": "Test Hall",
        "organizer": "QA Team",
        "max_participants": 50,
    }
    response = client.post("/events/", json=event_data)
    assert response.status_code == 200, response.text
    return response.json()


def test_create_and_get_reviews(test_client, sample_event):
    client, _ = test_client

    new_review = {
        "title": "Great event!",
        "content": "Had a fantastic time at the concert.",
        "rating": 5,
        "event_id": sample_event["id"],
    }

    # Create review
    create_response = client.post("/reviews/", json=new_review)
    assert create_response.status_code == 200, create_response.text
    created_review = create_response.json()
    assert created_review["title"] == new_review["title"]
    assert created_review["content"] == new_review["content"]
    assert created_review["rating"] == new_review["rating"]
    assert created_review["event_id"] == sample_event["id"]
    review_id = created_review["id"]

    # List all reviews
    list_response = client.get("/reviews/")
    assert list_response.status_code == 200
    reviews = list_response.json()
    assert isinstance(reviews, list)
    assert any(r["id"] == review_id for r in reviews)

    # Get review by ID
    get_response = client.get(f"/reviews/{review_id}")
    assert get_response.status_code == 200
    review_data = get_response.json()
    assert review_data["id"] == review_id
    assert review_data["event_id"] == sample_event["id"]

    # Get reviews for the event
    by_event_response = client.get(f"/reviews/event/{sample_event['id']}")
    assert by_event_response.status_code == 200
    event_reviews = by_event_response.json()
    assert len(event_reviews) >= 1
    assert any(r["id"] == review_id for r in event_reviews)


@pytest.mark.parametrize(
    "payload,expected_status",
    [
        ({"title": "Too short", "content": "Nice", "rating": 5, "event_id": 1}, 422),
        ({"title": "Valid title", "content": "Valid content", "rating": 0, "event_id": 1}, 422),
        ({"title": "", "content": "", "rating": 3, "event_id": 1}, 422),
    ],
)
def test_invalid_review_creation(test_client, payload, expected_status):
    client, _ = test_client
    response = client.post("/reviews/", json=payload)
    assert response.status_code == expected_status
