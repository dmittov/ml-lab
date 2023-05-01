import pytest
from sqlalchemy.orm import Session
from sqlalchemy import select
from domain.ratings import Artist


@pytest.fixture
def artist() -> Artist:
    return Artist(artist_name="Derrick May")


class TestRating:

    def test_add_artist(self, session: Session, artist: Artist) -> None:
        session.add(artist)
        stmt = (
            select(Artist)
            .where(Artist.artist_name == artist.artist_name)
        )
        rs = session.execute(stmt)
        found = rs.fetchall()
        assert len(found) == 1

    def test_id_is_set(self, session: Session, artist: Artist) -> None:
        session.add(artist)
        stmt = (
            select(Artist)
            .where(Artist.artist_name == artist.artist_name)
        )
        found_artist = session.execute(stmt).one()[0]
        assert found_artist.artist_id is not None

    def test_created_at(self, session: Session, artist: Artist) -> None:
        session.add(artist)
        stmt = (
            select(Artist)
            .where(Artist.artist_name == artist.artist_name)
        )
        found_artist = session.execute(stmt).one()[0]
        assert found_artist.created_at is not None

    def test_new_updated_at(self, session: Session, artist: Artist) -> None:
        session.add(artist)
        stmt = (
            select(Artist)
            .where(Artist.artist_name == artist.artist_name)
        )
        found_artist = session.execute(stmt).one()[0]
        assert found_artist.updated_dt is None

    def test_upd_updated_at(self, session: Session, artist: Artist) -> None:
        session.add(artist)
        stmt = (
            select(Artist)
            .where(Artist.artist_name == artist.artist_name)
        )
        artist = session.execute(stmt).one()[0]
        artist.artist_name = "May, Derrick"
        session.add(artist)
        stmt = (
            select(Artist)
            .where(Artist.artist_name == artist.artist_name)
        )
        found_artist = session.execute(stmt).one()[0]
        assert found_artist.updated_dt is not None
