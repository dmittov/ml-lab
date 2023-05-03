from fastapi import APIRouter, HTTPException
from fastapi_sqlalchemy import db
from domain import data, schema

router = APIRouter(
    prefix="/artist",
    tags=["artist"],
)

class ErrorMessages:
    @staticmethod
    def get_no_artist_msg(artist_id: int) -> str:
        return f"No artist with id [{artist_id}] found"


@router.get("/{artist_id}", response_model=schema.Artist)
async def get_user(artist_id: int) -> data.Artist:
    artist = db.session.query(data.Artist).get(artist_id)
    if artist is None:
        raise HTTPException(status_code=404, 
                            detail=ErrorMessages.get_no_artist_msg(artist_id))
    return artist


@router.post("/", response_model=schema.Artist)
async def create_user(artist: schema.Artist) -> data.Artist:
    if artist.artist_id is not None:
        raise HTTPException(status_code=422, 
                            detail="Attribute artist_id is not expected.")
    artist = data.Artist(
        artist_name=artist.artist_name
    )
    db.session.add(artist)
    db.session.commit()
    return artist


@router.put("/", response_model=schema.Artist)
async def update_artist(artist: schema.Artist) -> data.Artist:
    db_artist = db.session.query(data.Artist).get(artist.artist_id)
    if db_artist is None:
        raise HTTPException(
            status_code=404,
            detail=ErrorMessages.get_no_artist_msg(artist.artist_id)
        )
    db_artist.artist_name = artist.artist_name
    db.session.commit()
    return db_artist


@router.delete("/{artist_id}", response_model=schema.Artist)
async def delete_artist(artist_id: int) -> data.Artist:
    db_artist = db.session.query(data.Artist).get(artist_id)
    if db_artist is None:
        raise HTTPException(status_code=404, 
                            detail=ErrorMessages.get_no_artist_msg(artist_id))
    db.session.delete(db_artist)
    db.session.commit()
    return db_artist
