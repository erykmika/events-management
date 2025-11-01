import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { createEvent } from "../api";

export default function CreateEventForm() {
  const navigate = useNavigate();
  const [form, setForm] = useState({
    title: "",
    description: "",
    date: "",
    location: "",
    organizer: "",
    max_participants: "",
  });
  const [error, setError] = useState(null);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const eventData = {
        ...form,
        max_participants: Number(form.max_participants) || null,
      };
      await createEvent(eventData);
      navigate("/"); // go back to events list
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div className="p-6 max-w-xl mx-auto">
      <h1 className="text-2xl font-semibold mb-4">Create New Event</h1>
      {error && <p className="text-red-600 mb-2">{error}</p>}

      <form onSubmit={handleSubmit} className="space-y-3 border rounded p-4 shadow-sm">
        <input
          name="title"
          value={form.title}
          onChange={handleChange}
          placeholder="Event Title"
          required
          className="border p-2 rounded w-full"
        />
        <textarea
          name="description"
          value={form.description}
          onChange={handleChange}
          placeholder="Event Description"
          required
          className="border p-2 rounded w-full"
        />
        <input
          name="date"
          type="datetime-local"
          value={form.date}
          onChange={handleChange}
          required
          className="border p-2 rounded w-full"
        />
        <input
          name="location"
          value={form.location}
          onChange={handleChange}
          placeholder="Location"
          required
          className="border p-2 rounded w-full"
        />
        <input
          name="organizer"
          value={form.organizer}
          onChange={handleChange}
          placeholder="Organizer"
          required
          className="border p-2 rounded w-full"
        />
        <input
          name="max_participants"
          type="number"
          value={form.max_participants}
          onChange={handleChange}
          placeholder="Max Participants (optional)"
          className="border p-2 rounded w-full"
        />

        <button
          type="submit"
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
        >
          Create Event
        </button>
      </form>
    </div>
  );
}
