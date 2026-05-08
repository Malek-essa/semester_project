from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import date
from .. import models

class ProgressRepo:
    def __init__(self, db: Session):
        self.db = db

    def get_today_water_sum(self, user_id: int, today: date):
        # استعلام يجمع كل الماء المشروب لليوم الحالي
        result = self.db.query(func.sum(models.WaterLog.amount_ml)).filter(
            models.WaterLog.user_id == user_id,
            models.WaterLog.log_date == today
        ).scalar()
        return result or 0

    def get_today_sleep_sum(self, user_id: int, today: date):
        result = self.db.query(func.sum(models.SleepLog.total_hours)).filter(
            models.SleepLog.user_id == user_id,
            models.SleepLog.log_date == today
        ).scalar()
        return result or 0.0

    def check_achievement_exists(self, user_id: int, ach_type: str, today: date):
        return self.db.query(models.Achievement).filter(
            models.Achievement.user_id == user_id,
            models.Achievement.type == ach_type,
            models.Achievement.achieved_date == today
        ).first()

    def add_achievement(self, user_id: int, title: str, ach_type: str, today: date):
        ach = models.Achievement(user_id=user_id, title=title, type=ach_type, achieved_date=today)
        self.db.add(ach)
        self.db.commit()