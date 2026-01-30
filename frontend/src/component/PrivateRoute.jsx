import React, { useContext, useEffect, useState } from "react";
import { Navigate } from "react-router-dom";
import { AuthContext } from "../AuthContext.js";

export default function PrivateRoute({ children }) {
    const { authenticated, setAuthenticated } = useContext(AuthContext);
    const [isLoading, setIsLoading] = useState(true);
    const [isAuthenticated, setIsAuthenticated] = useState(false);

    useEffect(() => {
        const token = localStorage.getItem("id_token");
        if (token) {
            setIsAuthenticated(true);
            setAuthenticated(true);
        } else {
            setIsAuthenticated(false);
        }
        setIsLoading(false);
    }, []);

    if (isLoading) return <div>Loading...</div>;

    return isAuthenticated ? children : <Navigate to="/login" replace />;
}
