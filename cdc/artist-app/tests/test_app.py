from app.main import create_app
from domain import schema, data
from fastapi import FastAPI
from pytest_mock import MockerFixture
from fastapi.testclient import TestClient
from fastapi_sqlalchemy import db
from sqlalchemy.orm.query import Query
import pytest
import datetime
import os


@pytest.fixture
def client(mocker: MockerFixture) -> TestClient:
    mocker.patch.dict(os.environ, {"DATABASE_URL": "postgresql://fake"})
    return TestClient(create_app())


class TestApp:

    def test_app_runs(self, client) -> None:
        assert client.app is not None

    def test_get_artist(self,
                        mocker: MockerFixture,
                        client: TestClient) -> None:
        artist_id = 1
        expected = data.Artist(
                artist_id=artist_id,
                artist_name="Tanith",
                created_at=datetime.datetime.now(),
                updated_at=datetime.datetime.now(),
            )
        with mocker.patch.object(Query, "get", return_value=expected):
            response = client.get(f"/artist/{artist_id}")
        assert response.status_code == 200
        result = schema.Artist(**response.json())
        assert result.artist_name == expected.artist_name
        assert result.artist_id == expected.artist_id
