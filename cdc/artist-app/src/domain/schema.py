from pydantic import BaseModel
from typing import Optional

class Artist(BaseModel):
    artist_id: Optional[int] = None
    artist_name: str

    class Config:
        orm_mode = True
