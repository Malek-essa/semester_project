from datetime import date, datetime
from sqlalchemy.orm import Session
from ..repositories.progress_repo import ProgressRepo
from ..repositories.user_repo import UserRepo

class ProgressService:
    def __init__(self, db: Session):
        self.progress_repo = ProgressRepo(db)
        self.user_repo = UserRepo(db)

    def get_daily_dashboard(self, user_id: int, target_date_str: str = None):
        if target_date_str:
            try:
                target_date = datetime.strptime(target_date_str, "%Y-%m-%d").date()
            except ValueError:
                target_date = date.today()
        else:
            target_date = date.today()

        user = self.user_repo.get_user_by_id(user_id) 
        
        if not user:
            return None

        water_sum = self.progress_repo.get_today_water_sum(user_id, target_date)
        sleep_sum = self.progress_repo.get_today_sleep_sum(user_id, target_date)

        water_percent = min((water_sum / user.water_goal) * 100, 100.0) if user.water_goal > 0 else 0.0
        sleep_percent = min((sleep_sum / user.sleep_goal) * 100, 100.0) if user.sleep_goal > 0 else 0.0

        new_badges = []

        if target_date == date.today():
            if water_percent >= 100.0:
                if not self.progress_repo.check_achievement_exists(user_id, "WATER_GOAL", target_date):
                    self.progress_repo.add_achievement(user_id, "بطل الترطيب اليومي 💧", "WATER_GOAL", target_date)
                    new_badges.append("بطل الترطيب اليومي 💧")

            if sleep_percent >= 100.0:
                if not self.progress_repo.check_achievement_exists(user_id, "SLEEP_GOAL", target_date):
                    self.progress_repo.add_achievement(user_id, "نوم عميق وصحي 🌙", "SLEEP_GOAL", target_date)
                    new_badges.append("نوم عميق وصحي 🌙")

        return {
            "water_progress_percent": round(water_percent, 1),
            "sleep_progress_percent": round(sleep_percent, 1),
            "water_consumed_ml": water_sum,
            "water_goal_ml": user.water_goal,
            "sleep_hours_logged": sleep_sum,
            "sleep_goal_hours": user.sleep_goal,
            "new_achievements": new_badges
        }

    def get_user_achievements(self, user_id: int):
        
        return [
            {"id": 1, "title": "بطل الترطيب اليومي 💧", "is_unlocked": True, "date": str(date.today())},
            {"id": 2, "title": "نوم عميق وصحي 🌙", "is_unlocked": True, "date": str(date.today())}
        ]