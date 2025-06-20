from pydantic import BaseModel, Field
from uuid import UUID, uuid4
from datetime import datetime
from typing import Optional
from src.models.document import Document

class DocumentBase(BaseModel):
    filename: str
    file_path: str
    file_type: str
    categorie: str
    user_id: UUID

class DocumentDownload(DocumentBase):
    id: UUID 

class DocumentOut(DocumentBase):
    id: UUID 
    upload_at: datetime

class DocumentIn(DocumentBase):
    pass
