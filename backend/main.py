from contextlib import asynccontextmanager
from fastapi import FastAPI

from src.database.database import init_db

@asynccontextmanager 
async def life_span(app:FastAPI):
    print("Server start")
    await init_db()
    yield
    print('Server is stoped')


app = FastAPI(lifespan=life_span)