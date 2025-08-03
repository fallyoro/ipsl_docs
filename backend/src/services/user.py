from sqlmodel.ext.asyncio.session import AsyncSession
from src.schemas.user import UserCreate, UserOut, UserBase
from src.models.user import User
from src.models.document import Document

from sqlmodel.ext.asyncio.session import AsyncSession
from sqlmodel import select
from sqlalchemy import update
from src.utils import generate_passord_hash
from uuid import UUID


class UserService:
    async def get_user_by_user_name(self, user_name: str, session: AsyncSession) -> User | None:
        statement = select(User).where(User.user_name == user_name)
        result = await session.exec(statement)
        user = result.first()
        return user
    
    
    async def update_user(self, session: AsyncSession, user_name: str, new_user_name: str, new_classe: str) -> None:
        statement = update(User).where(User.user_name == user_name).values(user_name = new_user_name, classe = new_classe) # type: ignore
        await session.exec(statement) # type: ignore
        await session.commit()  # Permet que les changements prennent effet
        
    
    async def get_number_contribution(self, user_id:UUID, session: AsyncSession) -> int:
        statement = select(Document).where(Document.user_id == user_id)
        result = await session.exec(statement)
        documents = result.all()
        return len(documents)
    

    

        
    async def user_exist(self, user_name: str, session: AsyncSession) -> bool:
        user = await self.get_user_by_user_name(user_name, session)
        return True if user else False

    async def create_user(self, user_data: UserCreate, session: AsyncSession):
        user_data_dict = user_data.model_dump()
        new_user = User(**user_data_dict)
        print(new_user)
        new_user.password_hash = generate_passord_hash(user_data_dict["password"])

        session.add(new_user)
        await session.commit()
        await session.refresh(new_user)  
        return new_user



