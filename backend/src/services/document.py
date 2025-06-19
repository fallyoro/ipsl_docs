from sqlmodel import select
from sqlmodel.ext.asyncio.session import AsyncSession
from src.models.document import Document
from src.schemas.document import DocumentIn, DocumentOut, DocumentDownload
from uuid import UUID


class DocumentService:
    async def get_document_path(self, id: UUID, session: AsyncSession ):
        statement = select(Document.filename).where(Document.id == id)
        result = await session.exec(statement)
        return result
    
    async def get_all_documents(self, session: AsyncSession ):
        statement = select(Document)
        result = await session.exec(statement)
        return result.all()
    
    async def upload_doc(self, session: AsyncSession, doc_data : DocumentIn):
        doc_data_dict = doc_data.model_dump()
        new_doc = Document(**doc_data_dict)
        session.add(new_doc)
        await session.commit()
        return new_doc
