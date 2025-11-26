import { useState } from "react";
import { createReview, uploadReviewAsset } from "../api";

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
    <form
      onSubmit={submit}
      className="space-y-5 bg-white/70 backdrop-blur-xl border border-gray-200 rounded-3xl shadow-md p-6 max-w-xl mx-auto"
    >
      <h3 className="text-2xl font-bold text-gray-800 text-center">Add a Review</h3>

      <div className="space-y-2">
        <label className="text-sm font-medium text-gray-700">Title</label>
        <input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Enter a title"
          required
          className="w-full p-3 rounded-xl border border-gray-300 text-sm bg-white shadow-sm focus:border-purple-500 focus:ring-2 focus:ring-purple-200 transition-all"
        />
      </div>

      <div className="space-y-2">
        <label className="text-sm font-medium text-gray-700">Your Review</label>
        <textarea
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder="Write your review"
          required
          className="w-full p-3 rounded-xl border border-gray-300 text-sm bg-white shadow-sm h-28 focus:border-purple-500 focus:ring-2 focus:ring-purple-200 transition-all resize-none"
        />
      </div>

      <div className="space-y-2">
        <label className="text-sm font-medium text-gray-700">Rating</label>
        <select
          value={rating}
          onChange={(e) => setRating(Number(e.target.value))}
          className="w-full p-3 rounded-xl border border-gray-300 text-sm bg-white shadow-sm focus:border-purple-500 focus:ring-2 focus:ring-purple-200 transition-all"
        >
          {[1, 2, 3, 4, 5].map((r) => (
            <option key={r} value={r}>
              {r} Stars
            </option>
          ))}
        </select>
      </div>

      <div className="space-y-2">
        <label className="text-sm font-medium text-gray-700">Upload Image (Optional)</label>
        <input
          type="file"
          onChange={(e) => setFile(e.target.files[0])}
          accept="image/*"
          className="block w-full text-sm text-gray-600"
        />
      </div>

      <button
        type="submit"
        className="w-full py-3 text-lg font-semibold rounded-xl text-white bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 shadow-md hover:shadow-lg transition-all"
      >
        Submit Review
      </button>
    </form>
  );
}
