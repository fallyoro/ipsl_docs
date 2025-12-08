from curses import tparm
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
import time
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
    t0 = time.perf_counter()
    doc_data = DocumentCreate(user_id=user_id, path=path)  # type: ignore
    t1 = time.perf_counter()
    documents_path = Path(__file__).resolve().parent.parents[1] / "documents"
    documents_path.mkdir(parents=True, exist_ok=True)
    relative_path = Path(path)
    complete_path = documents_path / relative_path

    # Crée uniquement le dossier parent, pas le fichier
    complete_path.parent.mkdir(parents=True, exist_ok=True)
    print(f"[TIME] Préparation chemin: {time.perf_counter() - t1:.4f} sec")

    # Vérifie que ce n’est pas un dossier
    if complete_path.exists() and complete_path.is_dir():
        raise HTTPException(
            status_code=500, detail=f"{complete_path} est déjà un dossier"
        )

    t2 = time.perf_counter()
    document = await service.upload_doc(doc_data=doc_data, session=session)
    print(f"[TIME] Enregistrement BDD: {time.perf_counter() - t2:.4f} sec")

    t3 = time.perf_counter()
    with open(complete_path, "wb") as buffer:
        shutil.copyfileobj(doc.file, buffer)
    print(f"[TIME] Écriture fichier: {time.perf_counter() - t3:.4f} sec")

    t4 = time.perf_counter()
    user_service = UserService()
    user_name = await user_service.get_user_name(id=UUID(user_id), session=session)
    number_contribution = await user_service.get_number_contribution(
        session=session, user_id=UUID(user_id)
    )
    print(
        f"[TIME] Requêtes user_service (name + contrib): {time.perf_counter() - t4:.4f} sec"
    )

    t5 = time.perf_counter()

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
    print(f"[TIME] Récupération tokens: {time.perf_counter() - t5:.4f} sec")
    t6 = time.perf_counter()
    notification_service = NotificationService()
    background.add_task(
        notification_service.send_notification,
        tokens=tokens,
        path=path,
        user_name=user_name,
    )
    print(f"[TIME] Ajout tâche background: {time.perf_counter() - t6:.4f} sec")
    print(f"[TIME] Temps total route /upload: {time.perf_counter() - t0:.4f} sec")
    return {
        "id": document.id,
        "path": str(complete_path),
        "number_contribution": number_contribution,
        "updated_at": str(document.updated_at),
        # "succes_count": response.success_count,
        # "failure_count": response.failure_count,
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
