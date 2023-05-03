import pytest
from pytest_mock import MockerFixture
from fastapi.testclient import TestClient
from app.main import create_app
import os


@pytest.fixture(scope="session")
def client(session_mocker: MockerFixture) -> TestClient:
    dsn = "postgresql+psycopg2://user:pass@fakehost/fakedb"
    session_mocker.patch.dict(os.environ, {"DATABASE_URL": dsn})
    return TestClient(create_app())
