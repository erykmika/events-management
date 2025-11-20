import { loadRuntimeConfig } from "./configLoader";


export async function apiFetch(path, options = {}) {
  const config = await loadRuntimeConfig();

  const token = localStorage.getItem("id_token");
  if (token === null) {
    throw new Error("unauthenticated");
  }

  const headers = {
    "Content-Type": "application/json",
    ...(options.headers || {}),
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  };

  console.log(`Request using API URL: ${config.api_url}`)
  return fetch(`${config.api_url}${path}`, {
    ...options,
    headers,
  }).then(async (res) => {
    if (!res.ok) {
      const body = await res.text();
      throw new Error(`API error: ${res.status} ${body}`);
    }
    return res.json().catch(() => null);
  });
}


export async function getEvents() {
  return apiFetch(`/events/`);
}

export async function getEventById(id) {
  return apiFetch(`/events/${id}`);
}

export async function getReviewsForEvent(eventId) {
  return apiFetch(`/reviews/event/${eventId}`);
}

export async function createReview(reviewData) {
  return apiFetch(`/reviews/`, {
    method: "POST",
    body: JSON.stringify(reviewData),
  });
}

export async function createEvent(eventData) {
  return apiFetch(`/events/`, {
    method: "POST",
    body: JSON.stringify(eventData),
  });
}
