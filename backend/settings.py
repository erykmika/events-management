from enum import StrEnum, auto
from pydantic import BaseModel
import os
from dotenv import load_dotenv


class Settings(StrEnum):
    DEVELOPMENT = auto()
    PRODUCTION = auto()
    TESTING = auto()


class SettingsDetails(BaseModel):
    LOGGING_LEVEL: str = "INFO"
    DATABASE_URL: str


SETTINGS = {
    Settings.DEVELOPMENT: SettingsDetails(
        LOGGING_LEVEL="DEBUG",
        DATABASE_URL="sqlite:///./dev.db",
    ),
    Settings.PRODUCTION: SettingsDetails(
        LOGGING_LEVEL="INFO",
        DATABASE_URL="postgresql://user:password@localhost/prod_db",
    ),
    Settings.TESTING: SettingsDetails(
        LOGGING_LEVEL="DEBUG",
        DATABASE_URL="sqlite://:memory:",
    ),
}

load_dotenv()  # load variables from .env into the environment

_ENV_VAR = "ENVIRONMENT"

_env_value = os.getenv(_ENV_VAR, None)
_selected_env = Settings.DEVELOPMENT

if _env_value:
    # prefer enum member name (e.g. "DEVELOPMENT", "PRODUCTION", "TESTING")
    try:
        _selected_env = Settings[_env_value.upper()]
    except KeyError:
        # fall back to matching the enum value string
        for _s in Settings:
            if _s.value.upper() == _env_value.upper():
                _selected_env = _s
                break

CURRENT_ENV: Settings = _selected_env
CURRENT_SETTINGS: SettingsDetails = SETTINGS.get(
    CURRENT_ENV, SETTINGS[Settings.DEVELOPMENT]
)


def get_settings(env: Settings = Settings.DEVELOPMENT) -> SettingsDetails:
    return SETTINGS.get(env, SETTINGS[Settings.DEVELOPMENT])
