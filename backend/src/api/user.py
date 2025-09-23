from curses import use_default_colors
from datetime import timedelta
from dns import update
from fastapi import Depends, HTTPException, status, APIRouter
from fastapi.responses import JSONResponse
import uuid
from src.models.user import User
from src.schemas.user import UserCreate, UserOut, UserLogin, UserEdit
from src.services.user import UserService
from sqlmodel.ext.asyncio.session import AsyncSession
from src.database.database import create_session
from src.utils import create_acess_token, decode_token, passwd_context, verify_password
from typing import List


user_router = APIRouter()
user_service = UserService()


@user_router.put("/edit-profile")
async def edit_profile(
    user_data: UserEdit, session: AsyncSession = Depends(create_session)
):
    await user_service.update_user(
        session=session,
        user_name=user_data.user_name,
        new_classe=user_data.classe,
        new_user_name=user_data.new_user_name,
    )
    user = await user_service.get_user_by_user_name(
        user_name=user_data.user_name, session=session
    )
    return user


# @user_router.post("/sign-up", response_model=UserOut)
@user_router.post("/sign-up")
async def create_user(
    user_data: UserCreate, session: AsyncSession = Depends(create_session)
):
    user_exist = await user_service.user_exist(
        user_name=user_data.user_name, session=session
    )
    if user_exist:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Ce nom d'utilisateur existe deja",
        )
    new_user = await user_service.create_user(user_data, session)
    number_contribution = await user_service.get_number_contribution(
        session=session, user_id=new_user.id
    )
    # new_user_out = UserOut(**new_user.model_dump(exclude={"password"}), number_contribution= number_contribution)
    new_user_out = UserOut(
        **new_user.model_dump(exclude={"password"}),
        number_contribution=number_contribution,
    )
    return new_user_out


@user_router.post("/login")
async def login_user(
    login_data: UserLogin, session: AsyncSession = Depends(create_session)
):
    user_name = login_data.user_name
    password = login_data.password

    user = await user_service.get_user_by_user_name(
        user_name=user_name, session=session
    )

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
            number_contribution = str(
                await user_service.get_number_contribution(
                    session=session, user_id=user.id
                )
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
                    },
                }
            )
    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED, detail="Identifiant invalide"
    )
