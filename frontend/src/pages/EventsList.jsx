import React, { useEffect, useState } from "react";
import { getEvents } from "../api";
import { Link } from "react-router-dom";

export default function EventsList() {
    const [events, setEvents] = useState([]);

    useEffect(() => {
        getEvents().then(setEvents).catch(console.error);
    }, []);

    return (
        <div className="w-screen h-screen max-w-screen max-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50 p-6 overflow-auto flex flex-col items-center">
            <h1 className="text-3xl font-bold text-gray-800 mb-6 text-center">
                Upcoming Events
            </h1>

            {events.length === 0 ? (
                <p className="text-gray-500 text-lg mt-6">
                    No upcoming events.
                </p>
            ) : (
                <ul className="w-full max-w-3xl grid grid-cols-1 gap-4">
                    {events.map((ev) => (
                        <li
                            key={ev.id}
                            className="p-4 bg-white/70 backdrop-blur-xl border border-gray-200 rounded-2xl shadow-md hover:shadow-xl transform hover:-translate-y-1 transition-all"
                        >
                            <Link
                                to={`/events/${ev.id}`}
                                className="text-xl font-semibold text-blue-600 hover:underline"
                            >
                                {ev.title}
                            </Link>
                            <p className="text-gray-600 text-sm mt-1">
                                {ev.location} —{" "}
                                {new Date(ev.date).toLocaleDateString()}
                            </p>
                        </li>
                    ))}
                </ul>
            )}
        </div>
    );
}
