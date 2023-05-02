from app.main import create_app
from domain import schema, data
from pytest_mock import MockerFixture
from fastapi.testclient import TestClient
from sqlalchemy.orm.query import Query
from sqlalchemy.orm import Session
from sqlalchemy import Engine
import pytest
import datetime
import os


@pytest.fixture
def artist() -> schema.Artist:
    return schema.Artist(
        artist_id=1,
        artist_name="Tanith",
    )


@pytest.fixture
def client(mocker: MockerFixture) -> TestClient:
    dsn = "postgresql+psycopg2://user:pass@fakehost/fakedb"
    mocker.patch.dict(os.environ, {"DATABASE_URL": dsn})
    mocker.patch("sqlalchemy.create_engine")
    mocker.patch.object(Engine, "__new__")
    return TestClient(create_app())


class TestApp:

    def test_app_runs(self, client) -> None:
        assert client.app is not None

    def test_get_existing_artist(self,
                                 mocker: MockerFixture,
                                 client: TestClient) -> None:
        artist_id = 1
        expected = data.Artist(
                artist_id=artist_id,
                artist_name="Tanith",
                created_at=datetime.datetime.now(),
                updated_at=datetime.datetime.now(),
            )
        mocker.patch.object(Query, "get", return_value=expected)
        response = client.get(f"/artist/{artist_id}")
        assert response.status_code == 200
        result = schema.Artist(**response.json())
        assert result.artist_name == expected.artist_name
        assert result.artist_id == expected.artist_id

    def test_get_not_existing_artist(self,
                                     mocker: MockerFixture,
                                     client: TestClient) -> None:
        artist_id = 1
        mocker.patch.object(Query, "get", return_value=None)
        response = client.get(f"/artist/{artist_id}")
        assert response.status_code == 404

    def test_add_artist_ok(self,
                           artist: schema.Artist,
                           mocker: MockerFixture,
                           client: TestClient) -> None:
        artist.artist_id = None
        add_mock = mocker.MagicMock()
        commit_mock = mocker.MagicMock()
        mocker.patch.multiple(
            Session,
            add=add_mock,
            commit=commit_mock,
        )
        response = client.post("/artist", json=artist.dict())
        assert response.status_code == 200
        assert add_mock.call_count == 1
        assert commit_mock.call_count == 1

    def test_add_artist_with_id(self,
                                artist: schema.Artist,
                                client: TestClient) -> None:
        response = client.post("/artist", json=artist.dict())
        response.status_code == 422

    def test_delete_existing_artist(self,
                           artist: schema.Artist,
                           client: TestClient,
                           mocker: MockerFixture) -> None:
        db_return = data.Artist(**artist.dict())
        mocker.patch.object(Query, "get", return_value=db_return)
        delete_mock = mocker.MagicMock()
        commit_mock = mocker.MagicMock()
        mocker.patch.multiple(
            Session,
            delete=delete_mock,
            commit=commit_mock,
        )
        response = client.delete(f"/artist/{artist.artist_id}")
        assert response.status_code == 200
        assert delete_mock.call_count == 1
        assert commit_mock.call_count == 1

    def test_delete_not_existing_artist(self,
                           artist: schema.Artist,
                           client: TestClient,
                           mocker: MockerFixture) -> None:
        mocker.patch.object(Query, "get", return_value=None)
        delete_mock = mocker.MagicMock()
        commit_mock = mocker.MagicMock()
        mocker.patch.multiple(
            Session,
            delete=delete_mock,
            commit=commit_mock,
        )
        response = client.delete(f"/artist/{artist.artist_id}")
        assert response.status_code == 200
        assert delete_mock.call_count == 0
        assert commit_mock.call_count == 0


    def test_update_not_existing_artist(self,
                           artist: schema.Artist,
                           client: TestClient,
                           mocker: MockerFixture) -> None:
        mocker.patch.object(Query, "get", return_value=None)
        delete_mock = mocker.MagicMock()
        commit_mock = mocker.MagicMock()
        mocker.patch.multiple(
            Session,
            delete=delete_mock,
            commit=commit_mock,
        )
        response = client.delete(f"/artist/{artist.artist_id}")
        assert response.status_code == 200
        assert delete_mock.call_count == 0
        assert commit_mock.call_count == 0