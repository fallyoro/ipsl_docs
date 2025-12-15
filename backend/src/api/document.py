import aiofiles
from fastapi import (
    APIRouter,
    File,
    Form,
    HTTPException,
    UploadFile,
    Depends,
    status,
    BackgroundTasks,
)
from sqlmodel.ext.asyncio.session import AsyncSession
from src.database.database import create_session
from typing import List
from src.services.document import DocumentService
from fastapi.responses import FileResponse
import shutil
from pathlib import Path
from src.schemas.document import DocumentOut, DocumentCreate
from uuid import UUID
from src.services.user import UserService
from src.services.notification import NotificationService
from firebase_admin import messaging


service = DocumentService()
doc_router = APIRouter()


@doc_router.get("/documents", response_model=List[DocumentOut])
async def get_all_documents(session: AsyncSession = Depends(create_session)):
    try:
        documents = await service.get_all_documents(session=session)
    except:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Faild to fetch document from database",
        )
    return documents


@doc_router.post("/upload")
async def upload_doc(
    background: BackgroundTasks,
    path: str = Form(...),
    user_id: str = Form(...),
    doc: UploadFile = File(...),
    session: AsyncSession = Depends(create_session),
):
    doc_data = DocumentCreate(user_id=user_id, path=path)  # type: ignore
    documents_path = Path(__file__).resolve().parent.parents[1] / "documents"
    documents_path.mkdir(parents=True, exist_ok=True)
    relative_path = Path(path)
    if ".." in relative_path.parts:
        raise HTTPException(status_code=400, detail="Invalid path")
    complete_path = documents_path / relative_path

    ALLOWED_MIME_TYPES = {
        "application/pdf",
        "image/png",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    }
    assert doc.filename is not None
    if doc.content_type not in ALLOWED_MIME_TYPES:
        raise HTTPException(status_code=400, detail="Invalid MIME type")

    # Crée uniquement le dossier parent, pas le fichier
    complete_path.parent.mkdir(parents=True, exist_ok=True)

    # Vérifie que ce n’est pas un dossier
    if complete_path.exists() and complete_path.is_dir():
        raise HTTPException(
            status_code=500, detail=f"{complete_path} est déjà un dossier"
        )

    document = await service.upload_doc(doc_data=doc_data, session=session)

    # with open(complete_path, "wb") as buffer:
    #     shutil.copyfileobj(doc.file, buffer)
    try:
        async with aiofiles.open(complete_path, "wb") as buffer:
            while content := await doc.read(1024 * 1024):
                await buffer.write(content)

    except Exception as e:
        await session.rollback()
        print(e)
        raise HTTPException(status_code=500, detail="Impossible d'uploader le fichier")
    finally:
        await doc.close()

    user_service = UserService()
    user_name = await user_service.get_user_name(id=UUID(user_id), session=session)
    number_contribution = await user_service.get_number_contribution(
        session=session, user_id=UUID(user_id)
    )

    topic = path.split("/")[0]
    print(f"=====================The path of the doc {path}")
    # Si le document est de type general ou concours une notification est envoye a tout le monde. Par contre
    # si elle est specifique a une classe la notif est envoye seulement aux concerne.
    if topic == "Concours" or topic == "Général":
        print(f"The topic is : {topic}")
        tokens = await user_service.get_tokens(session=session)
        tokens = list(set(tokens))

    else:
        tokens = await user_service.get_tokens(session=session, classe=topic)
        tokens = list(set(tokens))

    print(f"The list of tokens: {tokens}")
    notification_service = NotificationService()
    background.add_task(
        notification_service.send_notification,
        tokens=tokens,
        path=path,
        user_name=user_name,
    )

    return {
        "id": document.id,
        "path": str(complete_path),
        "number_contribution": number_contribution,
        "updated_at": str(document.updated_at),
    }


@doc_router.get(
    "/download/{doc_id}",
    response_class=FileResponse,
    responses={
        200: {
            "content": {"application/octet-stream": {}},
        }
    },
)
async def download_doc(doc_id: str, session: AsyncSession = Depends(create_session)):
    try:
        doc_uuid = UUID(doc_id)
    except ValueError:
        raise HTTPException(status_code=422, detail="doc_id must be a valid UUID")

    doc_path = await service.get_document_path(id=doc_uuid, session=session)
    if not doc_path:
        raise HTTPException(status_code=404, detail="Document not found")

    base_dir = Path(__file__).resolve().parent.parents[1] / "documents"
    full_path = base_dir / doc_path

    # if it's not a file we just throw an error
    if not full_path.is_file:
        raise HTTPException(
            status_code=404,
            detail={"error": "file not found", "file_path": str(full_path)},
        )

    return FileResponse(
        path=full_path,
        media_type="application/octet-stream",
        filename=full_path.name,
    )
