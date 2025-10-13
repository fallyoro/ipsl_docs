from firebase_admin import messaging
from typing import List


class NotificationService:
    def send_notification(self, tokens: List[str], path, user_name):
        if not tokens:
            return None
        notification_data = self.build_notification(path=path, user_name=user_name)
        message = messaging.MulticastMessage(
            notification=messaging.Notification(
                title=notification_data[0], body=notification_data[1]
            ),
            tokens=tokens,
        )
        response = messaging.send_each_for_multicast(message)
        return response

    def build_notification(self, path: str, user_name: str) -> List[str]:
        topic = path.split("/")[0]
        if topic == "Concours":
            title = "Nouveau document de concours disponible !"
            message = f"{user_name} a ajouté un document lié aux concours."
        elif topic == "Général":
            title = "Nouveau document partagé !"
            message = f"{user_name} vient de partager un nouveau document général."
        else:
            material = path.split("/")[1]
            type = path.split("/")[3]
            title = "Nouveau document pour ta classe !"
            message = f"{user_name} vient de partager un document de type {type} en {material}."
        return [title, message]
