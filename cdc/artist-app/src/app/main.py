from fastapi import FastAPI
from fastapi_sqlalchemy import DBSessionMiddleware
from app.routers import artist
import os


def create_app() -> FastAPI:
    app = FastAPI()
    app.add_middleware(
        DBSessionMiddleware,
        db_url=os.environ.get("DATABASE_URL", None)
    )
    app.include_router(artist.router)
    return app


app = create_app()
