from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..services.features_service import FeaturesService
from .. import schemas

router = APIRouter(prefix="/api", tags=["Custom Features (Items 8 & 9)"])

# البند 8: إنشاء اختصار
@router.post("/shortcuts/create")
def create_shortcut(shortcut: schemas.ShortcutCreate, db: Session = Depends(get_db)):
    service = FeaturesService(db)
    return service.create_shortcut(shortcut.label, shortcut.amount)

# البند 9: تخصيص المشروبات
@router.post("/beverages/custom")
def create_beverage(beverage: schemas.BeverageCreate, db: Session = Depends(get_db)):
    service = FeaturesService(db)
    new_bev = service.add_custom_beverage(beverage.name, beverage.hydration_factor)
    return {
        "status": "success", 
        "beverage": {"id": new_bev.beverage_id, "name": new_bev.name, "factor": new_bev.hydration_factor}
    }