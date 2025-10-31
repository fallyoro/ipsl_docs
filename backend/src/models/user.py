from typing import Optional
from sqlmodel import SQLModel, Field
from datetime import datetime, timezone
from uuid import uuid4, UUID


class User(SQLModel, table=True):
    __tablename__: str = "users"
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    email: str = Field(index=True, unique=True)
    user_name: str
    classe: str
    password_hash: Optional[str] = None
    notification_token: str = Field(default=None, nullable=True)
    google_id: Optional[str] = Field(default=None, unique=True)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        sa_column_kwargs={"onupdate": lambda: datetime.now(timezone.utc)},
    )
