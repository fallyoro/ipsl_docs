from pydantic import BaseModel


class NotificationToken(BaseModel):
    token: str
    user_name: str
