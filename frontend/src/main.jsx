import {StrictMode} from 'react';
import {createRoot} from 'react-dom/client';
import './index.css';
import App from './App.jsx';
import {loadRuntimeConfig} from "./configLoader";
import {Amplify} from "aws-amplify";

async function bootstrap() {

    const config = await loadRuntimeConfig();
    console.log(`Loaded config ${JSON.stringify(config)}`);

    if (config !== null) {
        Amplify.configure({
            Auth: {
                Cognito: {
                    userPoolId: config.aws_user_pools_id,
                    userPoolClientId: config.aws_user_pools_web_client_id,
                }
            }
        });
    } else {
        console.log("Not configuring Amplify!");
    }

    createRoot(document.getElementById('root')).render(
        <StrictMode>
            <App/>
        </StrictMode>
    );
}


bootstrap();
