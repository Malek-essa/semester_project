from abc import ABC, abstractmethod
from sqlalchemy.orm import Session
from sqlalchemy import func
from .. import models


class IWaterRepo(ABC):
    @abstractmethod
    def create_water_log(self, water_data: dict): pass
    
    @abstractmethod
    def get_log(self, log_id: int): pass
    
    @abstractmethod
    def update_log(self, log_id: int, update_data: dict): pass
    
    @abstractmethod
    def delete_log(self, log_id: int): pass

    @abstractmethod
    def get_daily_total(self, user_id: int, target_date): pass


class SQLWaterRepo(IWaterRepo):
    def __init__(self, db: Session):
        self.db = db

    def create_water_log(self, water_data: dict):
        new_log = models.WaterLog(**water_data)
        self.db.add(new_log)
        self.db.commit()
        self.db.refresh(new_log)
        return new_log

    def get_log(self, log_id: int):
        return self.db.query(models.WaterLog).filter(models.WaterLog.log_id == log_id).first()

    def update_log(self, log_id: int, update_data: dict):
        log = self.get_log(log_id)
        if log:
            for key, value in update_data.items():
                setattr(log, key, value)
            self.db.commit()
            self.db.refresh(log)
        return log

    def delete_log(self, log_id: int):
        log = self.get_log(log_id)
        if log:
            self.db.delete(log)
            self.db.commit()
            return True
        return False

    def get_daily_total(self, user_id: int, target_date):
        total = self.db.query(func.sum(models.WaterLog.amount_ml)).filter(
            models.WaterLog.user_id == user_id,
            models.WaterLog.log_date == target_date
        ).scalar()
        return total or 0