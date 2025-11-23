import { useState } from "react";
import { createReview } from "../api";
import { uploadReviewAsset } from "../api";

export default function CreateReviewForm({ eventId, onReviewCreated }) {
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [rating, setRating] = useState(5);
  const [file, setFile] = useState(null);

  const submit = async (e) => {
    e.preventDefault();

    try {
      const review = await createReview({
        title,
        content,
        rating,
        event_id: eventId,
      });

      if (file) {
        await uploadReviewAsset(review.id, file);
      }

      onReviewCreated();
      setTitle("");
      setContent("");
      setRating(5);
      setFile(null);
    } catch (err) {
      console.error(err);
      alert("Error creating review");
    }
  };

  return (
    <form onSubmit={submit} className="space-y-2 border p-4 rounded">
      <h3 className="font-semibold text-lg">Add a Review</h3>

      <input
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        placeholder="Title"
        className="border p-2 rounded w-full"
      />

      <textarea
        value={content}
        onChange={(e) => setContent(e.target.value)}
        placeholder="Your review"
        className="border p-2 rounded w-full"
      />

      <select
        value={rating}
        onChange={(e) => setRating(Number(e.target.value))}
        className="border p-2 rounded"
      >
        {[1, 2, 3, 4, 5].map((r) => (
          <option key={r} value={r}>
            {r} Stars
          </option>
        ))}
      </select>

      <input
        type="file"
        onChange={(e) => setFile(e.target.files[0])}
        accept="image/*"
        className="block"
      />

      <button className="bg-blue-600 text-white py-2 px-4 rounded">
        Submit Review
      </button>
    </form>
  );
}
