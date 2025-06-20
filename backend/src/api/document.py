from fastapi import APIRouter, File, Form, HTTPException, UploadFile, Depends,  status
from pathlib import Path as FilePath
from sqlmodel.ext.asyncio.session import AsyncSession
from src.database.database import create_session
from typing import List

from src.services.document import DocumentService
from fastapi.responses import FileResponse
import shutil
import os
from pathlib import Path
from src.schemas.document import DocumentBase, DocumentDownload, DocumentIn, DocumentOut
from uuid import UUID

service = DocumentService()
doc_router = APIRouter()


@doc_router.get("/documents", response_model= List[DocumentDownload])
async def get_all_documents( session: AsyncSession = Depends(create_session)):
    try:
        documents = await service.get_all_documents(session=session)
    except:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Faild to fetch document from database")
    return documents


@doc_router.post("/upload")
async def upload_doc(
    filename: str = Form(...),
    file_path: str = Form(...),
    file_type: str = Form(...),
    categorie: str = Form(...),
    user_id: str = Form(...),
    doc: UploadFile = File(...),
    session: AsyncSession = Depends(create_session)
):

    doc_data = DocumentIn(
        filename=filename,
        file_path=file_path,
        file_type=file_type,
        categorie=categorie,
        user_id=user_id
    )
    

    documents_path = Path(__file__).resolve().parent.parents[0] / "documents"


    documents_path.mkdir(parents=True, exist_ok=True)
    complete_path = documents_path / doc.filename

    if complete_path.is_file() == False:
        await service.upload_doc(doc_data=doc_data, session=session)

    with open(complete_path, "wb") as buffer:
        shutil.copyfileobj(doc.file, buffer)

    return {
        "filename": doc.filename,
        "path": complete_path
    }




@doc_router.get("/download/{doc_id}", responses={
    200: {
        "content": {"application/pdf": {}}
    }
})
async def download_doc(
    doc_id: str,
    session: AsyncSession = Depends(create_session)
):

    try:
        doc_uuid = UUID(doc_id)
    except ValueError:
        raise HTTPException(status_code=422, detail="doc_id must be a valid UUID (GUID)")

   
    result = await service.get_document_path(id=doc_uuid, session=session)
    doc_path = result.first()

    if not doc_path:
        raise HTTPException(status_code=404, detail="Document not found")

    documents_path = Path(__file__).resolve().parent.parents[0] / "documents"
    documents_path.mkdir(parents=True, exist_ok=True)
    complete_path = documents_path / Path(doc_path).name
    complete_path = Path(complete_path)

    if complete_path.is_file():
        return FileResponse(path=complete_path, media_type="application/pdf")

    raise HTTPException(status_code=404, detail={
        "error" : "file not found",
        "file_path" : f'{complete_path}'
    })

 
