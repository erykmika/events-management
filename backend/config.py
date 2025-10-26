from enum import StrEnum, auto
from pydantic import BaseModel


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


def get_settings(env: Settings = Settings.DEVELOPMENT) -> SettingsDetails:
    return SETTINGS.get(env, SETTINGS[Settings.DEVELOPMENT])
