import pytest
from sqlalchemy.orm import Session
from domain.data import Artist
from sqlalchemy import Column


@pytest.fixture
def artist() -> Artist:
    return Artist(artist_name="Derrick May")


class TestArtist:
    def test_add_artist(self, local_session: Session, artist: Artist) -> None:
        local_session.add(artist)
        local_session.commit()
        assert artist.artist_id is not None

    def test_id_is_set(self, session: Session, artist: Artist) -> None:
        session.add(artist)
        session.flush()
        session.refresh(artist)
        assert artist.artist_id is not None

    def test_created_at(self, session: Session, artist: Artist) -> None:
        session.add(artist)
        session.flush()
        session.refresh(artist)
        assert artist.created_at is not None

    def test_new_updated_at(self, session: Session, artist: Artist) -> None:
        session.add(artist)
        session.flush()
        session.refresh(artist)
        assert artist.updated_at == artist.created_at 

    def test_upd_updated_at(self, 
                            local_session: Session, 
                            artist: Artist) -> None:
        local_session.add(artist)
        local_session.commit()
        artist.artist_name = "May, Derrick"
        local_session.commit()
        assert artist.updated_at > artist.created_at