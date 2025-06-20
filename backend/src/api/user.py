from datetime import timedelta
from fastapi import Depends, HTTPException, status, APIRouter
from fastapi.responses import JSONResponse
import uuid
from src.schemas.user import UserCreate, UserOut, UserLogin
from src.services.user import UserService
from sqlmodel.ext.asyncio.session import AsyncSession
from src.database.database import create_session
from src.utils import create_acess_token, decode_token, passwd_context, verify_password


user_router = APIRouter()
user_service = UserService()


@user_router.post("/sign-up", response_model=UserOut)
async def create_user(
    user_data: UserCreate, session: AsyncSession = Depends(create_session)
):
    email = user_data.email
    user_exist = await user_service.user_exist(email, session)
    if user_exist:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User with this email already exist",
        )
    new_user = await user_service.create_user(user_data, session)
    
    return new_user

@user_router.post("/login")
async def login_user(login_data: UserLogin, session: AsyncSession = Depends(create_session)):
    email = login_data.email
    password = login_data.password
    
    user =  await user_service.get_user_by_email(email=email, session=session)
    
    if user:
        passwd_valid = verify_password(password, user.password_hash) # type: ignore
        if passwd_valid:
            acess_token = create_acess_token(
                user_data= {
                    'email': user.email,
                    'id': str(user.id) 
                }
            )
            
            refresh_token = create_acess_token(
                user_data= {
                    'email': user.email, 
                    'id': str(user.id) 
                },
                expiry= timedelta(days=2),
                refresh=True
            )
            
            return JSONResponse(
                content= {
                    "message": "Login susseful",
                    "acess_token": acess_token,
                    "refresh_token": refresh_token,
                    "user" : {
                        'email': user.email, 
                        'id': str(user.id) 
                    }
                }
            )
    raise HTTPException(
        status_code= status.HTTP_403_FORBIDDEN,
        detail="Login faild. Invalid email or password"
    )
    
