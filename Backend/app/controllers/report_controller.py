from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..services.report_service import ReportService
from .. import schemas

router = APIRouter(prefix="/api/reports", tags=["Export Reports (UC-05)"])

@router.get("/export", response_model=schemas.ReportResponse)
def export_report(user_id: int, format: str = "pdf", range: str = "weekly", db: Session = Depends(get_db)):
    if format.lower() != "pdf":
        raise HTTPException(status_code=400, detail="عذراً، الصيغة المدعومة حالياً هي PDF فقط")
    
    service = ReportService(db)
    file_url = service.generate_weekly_report(user_id)
    
    if not file_url:
        raise HTTPException(status_code=404, detail="المستخدم غير موجود")
        
    return {"download_url": file_url}