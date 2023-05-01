import pytest
from alembic import config, command
import testing.postgresql
from sqlalchemy import create_engine
from sqlalchemy import Engine
from sqlalchemy.orm import Session


@pytest.fixture(scope="session")
def engine() -> Engine:
    with testing.postgresql.Postgresql() as pg:
        alembic_cfg = config.Config()
        alembic_cfg.set_main_option("script_location", "src:alembic")
        alembic_cfg.set_main_option("sqlalchemy.url", pg.url())
        command.upgrade(alembic_cfg, "head")
        engine = create_engine(pg.url())
        yield engine


@pytest.fixture
def session(engine: Engine) -> Session:
    with Session(engine) as session:
        yield session
        session.rollback()
