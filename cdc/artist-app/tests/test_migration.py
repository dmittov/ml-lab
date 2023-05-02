import testing.postgresql
from sqlalchemy import create_engine, text
from alembic import config, command
import pandas as pd


class TestMigration:
    def test_migration(self) -> None:
        with testing.postgresql.Postgresql() as pg:
            alembic_cfg = config.Config()
            alembic_cfg.set_main_option("script_location", "src:alembic")
            alembic_cfg.set_main_option("sqlalchemy.url", pg.url())
            command.upgrade(alembic_cfg, "head")
            engine = create_engine(pg.url())
            with engine.connect() as con:
                query = text("select * from alembic_version")
                df = pd.read_sql(sql=query, con=con)
        assert df.shape[0] > 0
