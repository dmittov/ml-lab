from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import declarative_base
from sqlalchemy.sql import func

Base = declarative_base()


class Artist(Base):
    __tablename__ = "artist"
    artist_id = Column(Integer, primary_key=True, index=True)
    artist_name = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), 
                        server_default=func.now(), 
                        onupdate=func.now())
