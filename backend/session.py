from sqlmodel import Session


def get_engine():
    from backend.db import engine

    return engine


def get_session():
    with Session(get_engine()) as session:
        yield session
