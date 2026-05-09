from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..services.sleep_service import SleepService
from .. import schemas

router = APIRouter(prefix="/api/sleep", tags=["Sleep Management"])

@router.post("/add", response_model=schemas.SleepLogResponse)
def add_sleep_record(user_id: int, log_data: schemas.SleepLogCreate, db: Session = Depends(get_db)):
    service = SleepService(db)
    result = service.log_sleep(user_id, log_data.start_time, log_data.end_time)
    return result

@router.post("/set-alarm")
def set_sleep_alarm(user_id: int, alarm_data: schemas.SleepAlarmSet, db: Session = Depends(get_db)):
    service = SleepService(db)
    message = service.trigger_alarm(user_id, alarm_data.alarm_time)
    return {"status": "success", "message": message}