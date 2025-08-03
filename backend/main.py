from contextlib import asynccontextmanager
from fastapi import FastAPI
from src.api.user import user_router
from src.api.document import doc_router

from src.database.database import init_db

@asynccontextmanager 
async def life_span(app:FastAPI):
    print("Server start")
    await init_db()
    yield
    print('Server is stoped')


app = FastAPI(lifespan=life_span)

app.include_router(router=user_router, prefix="/auth", tags=["auth"])
app.include_router(router=doc_router, prefix="/document", tags=["documents"])