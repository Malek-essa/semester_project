from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..services.water_service import WaterService
from .. import schemas

router = APIRouter(prefix="/api/water", tags=["Water Tracking"])

@router.post("/add")
def add_water(user_id: int, log_data: schemas.WaterLogCreate, db: Session = Depends(get_db)):
    service = WaterService(db)
    
    new_log = service.add_water_log(user_id, log_data)
    
    total_today = service.get_daily_total(user_id, log_data.date)
    
    return {
        "total_today": total_today, 
        "progress_percentage": 0.0 
    }