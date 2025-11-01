import { useEffect, useState } from "react";
import { getEvents } from "../api";
import { Link } from "react-router-dom";

export default function EventsList() {
  const [events, setEvents] = useState([]);

  useEffect(() => {
    getEvents().then(setEvents).catch(console.error);
  }, []);

  return (
    <div className="p-6">
      <h1 className="text-2xl font-semibold mb-4">Upcoming Events</h1>
      <ul className="space-y-3">
        {events.map(ev => (
          <li key={ev.id} className="p-4 border rounded hover:shadow">
            <Link to={`/events/${ev.id}`} className="text-blue-600 font-medium">
              {ev.title}
            </Link>
            <p className="text-gray-600">{ev.location} — {new Date(ev.date).toLocaleDateString()}</p>
          </li>
        ))}
      </ul>
    </div>
  );
}
