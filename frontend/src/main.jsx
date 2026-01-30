import React, { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "./index.css";
import App from "./App.jsx";
import { loadRuntimeConfig } from "./configLoader";

async function bootstrap() {
    const config = await loadRuntimeConfig();
    console.log(`Loaded config ${JSON.stringify(config)}`);

    createRoot(document.getElementById("root")).render(
        <StrictMode>
            <App />
        </StrictMode>,
    );
}

bootstrap();
