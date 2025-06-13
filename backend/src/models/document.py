from sqlmodel import SQLModel, Field
from datetime import datetime, timezone
from uuid import uuid4, UUID



class DocumentBase(SQLModel, table = True):
    __tablename__ = "Documents"
    id: UUID = Field(primary_key=True, default_factory=uuid4)
    filename: str
    file_path: str
    file_type: str
    categorie: str
    upload_at: datetime = Field(default_factory= lambda: datetime.now(timezone.utc))