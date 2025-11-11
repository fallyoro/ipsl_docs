from typing import Optional
from sqlmodel import SQLModel, Field
from datetime import datetime, timezone
from uuid import uuid4, UUID


class User(SQLModel, table=True):
    __tablename__: str = "users"
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    email: str = Field(index=True, unique=True, max_length=100)
    user_name: str = Field(max_length=100)
    picture_url: str = Field(max_length=100)
    classe: str = Field(max_length=100)
    password_hash: Optional[str] = Field(default=None, max_length=100)
    notification_token: str = Field(default=None, nullable=True, max_length=100)
    google_id: Optional[str] = Field(default=None, unique=True, max_length=100)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        sa_column_kwargs={"onupdate": lambda: datetime.now(timezone.utc)},
    )
