import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { loadRuntimeConfig } from "../configLoader";

export default function SignIn() {
    const [user, setUser] = useState("");
    const [password, setPassword] = useState("");
    const navigate = useNavigate();

    const login = async (e) => {
        e.preventDefault();
        try {
            const cfg = await loadRuntimeConfig();
            const tokenUrl = `${cfg.keycloak_base_url}/realms/${cfg.keycloak_realm}/protocol/openid-connect/token`;
            const body = new URLSearchParams({
                grant_type: "password",
                client_id: cfg.keycloak_client_id,
                username: user,
                password: password,
            });

            const resp = await fetch(tokenUrl, {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded",
                },
                body: body.toString(),
            });

            if (!resp.ok) {
                const errText = await resp.text();
                throw new Error(
                    `Keycloak auth failed: ${resp.status} ${errText}`,
                );
            }

            const data = await resp.json();
            // Use access token for API calls
            localStorage.setItem("id_token", data.access_token);
            navigate("/", { replace: true });
        } catch (err) {
            console.error(err);
            alert("Login failed");
        }
    };

    return (
        <div className="w-screen h-screen max-w-screen max-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 via-white to-purple-50 overflow-hidden p-4">
            <div className="w-full max-w-sm bg-white/60 backdrop-blur-xl border border-gray-200 shadow-xl rounded-3xl p-8 space-y-6">
                <h2 className="text-3xl font-bold text-center text-gray-800">
                    Sign In
                </h2>

                <form onSubmit={login} className="space-y-4">
                    <div className="space-y-1">
                        <label className="text-sm font-medium text-gray-700">
                            Username
                        </label>
                        <input
                            placeholder="Enter username"
                            value={user}
                            onChange={(e) => setUser(e.target.value)}
                            required
                            className="w-full p-3 rounded-lg border border-gray-300 bg-white shadow-sm text-sm focus:border-purple-500 focus:ring-2 focus:ring-purple-200 transition-all"
                        />
                    </div>

                    <div className="space-y-1">
                        <label className="text-sm font-medium text-gray-700">
                            Password
                        </label>
                        <input
                            type="password"
                            placeholder="Enter password"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            required
                            className="w-full p-3 rounded-lg border border-gray-300 bg-white shadow-sm text-sm focus:border-purple-500 focus:ring-2 focus:ring-purple-200 transition-all"
                        />
                    </div>

                    <button
                        type="submit"
                        className="w-full py-3 mt-2 rounded-lg text-lg font-semibold text-white bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 shadow-md hover:shadow-lg transition-all"
                    >
                        Sign In
                    </button>
                </form>
            </div>
        </div>
    );
}
