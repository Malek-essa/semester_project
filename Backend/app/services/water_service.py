from abc import ABC, abstractmethod
from sqlalchemy.orm import Session
from fastapi import HTTPException
from ..repositories.water_repo import SQLWaterRepo
from .. import models

class IHydrationStrategy(ABC):
    @abstractmethod
    def calcFactor(self, amount: int, factor: float) -> float:
        pass


class StandardHydrationStrategy(IHydrationStrategy):
    def calcFactor(self, amount: int, factor: float) -> float:
        return amount * factor


class WaterService:
    def __init__(self, db: Session, hydration_strategy: IHydrationStrategy = None):
        self.repo = SQLWaterRepo(db)
        self.db = db
        self.hydration_strategy = hydration_strategy or StandardHydrationStrategy()

    def add_water_log(self, user_id: int, log_data):
        beverage = self.db.query(models.BeverageType).filter(
            models.BeverageType.beverage_id == log_data.beverage_id
        ).first()
        
        factor = beverage.hydration_factor if beverage else 1.0
        
        effective_hydration = self.hydration_strategy.calcFactor(log_data.amount_ml, factor)
        
        water_data = {
            "user_id": user_id,
            "beverage_id": log_data.beverage_id,
            "amount_ml": int(effective_hydration),
            "log_date": log_data.date,
            "log_time": log_data.time
        }
        
        return self.repo.create_water_log(water_data)

    def get_daily_total(self, user_id: int, target_date):
        return self.repo.get_daily_total(user_id, target_date)