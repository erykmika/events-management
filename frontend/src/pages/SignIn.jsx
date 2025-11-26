import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { signIn, fetchAuthSession } from "aws-amplify/auth";

export default function SignIn() {
    const [user, setUser] = useState("");
    const [password, setPassword] = useState("");
    const navigate = useNavigate();

    const login = async (e) => {
        e.preventDefault();
        try {
            await signIn({ username: user, password });
            const session = await fetchAuthSession();
            localStorage.setItem("id_token", session.tokens.idToken.toString());

            navigate("/", { replace: true });
        } catch (err) {
            console.error(err);
            alert("Login failed");
        }
    };

    return (
        <div style={{ maxWidth: 300, margin: "60px auto" }}>
            <h2>Sign In</h2>
            <form onSubmit={login}>
                <input
                    placeholder="User"
                    value={user}
                    onChange={(e) => setUser(e.target.value)}
                /><br /><br />

                <input
                    type="password"
                    placeholder="Password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                /><br /><br />

                <button type="submit">Sign In</button>
            </form>
        </div>
    );
}
