import pytest
from sqlalchemy import create_engine
from sqlmodel import Session, SQLModel
from starlette.testclient import TestClient

import backend.session
import backend.auth
from backend.main import app

TEST_DB_URL = "sqlite:///pytest_db.sql"


@pytest.fixture(scope="session")
def test_client():
    engine = create_engine(TEST_DB_URL, connect_args={"check_same_thread": False})

    def get_test_session():
        with Session(engine) as session:
            yield session

    # Override dependencies
    app.dependency_overrides[backend.session.get_engine] = lambda: engine
    app.dependency_overrides[backend.session.get_session] = get_test_session
    app.dependency_overrides[backend.auth.verify_token] = lambda: True

    SQLModel.metadata.create_all(engine)
    client = TestClient(app)

    yield client, engine

    client.close()
    SQLModel.metadata.drop_all(bind=engine)
    engine.dispose()
