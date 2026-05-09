from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..services.intelligence_service import IntelligenceService
from .. import schemas

router = APIRouter(prefix="/api", tags=["Intelligence & Monitoring (UC-06)"])

@router.get("/user/tips", response_model=schemas.TipResponse)
def get_user_tips(user_id: int, db: Session = Depends(get_db)):
    service = IntelligenceService(db)
    tip = service.generate_daily_tip(user_id)
    if not tip:
        return {"tip_title": "نصيحة صحية", "tip_content": "شرب الماء بانتظام يحسن من صحة الجلد.", "relevance_score": 0.5}
    return tip

@router.get("/notifications/settings", response_model=schemas.NotificationSettingsResponse)
def get_notification_settings(user_id: int):
    return {"allow_reminders": True, "frequency_minutes": 60}