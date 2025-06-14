from pydantic import BaseModel
from uuid import UUID
from datetime import datetime

class UserBase(BaseModel):
    nom: str
    prenom: str
    email: str
    password: str
    classe: str
    
'''class User(BaseModel):
    nom: str
    prenom: str
    email: str
    password: str
    classe: str'''

    
    
class UserUpdate(UserBase):
    pass

class UserCreate(UserBase):
    pass
    
class UserOut(BaseModel):
    id: UUID
    nom: str
    prenom: str
    email: str
    password_hash: str
    created_at: datetime
    updated_at: datetime
    
    
class UserLogin(BaseModel):
    password: str
    email: str
    