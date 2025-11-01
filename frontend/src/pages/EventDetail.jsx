import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { getEventById, getReviewsForEvent } from "../api";
import CreateReviewForm from "./CreateReviewForm.jsx";

export default function EventDetail() {
  const { id } = useParams();
  const [event, setEvent] = useState(null);
  const [reviews, setReviews] = useState([]);

  const refreshReviews = () => {
    getReviewsForEvent(id).then(setReviews).catch(console.error);
  };

  useEffect(() => {
    getEventById(id).then(setEvent).catch(console.error);
    refreshReviews();
  }, [id]);

  if (!event) return <p className="p-6">Loading event...</p>;

  return (
    <div className="p-6 space-y-4">
      <h1 className="text-3xl font-bold">{event.title}</h1>
      <p>{event.description}</p>
      <p className="text-gray-600">
        {event.location} — {new Date(event.date).toLocaleString()}
      </p>

      <h2 className="text-xl font-semibold mt-6">Reviews</h2>
      <ul className="space-y-2">
        {reviews.length ? (
          reviews.map(r => (
            <li key={r.id} className="border p-3 rounded">
              <strong>{r.title}</strong> ({r.rating}/5)
              <p>{r.content}</p>
            </li>
          ))
        ) : (
          <p>No reviews yet.</p>
        )}
      </ul>

      <CreateReviewForm eventId={event.id} onReviewCreated={refreshReviews} />
    </div>
  );
}
