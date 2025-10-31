from pydantic import BaseModel
from uuid import UUID


class UserBase(BaseModel):
    user_name: str
    password: str
    classe: str
    # notification_token: str


class UserEdit(BaseModel):
    id :UUID
    new_user_name: str
    classe: str


class UserUpdate(UserBase):
    pass


class UserCreate(UserBase):
    pass
    email: str
    fcm_token: str


class GoogleLoginRequest(BaseModel):
    id_token: str
    fcm_token: str


class UserOut(BaseModel):
    id: UUID
    number_contribution: int
    user_name: str
    classe: str
    # notification_token: str


class UserLogin(BaseModel):
    email: str
    password: str
    fcm_token: str
