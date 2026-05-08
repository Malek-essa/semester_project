from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from ..database import get_db
from ..services.progress_service import ProgressService
from .. import schemas

router = APIRouter(prefix="/api/user", tags=["Daily Dashboard & Achievements (UC-09)"])

# البند 11: مراقبة التقدم اليومي (مع دعم التاريخ)
@router.get("/progress", response_model=schemas.DailyProgressResponse)
def get_daily_progress(user_id: int, date: str = Query(None), db: Session = Depends(get_db)):
    service = ProgressService(db)
    dashboard_data = service.get_daily_dashboard(user_id, date)
    
    if not dashboard_data:
        raise HTTPException(status_code=404, detail="المستخدم غير موجود")
        
    return dashboard_data

# البند 12: نظام الإنجازات
@router.get("/achievements")
def get_achievements(user_id: int, db: Session = Depends(get_db)):
    service = ProgressService(db)
    # إرجاع قائمة الإنجازات كما في الاتفاقية
    return service.get_user_achievements(user_id)