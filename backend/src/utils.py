from passlib.context import CryptContext
import datetime
from src.core.config import settings
import jwt
from datetime import datetime, timedelta
from uuid import uuid4
import logging


passwd_context = CryptContext(schemes=['bcrypt'])

ACCES_TOKEN_EXPIRY = 3600


def generate_passord_hash(password: str) -> str:
    hash = passwd_context.hash(password)
    return hash


def verify_password(password: str, hash: str) -> bool:
    return passwd_context.verify(secret=password, hash=hash)


def create_acess_token(user_data: dict, expiry: timedelta = None, refresh: bool = False) -> str:  # type: ignore
    payload = {}
    payload['user'] = user_data
    payload["exp"] = datetime.now() + (expiry or timedelta(seconds=ACCES_TOKEN_EXPIRY))

    
    payload['jti'] = str(uuid4())
    payload['refresh'] = refresh

    token = jwt.encode(
        payload=payload,
        key=settings.JWT_SECRET,
        algorithm=settings.JWT_ALGO
    )

    return token

def decode_token(token: str):
    try:
        token_data = jwt.decode(
            jwt=token,
            algorithms=settings.JWT_ALGO,
            key= settings.JWT_SECRET
        )
        return token_data
    except jwt.PyJWKSetError as e:
        logging.exception(e)
        return None
        

