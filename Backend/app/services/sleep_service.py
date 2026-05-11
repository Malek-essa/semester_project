from abc import ABC, abstractmethod
from datetime import datetime
from ..repositories.sleep_repo import SQLSleepRepo, ISleepRepo


class INotificationStrategy(ABC):
    @abstractmethod
    def schedule(self, user_id: int, time_data) -> str:
        pass


class StandardNotify(INotificationStrategy):
    def schedule(self, user_id: int, time_data) -> str:
        return f"تم ضبط المنبه بنجاح في تمام الساعة {time_data}. (الوضع العادي)"

class FastingNotify(INotificationStrategy):
    def schedule(self, user_id: int, time_data) -> str:
        return f"تم ضبط المنبه بنجاح في تمام الساعة {time_data}. (وضع الصيام: تم جدولة إشعارات السحور)"


class SleepService:
    def __init__(self, db, sleep_repo: ISleepRepo = None, notify_strategy: INotificationStrategy = None):
        self.repo = sleep_repo or SQLSleepRepo(db)
        self.notify_strategy = notify_strategy or StandardNotify()

    def log_sleep(self, user_id: int, start_time: datetime, end_time: datetime):
        duration = end_time - start_time
        total_hours = duration.total_seconds() / 3600
        
        sleep_data = {
            "user_id": user_id,
            "sleep_start": start_time,
            "wake_up_end": end_time,
            "total_hours": round(total_hours, 2),
            "log_date": end_time.date()
        }
        return self.repo.create_sleep_log(sleep_data)

    def trigger_alarm(self, user_id: int, alarm_time):
        return self.notify_strategy.schedule(user_id, alarm_time)