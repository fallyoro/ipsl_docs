from datetime import timedelta
from fastapi import Depends, HTTPException, status, APIRouter
from fastapi.responses import JSONResponse
from google.oauth2 import id_token
from google.auth.transport import requests
from src.schemas.notification_token import NotificationToken
from src.schemas.user import (
    GoogleLoginRequest,
    UserCreate,
    UserOut,
    UserLogin,
    UserEdit,
)
from src.services.user import UserService
from sqlmodel.ext.asyncio.session import AsyncSession
from src.database.database import create_session
from src.utils import create_acess_token, decode_token, passwd_context, verify_password
from uuid import UUID
from src.core.config import settings

user_router = APIRouter()
user_service = UserService()


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


# @user_router.post("/sign-up", response_model=UserOut)
@user_router.post("/sign-up")
async def create_user(
    user_data: UserCreate, session: AsyncSession = Depends(create_session)
):
    user_exist = await user_service.user_exist(email=user_data.email, session=session)
    if user_exist:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Ce nom d'utilisateur existe deja",
        )
    new_user = await user_service.create_user(user_data, session)
    number_contribution = await user_service.get_number_contribution(
        session=session, user_id=new_user.id
    )
    new_user_out = UserOut(
        **new_user.model_dump(exclude={"password"}),
        number_contribution=number_contribution,
    )
    await user_service.update_token(
        token=user_data.fcm_token, email=user_data.email, session=session
    )
    return new_user_out


@user_router.post("/login")
async def login_user(
    login_data: UserLogin, session: AsyncSession = Depends(create_session)
):
    email = login_data.email
    password = login_data.password
    fcm_token = login_data.fcm_token
    await user_service.update_token(token=fcm_token, email=email, session=session)
    user = await user_service.get_user_by_email(email=email, session=session)
    if user:
        passwd_valid = verify_password(password, user.password_hash)  # type: ignore
        if passwd_valid:
            acess_token = create_acess_token(
                user_data={
                    "user_name": user.user_name,
                    "id": str(user.id),
                }
            )

            refresh_token = create_acess_token(
                user_data={"user_name": user.user_name, "id": str(user.id)},
                expiry=timedelta(days=2),
                refresh=True,
            )
            number_contribution = await user_service.get_number_contribution(
                session=session, user_id=user.id
            )
            return JSONResponse(
                content={
                    "message": "Login susseful",
                    "access_token": acess_token,
                    "refresh_token": refresh_token,
                    "user": {
                        "id": str(user.id),
                        "user_name": user.user_name,
                        "classe": user.classe,
                        "number_contribution": number_contribution,
                        "email": user.email,
                    },
                }
            )
    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED, detail="Identifiant invalide"
    )


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

    user = await user_service.find_user_by_google_id(google_id=sub, session=session)
    if user:
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
                    "number_contribution": number_contribution,
                },
            }
        )
    else:
        new_user = await user_service.create_user_from_google(
            google_id=sub,
            user_name=name,
            email=email,
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
                    "classe": new_user.classe,
                    "number_contribution": 0,
                },
            }
        )


@user_router.put("/update-fcm-token/{user_name}")
async def update_fcm_token(
    token: NotificationToken, user_name: str, session=Depends(create_session)
):
    try:
        await user_service.update_token(token.token, user_name, session)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Impossible d'enregistrer le token: {e}",
        )
