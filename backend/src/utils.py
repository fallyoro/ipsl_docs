from passlib.context import CryptContext
import datetime
from src.core.config import settings
import jwt

from datetime import datetime, timedelta
from uuid import uuid4
import logging

passwd_context = CryptContext(schemes=['bcrypt'])

ACCES_TOKEN_EXPIRY = 3600


def generate_passord_hash(password: str):
    hash = passwd_context.hash(password)
    return hash


def verify_password(password: str, hash: str) -> bool:
    return passwd_context.verify(secret=password, hash=hash)


def create_acess_token(user_data: dict, expiry: timedelta = None, refresh: bool = False): # type: ignore
    playload = {}
    playload['user'] = user_data
    playload["exp"] = datetime.now() + (expiry or timedelta(seconds=ACCES_TOKEN_EXPIRY))

    token = jwt.encode(
        payload=playload,
        key=settings.JWT_SECRET,
        algorithm=settings.JWT_ALGO
    )
    playload['jti'] = str(uuid4())
    playload['refresh'] = refresh

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
        
