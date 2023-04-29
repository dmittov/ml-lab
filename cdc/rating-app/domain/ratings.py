from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.sql import func

Base = declarative_base()


class User(Base):
    __tablename__ = "user"
    user_id = Column(Integer, primary_key=True, index=True)
    # keep it simple, no first/last names, it's not a real app
    user_name = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_dt = Column(DateTime(timezone=True), onupdate=func.now())


class Artist(Base):
    __tablename__ = "artist"
    artist_id = Column(Integer, primary_key=True, index=True)
    artist_name = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_dt = Column(DateTime(timezone=True), onupdate=func.now())


class Track(Base):
    __tablename__ = "track"
    track_id = Column(Integer, primary_key=True, index=True)
    artist_id = Column(Integer, ForeignKey(Artist.artist_id))
    track_name = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_dt = Column(DateTime(timezone=True), onupdate=func.now())


class Rating(Base):
    __tablename__ = "rating"
    track_id = Column(Integer, ForeignKey(Track.track_id), primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey(User.user_id), primary_key=True, index=True)
    stars = Column(Integer, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
