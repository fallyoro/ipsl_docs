import redis.asyncio as redis
from src.core.config import settings

JTI_EXPIRY = 3600

redis_client = redis.Redis(
    host=settings.REDIS_HOST,
    port=settings.REDIS_PORT,
    db=0
)


async def add_jit(jti: str):
    redis_client.set(name=jti, value="", ex=JTI_EXPIRY)
    
async def add_blacklist_jti(jti: str):
    key = f"blacklist:refresh:{jti}"
    await redis_client.set(name=key,value= "revoked", ex=JTI_EXPIRY)
    
async def is_black_list_jti(jti: str):
    key = f"blacklist:refresh:{jti}"
    return await redis_client.exists(names=key) # pyright: ignore[reportCallIssue]