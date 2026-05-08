from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..services.water_service import WaterService
from .. import schemas

router = APIRouter(prefix="/api/water", tags=["Water Tracking"])

# البند 5 في الاتفاقية: تسجيل كمية الماء
@router.post("/add")
def add_water(user_id: int, log_data: schemas.WaterLogCreate, db: Session = Depends(get_db)):
    service = WaterService(db)
    
    # إضافة السجل الجديد
    new_log = service.add_water_log(user_id, log_data)
    
    # حساب المجموع الكلي لليوم بعد إضافة السجل الجديد
    total_today = service.get_daily_total(user_id, log_data.date)
    
    # إرجاع استجابة مطابقة للاتفاقية بالرقم التراكمي
    # ملاحظة: يمكن لاحقاً ربط النسبة المئوية بـ ProgressService
    return {
        "total_today": total_today, 
        "progress_percentage": 0.0 
    }