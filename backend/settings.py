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
    COGNITO_USER_POOL_ID: str = ""
    COGNITO_APP_CLIENT_ID: str = ""
    COGNITO_JWKS_URL: str = ""


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
_DB_URL_VAR = "DATABASE_URL"

_env_value = os.getenv(_ENV_VAR, None)
_selected_env = Settings.DEVELOPMENT

if _env_value:
    _selected_env = Settings[_env_value.upper()]  # noqa
else:
    _selected_env = Settings.DEVELOPMENT

CURRENT_SETTINGS: SettingsDetails = SETTINGS.get(_selected_env, SETTINGS[Settings.DEVELOPMENT])  # noqa

# optionally override db url
_db_url_value = os.getenv(_DB_URL_VAR, None)
if _db_url_value:
    logger.info(f"Using .env-provided DB URL: {_db_url_value[:5]}...")
    CURRENT_SETTINGS.DATABASE_URL = _db_url_value

# override cognito environment vars
for cognito_setting in ("COGNITO_USER_POOL_ID", "COGNITO_APP_CLIENT_ID", "COGNITO_JWKS_URL"):
    _env_value = os.getenv(cognito_setting, None)
    if _env_value is not None:
        logger.info(f"Using .env-provided value of {cognito_setting}: {_env_value}")
        setattr(CURRENT_SETTINGS, cognito_setting, _env_value)
    else:
        logger.info(f"{cognito_setting} not given in .env")


def get_settings() -> SettingsDetails:
    return CURRENT_SETTINGS
