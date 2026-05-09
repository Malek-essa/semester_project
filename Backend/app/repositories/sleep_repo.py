from abc import ABC, abstractmethod
from sqlalchemy.orm import Session
from .. import models


class ISleepRepo(ABC):
    @abstractmethod
    def create_sleep_log(self, sleep_data: dict): pass
    
    @abstractmethod
    def update_sleep_log(self, sleep_id: int, update_data: dict): pass


class SQLSleepRepo(ISleepRepo):
    def __init__(self, db: Session):
        self.db = db

    def create_sleep_log(self, sleep_data: dict):
        new_log = models.SleepLog(**sleep_data)
        self.db.add(new_log)
        self.db.commit()
        self.db.refresh(new_log)
        return new_log

    def update_sleep_log(self, sleep_id: int, update_data: dict):
        log = self.db.query(models.SleepLog).filter(models.SleepLog.sleep_id == sleep_id).first()
        if log:
            for key, value in update_data.items():
                setattr(log, key, value)
            self.db.commit()
            self.db.refresh(log)
        return log