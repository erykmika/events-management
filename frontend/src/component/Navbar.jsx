import {Link} from "react-router-dom";

export default function Navbar() {
    return (
        <nav className="bg-blue-600 text-white p-4 flex justify-between items-center">
            <div>
                <Link to="/" className="hover:underline">Events</Link>
            </div>
            <div>
                <Link to="/events/new" className="hover:underline">Add Event</Link>
            </div>
        </nav>
    );
}
