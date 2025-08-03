from pydantic import BaseModel
from uuid import UUID
from datetime import datetime




class DocumentBase(BaseModel):
    filename: str
    classe: str
    subject: str
    year: str 
    categorie: str
    user_id: UUID

class DocumentDownload(DocumentBase):
    id: UUID 

class DocumentOut(DocumentBase):
    id: UUID 
    upload_at: datetime

class DocumentIn(DocumentBase):
    pass
