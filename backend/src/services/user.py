from sqlmodel.ext.asyncio.session import AsyncSession
from src.schemas.user import UserCreate
from src.models.user import User
from src.models.document import Document

from sqlmodel.ext.asyncio.session import AsyncSession
from sqlmodel import select, update
from src.utils import generate_passord_hash
from uuid import UUID


class UserService:
    async def get_user_by_id(self, id: UUID, session: AsyncSession) -> User | None:
        statement = select(User).where(User.id == id)
        result = await session.exec(statement)
        user = result.first()
        return user

    async def find_user_by_email(
        self, email: str, session: AsyncSession
    ) -> User | None:
        statement = select(User).where(User.email == email)
        result = await session.exec(statement)
        user = result.first()
        return user

    async def update_user(
        self, session: AsyncSession, user_id: UUID, new_user_name: str, new_classe: str
    ) -> None:
        statement = update(User).where(User.id == user_id).values(user_name=new_user_name, classe=new_classe)  # type: ignore
        await session.exec(statement)  # type: ignore
        await session.commit()

    async def get_number_contribution(
        self, user_id: UUID, session: AsyncSession
    ) -> int:
        statement = select(Document).where(Document.user_id == user_id)
        result = await session.exec(statement)
        documents = result.all()
        return len(documents)

    async def user_exist(self, email: str, session: AsyncSession) -> bool:
        user = await self.find_user_by_email(email, session)
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

    async def create_user_from_google(
        self,
        google_id: str,
        user_name: str,
        email: str,
        classe: str,
        notification_token: str,
        picture_url: str,
        session: AsyncSession,
    ) -> User:
        new_user = User(
            user_name=user_name,
            email=email,
            picture_url=picture_url,
            google_id=google_id,
            classe=classe,
            notification_token=notification_token,
        )
        session.add(new_user)
        await session.commit()
        await session.refresh(new_user)
        return new_user

    async def find_user_by_google_id(
        self, google_id: str, session: AsyncSession
    ) -> User | None:
        statement = select(User).where(User.google_id == google_id)
        result = await session.exec(statement)
        user = result.first()
        return user

    async def update_token(self, token: str, email: str, session: AsyncSession):
        statement = update(User).where(User.email == email).values(notification_token=token)  # type: ignore
        await session.exec(statement)  # type: ignore
        await session.commit()

    async def enable_upload_access(self, user_id: str, session: AsyncSession):
        id = UUID(user_id)
        statement = update(User).where(User.id == id).values(can_upload=True)  # type: ignore
        await session.exec(statement)  # type: ignore
        await session.commit()

    async def get_tokens(
        self, session: AsyncSession, classe: str | None = None
    ) -> list[str]:
        if classe:
            statement = select(User.notification_token).where(User.classe == classe)
        else:
            statement = select(User.notification_token)
        result = await session.exec(statement)
        tokens = [row for row in result.all() if row]
        return tokens

    async def get_user_name(self, id: UUID, session: AsyncSession) -> str | None:
        statement = select(User.user_name).where(User.id == id)
        result = await session.exec(statement)
        user_name = result.one_or_none()
        return user_name
