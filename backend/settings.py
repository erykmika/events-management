import logging
from enum import StrEnum, auto
from logging import getLogger

from pydantic import BaseModel
import os
from dotenv import load_dotenv

logging.basicConfig(level=logging.DEBUG)
logger = getLogger(__name__)


class Settings(StrEnum):
    DEVELOPMENT = auto()
    PRODUCTION = auto()
    TESTING = auto()


class SettingsDetails(BaseModel):
    LOGGING_LEVEL: str = "INFO"
    DATABASE_URL: str
    KEYCLOAK_CLIENT_ID: str = ""
    KEYCLOAK_JWKS_URL: str = ""
    S3_ASSETS_BUCKET: str = ""
    MINIO_ENDPOINT: str = ""
    MINIO_ACCESS_KEY: str = ""
    MINIO_SECRET_ACCESS_KEY: str = ""
    AWS_REGION: str = ""
    LAMBDA_ARN: str = ""


SETTINGS = {
    Settings.DEVELOPMENT: SettingsDetails(
        LOGGING_LEVEL="DEBUG",
        DATABASE_URL="sqlite:///./dev.db",
    ),
    Settings.PRODUCTION: SettingsDetails(
        LOGGING_LEVEL="INFO",
        DATABASE_URL="",  # need to pass explicitly via environment variable
    ),
}

load_dotenv()

_ENV_VAR = "ENVIRONMENT"

_env_value = os.getenv(_ENV_VAR)
_selected_env = Settings.DEVELOPMENT

if _env_value:
    _selected_env = Settings[_env_value.upper()]  # noqa
else:
    _selected_env = Settings.DEVELOPMENT

CURRENT_SETTINGS: SettingsDetails = SETTINGS.get(_selected_env, SETTINGS[Settings.DEVELOPMENT])  # noqa

# optionally override `CURRENT_SETTINGS` attributes with the values given in env
for setting in CURRENT_SETTINGS.model_dump().keys():
    env_value = os.getenv(setting)
    if env_value is not None:
        logger.info(f"Using env-provided value of {setting}={str(env_value)[:5]}***{str(env_value)[-5:]}")
        setattr(CURRENT_SETTINGS, setting, env_value)


def get_settings() -> SettingsDetails:
    return CURRENT_SETTINGS
