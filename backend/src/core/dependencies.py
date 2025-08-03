
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.exceptions import HTTPException
from src.utils import decode_token
from fastapi import Request
from src.database.redis import redis_client, is_black_list_jti


class TokenBearer(HTTPBearer):
    
    def __init__(self, auto_error = True):
        super().__init__(auto_error=auto_error)

    async def __call__(self, request: Request):
        credentials: HTTPAuthorizationCredentials = await super().__call__(request) # pyright: ignore[reportAssignmentType]
        token = credentials.credentials

        token_data = decode_token(token)
        if not token_data:
            raise HTTPException(status_code=403, detail="Invalid token")
        
        if is_black_list_jti(token_data['jti']):
            raise HTTPException(status_code=403, detail={
                "error" :"This token is revoked",
                "resolution" : "Please login"
            })
        
        self.verify_token_data

        return token_data
    
    def verify_token_data(self, token_data: dict):
        raise NotImplemented('Please overide this methode') # type: ignore


class AccesTokenBearer(TokenBearer):
    def verify_token_data(self, token_data: dict) -> None:
        if token_data and token_data.get("refresh"):
            raise HTTPException(
                status_code=403, detail="Please provide an access token")


class RefreshTokenBearer(TokenBearer):
    def verify_token_data(self, token_data: dict) -> None:
        if token_data and not token_data.get("refresh"):
            raise HTTPException(
                status_code=403, detail="Please provide an refresh token")


'''
token_data["refresh"] → lèvera une erreur si "refresh" n'existe pas ❌

token_data.get("refresh") → retourne None si elle n'existe pas ✅
'''
