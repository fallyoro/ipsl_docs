from contextlib import asynccontextmanager
from fastapi import FastAPI
from src.api.user import user_router
from src.api.document import doc_router
from src.database.database import init_db
from firebase_admin import credentials
import firebase_admin

cred = credentials.Certificate(
    "src/core/ipsldocs-firebase-adminsdk-fbsvc-f8f43c5a3f.json"
)


@asynccontextmanager
async def life_span(app: FastAPI):
    print("Server start")
    await init_db()
    firebase_admin.initialize_app(cred)
    yield
    print("Server is stoped")


app = FastAPI(lifespan=life_span)

app.include_router(router=user_router, prefix="/auth", tags=["auth"])
app.include_router(router=doc_router, prefix="/document", tags=["documents"])
