import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { getEventById, getReviewsForEvent, getAssetsForReview } from "../api";
import CreateReviewForm from "./CreateReviewForm.jsx";

export default function EventDetail() {
    const { id } = useParams();
    const [event, setEvent] = useState(null);
    const [reviews, setReviews] = useState([]);
    const [assetsByReview, setAssetsByReview] = useState({});

    const refreshReviews = () => {
        getReviewsForEvent(id).then(setReviews).catch(console.error);
    };

    useEffect(() => {
        getEventById(id).then(setEvent).catch(console.error);
        refreshReviews();
    }, [id]);

    const loadAssets = async (reviewId) => {
        const assets = await getAssetsForReview(reviewId);
        setAssetsByReview((prev) => ({ ...prev, [reviewId]: assets }));
    };

    useEffect(() => {
        if (reviews.length) {
            reviews.forEach((r) => loadAssets(r.id));
        }
    }, [reviews]);

    if (!event)
        return (
            <div className="w-screen h-screen flex items-center justify-center">
                <p className="text-gray-500 text-lg">Loading event...</p>
            </div>
        );

    return (
        <div className="w-screen h-screen max-w-screen max-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50 overflow-auto p-6 flex justify-center">
            <div className="w-full max-w-3xl space-y-6">
                {/* Event Card */}
                <div className="bg-white/70 backdrop-blur-xl border border-gray-200 shadow-lg rounded-3xl p-6 space-y-3">
                    <h1 className="text-3xl font-bold text-gray-800">
                        {event.title}
                    </h1>
                    <p className="text-gray-700">{event.description}</p>
                    <p className="text-gray-500 text-sm">
                        {event.location} —{" "}
                        {new Date(event.date).toLocaleString()}
                    </p>
                </div>

                {/* Reviews Section */}
                <div className="space-y-4">
                    <h2 className="text-2xl font-semibold text-gray-800">
                        Reviews
                    </h2>

                    {reviews.length === 0 ? (
                        <p className="text-gray-500">No reviews yet.</p>
                    ) : (
                        <ul className="space-y-4">
                            {reviews.map((r) => {
                                const assets = assetsByReview[r.id] || [];
                                return (
                                    <li
                                        key={r.id}
                                        className="bg-white/60 backdrop-blur-xl border border-gray-200 rounded-2xl shadow-md p-4 hover:shadow-xl transition-all"
                                    >
                                        <div className="flex justify-between items-center mb-2">
                                            <strong className="text-lg text-gray-800">
                                                {r.title}
                                            </strong>
                                            <span className="text-sm text-gray-600">
                                                {r.rating}/5
                                            </span>
                                        </div>
                                        <p className="text-gray-700 text-sm">
                                            {r.content}
                                        </p>

                                        {assets.length > 0 && (
                                            <div className="flex flex-wrap gap-2 mt-3">
                                                {assets.map((a) => (
                                                    <img
                                                        key={a.id}
                                                        src={a.url}
                                                        alt="Review asset"
                                                        className="h-24 w-24 object-cover rounded-lg border"
                                                    />
                                                ))}
                                            </div>
                                        )}
                                    </li>
                                );
                            })}
                        </ul>
                    )}
                </div>

                {/* Create Review Form */}
                <div className="bg-white/70 backdrop-blur-xl border border-gray-200 shadow-lg rounded-3xl p-6">
                    <CreateReviewForm
                        eventId={event.id}
                        onReviewCreated={refreshReviews}
                    />
                </div>
            </div>
        </div>
    );
}
