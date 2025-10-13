from pydantic import BaseModel
from uuid import UUID


class UserBase(BaseModel):
    user_name: str
    password: str
    classe: str
    # notification_token: str


class UserEdit(BaseModel):
    user_name: str
    new_user_name: str
    classe: str


class UserUpdate(UserBase):
    pass


class UserCreate(UserBase):
    pass


class UserOut(BaseModel):
    id: UUID
    number_contribution: int
    user_name: str
    classe: str
    # notification_token: str


class UserLogin(BaseModel):
    password: str
    user_name: str
    fcm_token: str
