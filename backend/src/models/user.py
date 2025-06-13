from sqlmodel import SQLModel, Field
from datetime import datetime, timezone
from uuid import uuid4, UUID


class User(SQLModel, table=True):
    __tablename__ = "Users"
    id : UUID = Field(default_factory=uuid4, primary_key= True)
    nom: str
    prenom: str
    email: str
    password_hash: str
    created_at: datetime = Field(default_factory= lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        sa_column_kwargs={"onupdate": lambda: datetime.now(timezone.utc)}
    )