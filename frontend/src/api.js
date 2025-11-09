const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;


export async function getEvents() {
  const response = await fetch(`${API_BASE_URL}/events/`);
  if (!response.ok) throw new Error("Failed to fetch events");
  return response.json();
}

export async function getEventById(id) {
  const response = await fetch(`${API_BASE_URL}/events/${id}`);
  if (!response.ok) throw new Error("Failed to fetch event");
  return response.json();
}

export async function getReviewsForEvent(eventId) {
  const response = await fetch(`${API_BASE_URL}/reviews/event/${eventId}`);
  if (!response.ok) throw new Error("Failed to fetch reviews");
  return response.json();
}

export async function createReview(reviewData) {
  const response = await fetch(`${API_BASE_URL}/reviews/`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(reviewData),
  });
  if (!response.ok) throw new Error("Failed to create review");
  return response.json();
}

export async function createEvent(eventData) {
  const response = await fetch(`${API_BASE_URL}/events/`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(eventData),
  });
  if (!response.ok) throw new Error("Failed to create event");
  return response.json();
}
