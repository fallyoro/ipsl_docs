from pydantic import BaseModel


class NotificationToken(BaseModel):
    fcm_token: str
