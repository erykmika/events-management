import {useEffect, useState} from "react";
import {useParams} from "react-router-dom";
import {getEventById, getReviewsForEvent} from "../api";
import CreateReviewForm from "./CreateReviewForm.jsx";
import {getAssetsForReview} from "../api";

export default function EventDetail() {
    const {id} = useParams();
    const [event, setEvent] = useState(null);
    const [reviews, setReviews] = useState([]);

    const refreshReviews = () => {
        getReviewsForEvent(id).then(setReviews).catch(console.error);
    };

    useEffect(() => {
        getEventById(id).then(setEvent).catch(console.error);
        refreshReviews();
    }, [id]);

    const [assetsByReview, setAssetsByReview] = useState({});

    const loadAssets = async (reviewId) => {
        const assets = await getAssetsForReview(reviewId);
        setAssetsByReview((prev) => ({...prev, [reviewId]: assets}));
    };

    useEffect(() => {
        if (reviews.length) {
            reviews.forEach((r) => loadAssets(r.id));
        }
    }, [reviews]);


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
                    reviews.map(r => {
                        const assets = assetsByReview[r.id] || [];

                        return (
                            <li key={r.id} className="border p-3 rounded">
                                <strong>{r.title}</strong> ({r.rating}/5)
                                <p>{r.content}</p>

                                {assets.length > 0 && (
                                    <div className="flex gap-2 mt-2">
                                        {assets.map(a => (
                                            <img
                                                key={a.id}
                                                src={a.url}
                                                alt="Review asset"
                                                className="h-24 w-24 object-cover rounded border"
                                            />
                                        ))}
                                    </div>
                                )}
                            </li>
                        );
                    })
                ) : (
                    <p>No reviews yet.</p>
                )}
            </ul>

            <CreateReviewForm eventId={event.id} onReviewCreated={refreshReviews}/>
        </div>
    );
}
