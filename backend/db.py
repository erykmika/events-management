from sqlmodel import SQLModel

from .auth.models import *
from .events.models import *
from sqlmodel import create_engine
from .settings import get_settings


settings = get_settings()
engine = create_engine(settings.database_url)

SQLModel.metadata.create_all(engine)
