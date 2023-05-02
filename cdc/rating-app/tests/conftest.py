import pytest
from alembic import config, command
import testing.postgresql
from sqlalchemy import create_engine
from sqlalchemy import Engine
from sqlalchemy.orm import Session
from typing import Generator


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
