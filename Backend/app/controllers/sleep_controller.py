from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..services.sleep_service import SleepService
from .. import schemas

router = APIRouter(prefix="/api/sleep", tags=["Sleep Management"])

# البند 6 في الاتفاقية: تسجيل ساعات النوم
@router.post("/add", response_model=schemas.SleepLogResponse)
def add_sleep_record(user_id: int, log_data: schemas.SleepLogCreate, db: Session = Depends(get_db)):
    service = SleepService(db)
    # استخدام start_time و end_time المحددة في schemas.py
    result = service.log_sleep(user_id, log_data.start_time, log_data.end_time)
    return result

# البند رقم 12: ضبط منبه موعد النوم
# البند رقم 12: ضبط منبه موعد النوم
@router.post("/set-alarm")
def set_sleep_alarm(user_id: int, alarm_data: schemas.SleepAlarmSet, db: Session = Depends(get_db)):
    service = SleepService(db)
    # استدعاء دالة المنبه اللي بتعتمد على الـ Strategy Pattern
    message = service.trigger_alarm(user_id, alarm_data.alarm_time)
    return {"status": "success", "message": message}