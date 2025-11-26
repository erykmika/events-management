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
      navigate("/");
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div className="w-screen h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50 flex items-center justify-center p-4 overflow-auto">
      <div className="w-full max-w-xl flex flex-col space-y-6">

        <h1 className="text-3xl font-bold text-center text-gray-800">
          Create a New Event
        </h1>

        {error && (
          <p className="text-red-600 text-center bg-red-100 p-2 rounded-lg text-sm">
            {error}
          </p>
        )}

        <form
          onSubmit={handleSubmit}
          className="overflow-y-hidden space-y-1.5 bg-white/70 backdrop-blur-xl border border-gray-200 shadow-lg rounded-2xl p-6 max-h-[90vh]"
        >
          {[
            { name: "title", label: "Event Title", type: "text" },
            { name: "description", label: "Event Description", type: "textarea" },
            { name: "date", label: "Date & Time", type: "datetime-local" },
            { name: "location", label: "Location", type: "text" },
            { name: "organizer", label: "Organizer", type: "text" },
            { name: "max_participants", label: "Max Participants (Optional)", type: "number" },
          ].map(({ name, label, type }) => (
            <div key={name}>
              <label className="block mb-1 font-medium text-gray-700 text-sm">
                {label}
              </label>

              {type === "textarea" ? (
                <textarea
                  name={name}
                  value={form[name]}
                  onChange={handleChange}
                  required={name !== "max_participants"}
                  className="border border-gray-300 p-3 rounded-lg w-full h-24 text-sm focus:border-purple-500 focus:ring-2 focus:ring-purple-200 transition-all bg-white"
                />
              ) : (
                <input
                  name={name}
                  type={type}
                  value={form[name]}
                  onChange={handleChange}
                  required={name !== "max_participants"}
                  className="border border-gray-300 p-3 rounded-lg w-full text-sm focus:border-purple-500 focus:ring-2 focus:ring-purple-200 transition-all bg-white"
                />
              )}
            </div>
          ))}

          <button
            type="submit"
            className="w-full py-3 rounded-lg text-lg font-semibold text-white bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 shadow-md transition-all"
          >
            Create Event
          </button>
        </form>
      </div>
    </div>
  );
}
