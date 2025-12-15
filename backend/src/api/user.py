from fastapi import Depends, HTTPException, status, APIRouter
from fastapi.responses import JSONResponse
from google.oauth2 import id_token
from google.auth.transport import requests
from src.schemas.notification_token import NotificationToken
from src.schemas.user import (
    GoogleLoginRequest,
    UserEdit,
)
from src.services.user import UserService
from sqlmodel.ext.asyncio.session import AsyncSession
from src.database.database import create_session
from uuid import UUID
from src.core.config import settings
import logging

user_router = APIRouter()
user_service = UserService()
logger = logging.getLogger(__name__)


@user_router.put("/edit-profile")
async def edit_profile(
    user_data: UserEdit, session: AsyncSession = Depends(create_session)
):
    await user_service.update_user(
        session=session,
        user_id=UUID(user_data.id),
        new_classe=user_data.classe,
        new_user_name=user_data.new_user_name,
    )
    user = await user_service.get_user_by_id(id=UUID(user_data.id), session=session)
    return user


@user_router.post("/google")
async def login_with_google(
    login_data: GoogleLoginRequest, session=Depends(create_session)
):
    CLIENT_ID = settings.CLIENT_ID
    idinfo = id_token.verify_oauth2_token(
        login_data.id_token,
        requests.Request(),
        audience=CLIENT_ID,
        clock_skew_in_seconds=3,
    )

    sub = idinfo["sub"]
    email = idinfo.get("email")
    name = (idinfo.get("name") or "").split(" ")[0]
    picture_url = idinfo.get("picture")

    fcm_token = login_data.fcm_token

    # user = await user_service.find_user_by_google_id(google_id=sub, session=session)
    user = await user_service.find_user_by_email(email=email, session=session)
    if user:
        await user_service.update_token(fcm_token, email, session)
        number_contribution = await user_service.get_number_contribution(
            user_id=user.id, session=session
        )
        return JSONResponse(
            content={
                "message": "Login susseful",
                "user": {
                    "id": str(user.id),
                    "user_name": user.user_name,
                    "email": user.email,
                    "classe": user.classe,
                    "picture_url": picture_url,
                    "number_contribution": number_contribution,
                },
            }
        )
    else:
        new_user = await user_service.create_user_from_google(
            google_id=sub,
            user_name=name,
            email=email,
            picture_url=picture_url,
            classe="Cpi1",
            notification_token=login_data.fcm_token,
            session=session,
        )
        return JSONResponse(
            content={
                "message": "Signup successful",
                "user": {
                    "id": str(new_user.id),
                    "email": new_user.email,
                    "user_name": new_user.user_name,
                    "picture_url": new_user.picture_url,
                    "classe": new_user.classe,
                    "number_contribution": 0,
                },
            }
        )


@user_router.put("/update-fcm-token/{email}")
async def update_fcm_token(
    email: str, token: NotificationToken, session=Depends(create_session)
):
    try:
        logger.info(f"The token is {token.fcm_token}")
        await user_service.update_token(token.fcm_token, email, session)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Impossible d'enregistrer le token: {e}",
        )
