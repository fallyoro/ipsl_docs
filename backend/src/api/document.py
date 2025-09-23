from fastapi import APIRouter, File, Form, HTTPException, UploadFile, Depends, status
from sqlmodel.ext.asyncio.session import AsyncSession
from src.database.database import create_session
from typing import List
from src.services.document import DocumentService
from fastapi.responses import FileResponse
import shutil
from pathlib import Path
from src.schemas.document import DocumentDownload, DocumentIn
from uuid import UUID
from src.services.user import UserService

service = DocumentService()
doc_router = APIRouter()


@doc_router.get("/documents", response_model=List[DocumentDownload])
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
    filename: str = Form(...),
    classe: str = Form(...),
    subject: str = Form(...),
    year: str = Form(...),
    categorie: str = Form(...),
    user_id: str = Form(...),
    doc: UploadFile = File(...),
    session: AsyncSession = Depends(create_session),
):

    doc_data = DocumentIn(
        filename=filename,
        year=year,
        classe=classe,
        categorie=categorie,
        subject=subject,
        user_id=user_id,  # type: ignore
    )

    documents_path = Path(__file__).resolve().parent.parents[1] / "documents"
    documents_path.mkdir(parents=True, exist_ok=True)

    complete_path = (
        documents_path
        / doc_data.classe
        / str(doc_data.year)
        / doc_data.subject
        / doc_data.categorie
        / doc_data.filename
    )

    # Crée uniquement le dossier parent, pas le fichier
    complete_path.parent.mkdir(parents=True, exist_ok=True)

    # Vérifie que ce n’est pas un dossier
    if complete_path.exists() and complete_path.is_dir():
        raise HTTPException(
            status_code=500, detail=f"{complete_path} est déjà un dossier"
        )

    # Upload si nécessaire
    # if not complete_path.is_file():
    # await service.upload_doc(doc_data=doc_data, session=session)
    document = await service.upload_doc(doc_data=doc_data, session=session)
    # Warning Vefrfkelvfe jv
    # Copie le contenu du fichier entrant
    with open(complete_path, "wb") as buffer:
        shutil.copyfileobj(doc.file, buffer)

    user_service = UserService()
    number_contribution = await user_service.get_number_contribution(
        session=session, user_id=UUID(user_id)
    )

    return {
        "filename": document.filename,
        "id": document.id,
        "path": str(complete_path),
        "number_contribution": number_contribution,
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

    documents_path = Path(__file__).resolve().parent.parents[1] / "documents"
    complete_path = documents_path / Path(doc_path)

    if complete_path.is_file():
        return FileResponse(
            path=complete_path,
            media_type="application/octet-stream",
            filename=complete_path.name,
        )

    raise HTTPException(
        status_code=404,
        detail={"error": "file not found", "file_path": str(complete_path)},
    )
