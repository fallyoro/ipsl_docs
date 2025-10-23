from typing import List
from src.models.document import Document
from sqlmodel import SQLModel, Field, Relationship, null

# from src.models.document import Document
from datetime import datetime, timezone
from uuid import uuid4, UUID


class User(SQLModel, table=True):
    __tablename__ = "users"  # type: ignore
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    user_name: str
    classe: str
    password_hash: str
    notification_token: str = Field(default=None, nullable=True)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        sa_column_kwargs={"onupdate": lambda: datetime.now(timezone.utc)},
    )
    # documents: List["Document"] = Relationship(back_populates="user")
