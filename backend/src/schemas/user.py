from pydantic import BaseModel
from uuid import uuid
from datetime import datetime

class UserBase(BaseModel):
    nom: str
    prenom: str
    email: str
    password: str
    classe: str

    
    
class UserUpdate(UserBase):
    pass

class UserCreate(UserBase):
    pass
    
class UserOut(BaseModel):
    id: uuid
    nom: str
    prenom: str
    email: str
    password_hash: str
    created_at: datetime
    updated_at: datetime
    