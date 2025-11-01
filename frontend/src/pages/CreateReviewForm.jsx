import { useState } from "react";
import { createReview } from "../api";

export default function CreateReviewForm({ eventId, onReviewCreated }) {
  const [form, setForm] = useState({ title: "", content: "", rating: 5 });
  const [error, setError] = useState(null);

  const handleChange = e => setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = async e => {
    e.preventDefault();
    try {
      await createReview({ ...form, rating: Number(form.rating), event_id: eventId });
      setForm({ title: "", content: "", rating: 5 });
      onReviewCreated?.();
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="border rounded p-4 mt-6 space-y-3">
      <h3 className="text-lg font-semibold">Leave a Review</h3>
      {error && <p className="text-red-600">{error}</p>}
      <input
        name="title"
        value={form.title}
        onChange={handleChange}
        placeholder="Title"
        className="border w-full p-2 rounded"
        required
      />
      <textarea
        name="content"
        value={form.content}
        onChange={handleChange}
        placeholder="Your thoughts..."
        className="border w-full p-2 rounded"
        required
      />
      <select
        name="rating"
        value={form.rating}
        onChange={handleChange}
        className="border w-full p-2 rounded"
      >
        {[1, 2, 3, 4, 5].map(r => (
          <option key={r} value={r}>{r}</option>
        ))}
      </select>
      <button
        type="submit"
        className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
      >
        Submit Review
      </button>
    </form>
  );
}
