import React, { useEffect, useState } from "react";
import { Navigate } from "react-router-dom";
import { fetchAuthSession } from "aws-amplify/auth";

export default function PrivateRoute({ children }) {
    const [isLoading, setIsLoading] = useState(true);
    const [isAuthenticated, setIsAuthenticated] = useState(false);

    useEffect(() => {
        const checkAuth = async () => {
            try {
                const session = await fetchAuthSession();
                if (session?.tokens?.idToken) {
                    localStorage.setItem(
                        "id_token",
                        session.tokens.idToken.toString()
                    );
                    setIsAuthenticated(true);
                }
            } catch (err) {
                console.error("Not authenticated", err);
                setIsAuthenticated(false);
            } finally {
                setIsLoading(false);
            }
        };

        checkAuth();
    }, []);

    if (isLoading) return <div>Loading...</div>;

    return isAuthenticated ? children : <Navigate to="/login" replace />;
}
