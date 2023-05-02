from fastapi import FastAPI, HTTPException
from fastapi_sqlalchemy import DBSessionMiddleware
from fastapi_sqlalchemy import db
from domain import data, schema
import os


def create_app() -> FastAPI:
    app = FastAPI()
    app.add_middleware(
        DBSessionMiddleware,
        db_url=os.environ.get("DATABASE_URL", None)
    )

    @app.get("/artist/{artist_id}", response_model=schema.Artist)
    async def get_user(artist_id: int) -> data.Artist:
        artist = db.session.query(data.Artist).get(artist_id)
        if artist is None:
            raise HTTPException(status_code=404, 
                                detail="No artist with id [{artist_id}] found")
        return artist


    @app.post("/artist", response_model=schema.Artist)
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


    @app.put("/artist/{artist_id}", response_model=schema.Artist)
    async def update_artist(artist: schema.Artist) -> data.Artist:
        db_artist = db.session.query(data.Artist).get(artist.artist_id)
        db_artist.artist_name = artist.artist_name
        db.session.commit()
        return db_artist


    @app.delete("/artist/{artist_id}", response_model=schema.Artist)
    async def delete_artist(artist_id: int) -> data.Artist:
        db_artist = db.session.query(data.Artist).get(artist_id)
        db.session.delete(db_artist)
        db.session.commit()
        return db_artist


    return app


app = create_app()
