from sqlmodel import select
from sqlmodel.ext.asyncio.session import AsyncSession
from src.models.document import Document
from src.schemas.document import DocumentIn, DocumentOut, DocumentDownload
from uuid import UUID
from pathlib import Path


class DocumentService:
    async def get_document_path(self, id: UUID, session: AsyncSession):
        statement = select(Document.classe, Document.year, Document.subject,Document.categorie, Document.filename).where(Document.id == id) # type: ignore
        result = await session.exec(statement)
        row = result.first()
        if row:
            classe, year, subject, categorie, filename = row
            path = Path(classe) / Path(str(year)) / Path(subject) / Path(categorie) / Path(filename)
            return str(path)
        return None

    async def get_document_by_id(self, id: UUID, session: AsyncSession):
        statement = select(Document).where(Document.id == id)
        result = await session.exec(statement)
        return result.first()
        
    async def get_all_documents(self, session: AsyncSession):
        statement = select(Document)
        result = await session.exec(statement)
        return result.all()
    
    

    async def upload_doc(self, session: AsyncSession, doc_data: DocumentIn):
        doc_data_dict = doc_data.model_dump()
        new_doc = Document(**doc_data_dict)
        session.add(new_doc)
        await session.commit()
        await session.refresh(new_doc)
        return new_doc
