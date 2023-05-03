import pytest
from alembic import config, command
import testing.postgresql
from sqlalchemy import create_engine
from sqlalchemy import Engine
from sqlalchemy.orm import Session
from typing import Generator
from pytest_mock import MockerFixture
from fastapi.testclient import TestClient
from sqlalchemy import Engine
from app.main import create_app
import os


@pytest.fixture(scope="session")
def engine() -> Generator[Engine, None, None]:
    with testing.postgresql.Postgresql() as pg:
        alembic_cfg = config.Config()
        alembic_cfg.set_main_option("script_location", "src:alembic")
        alembic_cfg.set_main_option("sqlalchemy.url", pg.url())
        command.upgrade(alembic_cfg, "head")
        engine = create_engine(pg.url())
        yield engine


@pytest.fixture
def local_engine() -> Generator[Engine, None, None]:
    """Significant performance overhead, pls use only when performing commits
    in tests"""
    with testing.postgresql.Postgresql() as pg:
        alembic_cfg = config.Config()
        alembic_cfg.set_main_option("script_location", "src:alembic")
        alembic_cfg.set_main_option("sqlalchemy.url", pg.url())
        command.upgrade(alembic_cfg, "head")
        engine = create_engine(pg.url())
        yield engine


@pytest.fixture
def local_session(local_engine: Engine) -> Generator[Session, None, None]:
    with Session(local_engine) as session:
        yield session
        session.commit()


@pytest.fixture
def session(engine: Engine) -> Generator[Session, None, None]:
    with Session(engine) as session:
        yield session
        session.rollback()


@pytest.fixture(scope="class")
def client(class_mocker: MockerFixture) -> TestClient:
    """FastAPI tests mock SQLAlchemy engine creation, therefore it makes
    sense to use this fixture on a module/class, but not on a session level
    """
    dsn = "postgresql+psycopg2://user:pass@fakehost/fakedb"
    class_mocker.patch.dict(os.environ, {"DATABASE_URL": dsn})
    class_mocker.patch("sqlalchemy.create_engine")
    class_mocker.patch.object(Engine, "__new__")
    return TestClient(create_app())
