from pydantic import BaseModel
from uuid import UUID
from datetime import datetime


class DocumentBase(BaseModel):
    user_id: UUID
    path: str


class DocumentOut(DocumentBase):
    id: UUID
    upload_at: datetime
    is_deleted: bool
    updated_at: datetime


class DocumentCreate(DocumentBase):
    pass
