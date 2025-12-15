from sqlmodel import SQLModel
from sqlmodel.ext.asyncio.session import AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.asyncio import create_async_engine
from src.core.config import settings


engine = create_async_engine(url=settings.DATABASE_URL, echo=True)

SessionLocal = sessionmaker(
    bind=engine,  # type: ignore
    class_=AsyncSession,
    expire_on_commit=False,
)  # type: ignore


async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)


async def create_session():
    async with SessionLocal() as session:  # type: ignore
        yield session  # type: ignore
