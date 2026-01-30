import { Link } from "react-router-dom";
import React from "react";
import { useContext } from "react";
import { AuthContext } from "../AuthContext.js";

export default function Sidebar() {
    const { authenticated, setAuthenticated } = useContext(AuthContext);

    if (!authenticated) return null;

    const handleLogout = () => {
        localStorage.clear();
        setAuthenticated(false);
        window.location.reload();
    };

    return (
        <aside className="fixed top-0 left-0 h-screen w-64 bg-gradient-to-b from-blue-600 to-purple-600 shadow-lg flex flex-col justify-between p-6 z-50">
            <div className="space-y-6">
                <h2 className="text-white text-2xl font-bold">Menu</h2>
                <div className="flex flex-col space-y-4">
                    <Link
                        to="/"
                        className="text-white font-semibold text-lg hover:text-yellow-300 transition-colors"
                    >
                        Events
                    </Link>
                    <Link
                        to="/events/new"
                        className="text-white font-semibold text-lg hover:text-yellow-300 transition-colors"
                    >
                        Add Event
                    </Link>
                </div>
            </div>

            <div>
                <button
                    onClick={handleLogout}
                    className="bg-white/20 hover:bg-white/30 text-white font-semibold px-4 py-2 rounded-lg w-full transition-colors"
                >
                    Logout
                </button>
            </div>
        </aside>
    );
}
