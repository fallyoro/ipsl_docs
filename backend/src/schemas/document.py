from pydantic import BaseModel
from uuid import UUID
from datetime import datetime


class DocumentBase(BaseModel):
    user_id: UUID
    path: str


class DocumentDownload(DocumentBase):
    id: UUID


class DocumentOut(DocumentBase):
    id: UUID
    upload_at: datetime


class DocumentIn(DocumentBase):
    pass
