from pydantic import BaseModel
from uuid import UUID
from datetime import datetime

class UserBase(BaseModel):
    user_name: str
    email: str
    password: str
    classe: str
    

    
    
class UserUpdate(UserBase):
    pass

class UserCreate(UserBase):
    pass
    
class UserOut(UserBase):
    id: UUID
    user_name: str
    email: str
    classe: str
    
    class Config:
        orm_mode = True
    
    
class UserLogin(BaseModel):
    password: str
    email: str
    