from pydantic import BaseModel, Field
from uuid import UUID, uuid4
from datetime import datetime
from typing import Optional

class DocumentBase(BaseModel):
    filename: str
    file_path: str
    file_type: str
    categorie: str


class DocumentOut(DocumentBase):
    id: UUID 
    upload_at: datetime

class DocumentIn(DocumentBase):
    upload_at: Optional[datetime] = None
