from sqlmodel import Relationship, SQLModel, Field
from datetime import datetime, timezone
from uuid import uuid4, UUID


class Document(SQLModel, table=True):
    __tablename__ = "documents"
    id: UUID = Field(primary_key=True, default_factory=uuid4)
    path: str
    upload_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    user_id: UUID = Field(foreign_key="users.id")
    # user: "User" = Relationship(back_populates="documents")
