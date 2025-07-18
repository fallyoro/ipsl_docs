from pydantic import BaseModel, Field
from uuid import UUID, uuid4
from datetime import datetime
from typing import Optional
from src.models.document import Document

'''
 __tablename__ = "documents"
    id: UUID = Field(primary_key=True, default_factory=uuid4)
    
    filename: str
 
   
    upload_at: datetime = Field(default_factory= lambda: datetime.now(timezone.utc))
    user_id: UUID = Field(foreign_key="users.id")
    # user: "User" = Relationship(back_populates="documents")
'''

class DocumentBase(BaseModel):
    filename: str
    classe: str
    subject: str
    year: int 
    categorie: str
    user_id: UUID

class DocumentDownload(DocumentBase):
    id: UUID 

class DocumentOut(DocumentBase):
    id: UUID 
    upload_at: datetime

class DocumentIn(DocumentBase):
    pass
