import {Link} from "react-router-dom";
import {useContext} from "react";
import {AuthContext} from "../AuthContext.js";

export default function Navbar() {

    const { authenticated, setAuthenticated } = useContext(AuthContext);

    return (
        authenticated ?
            <nav className="bg-blue-600 text-white p-4 flex justify-between items-center">
                <div>
                    <Link to="/" className="hover:underline">Events</Link>
                </div>
                <div>
                    <Link to="/events/new" className="hover:underline">Add Event</Link>
                </div>
            </nav> : <></>
    );
}
