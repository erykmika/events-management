import requests
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt, JWTError

from backend.settings import get_settings


def get_jwks():
    settings = get_settings()
    jwks = requests.get(settings.COGNITO_JWKS_URL).json()
    return {key["kid"]: key for key in jwks["keys"]}


security = HTTPBearer()


def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Verify JWT token using AWS Cognito auth provider"""
    settings = get_settings()
    token = credentials.credentials
    try:
        headers = jwt.get_unverified_header(token)
        key = get_jwks().get(headers["kid"])
        if not key:
            raise HTTPException(status_code=401, detail="Invalid token")

        payload = jwt.decode(
            token,
            key,
            algorithms=[headers["alg"]],
            audience=settings.COGNITO_APP_CLIENT_ID,
        )
        return payload
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
