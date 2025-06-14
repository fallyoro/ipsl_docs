from sqlmodel.ext.asyncio.session import AsyncSession
from src.schemas.user import UserCreate, UserOut, UserBase
from src.models.user import User

from sqlmodel.ext.asyncio.session import AsyncSession
from sqlmodel import select
from src.utils import generate_passord_hash


class UserService:
    async def get_user_by_email(self, email: str, session: AsyncSession) -> User | None:
        statement = select(User).where(User.email == email)
        result = await session.exec(statement)
        user = result.first()
        return user

    async def user_exist(self, email: str, session: AsyncSession) -> bool:
        user = await self.get_user_by_email(email, session)
        return True if user else False

    async def create_user(self, user_data: UserCreate, session: AsyncSession):
        user_data_dict = user_data.model_dump()
        new_user = User(**user_data_dict)
        print(new_user)
        new_user.password_hash = generate_passord_hash(user_data_dict["password"])

        session.add(new_user)
        await session.commit()
        await session.refresh(new_user)  # ✅ recharge depuis la DB
        return new_user



