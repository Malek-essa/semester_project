from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..services.log_service import LogService
from .. import schemas

router = APIRouter(prefix="/api/logs", tags=["Edit & History Logs (UC-03)"])

@router.put("/update")
def update_daily_log(log_data: schemas.WaterLogUpdate, db: Session = Depends(get_db)):
    service = LogService(db)
    return service.update_log_entry(log_data.log_type, log_data.log_id, log_data.new_value)

@router.delete("/delete")
def delete_daily_log(log_type: str, log_id: int, db: Session = Depends(get_db)):
    service = LogService(db)
    return service.delete_log_entry(log_type, log_id)

@router.get("/history/{user_id}")
def get_logs_history(user_id: int, db: Session = Depends(get_db)):
    service = LogService(db)
    return service.get_user_history(user_id)