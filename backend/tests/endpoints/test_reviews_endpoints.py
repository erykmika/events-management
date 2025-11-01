import pytest


def test_create_and_get_reviews(test_client):
    client, _ = test_client

    new_review = {
        "title": "Great event!",
        "content": "Had a fantastic time at the concert.",
        "rating": 5,
    }

    create_response = client.post("/reviews", json=new_review)
    assert create_response.status_code == 200, create_response.text

    created_review = create_response.json()
    assert created_review["title"] == new_review["title"]
    assert created_review["content"] == new_review["content"]
    assert created_review["rating"] == new_review["rating"]
    assert "id" in created_review

    review_id = created_review["id"]

    list_response = client.get("/reviews")
    assert list_response.status_code == 200
    reviews = list_response.json()
    assert isinstance(reviews, list)
    assert len(reviews) >= 1
    assert any(r["id"] == review_id for r in reviews)

    get_response = client.get(f"/reviews/{review_id}")
    assert get_response.status_code == 200
    review_data = get_response.json()
    assert review_data["id"] == review_id
    assert review_data["title"] == new_review["title"]
    assert review_data["rating"] == new_review["rating"]


@pytest.mark.parametrize(
    "payload,expected_status",
    [
        ({"title": "Too short", "content": "Nice", "rating": 5}, 422),  # invalid title/content length
        ({"title": "Valid title", "content": "Valid content", "rating": 0}, 422),  # invalid rating
        ({"title": "", "content": "", "rating": 3}, 422),  # missing fields
    ],
)
def test_invalid_review_creation(test_client, payload, expected_status):
    client, _ = test_client
    response = client.post("/reviews", json=payload)
    assert response.status_code == expected_status
