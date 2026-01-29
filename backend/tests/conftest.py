import pytest
from sqlalchemy import create_engine
from sqlmodel import Session, SQLModel
from starlette.testclient import TestClient
from unittest.mock import Mock

import backend.session
import backend.auth
import backend.s3
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


@pytest.fixture(autouse=True)
def _mock_s3_client():
    mock_client = Mock()
    mock_client.head_bucket = Mock()
    mock_client.create_bucket = Mock()
    mock_client.upload_fileobj = Mock()
    mock_client.generate_presigned_url = Mock(return_value="")

    backend.s3.s3 = mock_client
    yield
    backend.s3.s3 = None
