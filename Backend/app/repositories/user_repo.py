from sqlalchemy.orm import Session
from .. import models

class UserRepo:
    def __init__(self, db: Session):
        self.db = db

    def get_user_by_email(self, email: str):
        return self.db.query(models.User).filter(models.User.email == email).first()

    # دالة مضافة: بتلزمنا لجلب المستخدم عن طريق الـ ID تبعه
    def get_user_by_id(self, user_id: int):
        return self.db.query(models.User).filter(models.User.user_id == user_id).first()

    def create_user(self, user_data: dict):
        new_user = models.User(**user_data)
        self.db.add(new_user)
        self.db.commit()
        self.db.refresh(new_user)
        return new_user

    def update_user(self, user_id: int, update_data: dict):
        db_user = self.get_user_by_id(user_id)
        if db_user:
            for key, value in update_data.items():
                setattr(db_user, key, value)
            self.db.commit()
            self.db.refresh(db_user)
        return db_user