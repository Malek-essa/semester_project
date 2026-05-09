from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..services.user_service import UserService 
from .. import schemas

router = APIRouter(prefix="/api/user", tags=["User & Profile (UC-02, UC-04, UC-10)"])

@router.put("/profile")
def update_profile(user_id: int, profile: schemas.ProfileUpdate, db: Session = Depends(get_db)):
    service = UserService(db)
    return service.update_profile(user_id, profile)

@router.patch("/goals")
def update_goals(user_id: int, goals: schemas.GoalUpdate, db: Session = Depends(get_db)):
    service = UserService(db)
    return service.update_goals(user_id, goals)

@router.patch("/fasting")
def toggle_fasting(user_id: int, fasting: schemas.FastingUpdate, db: Session = Depends(get_db)):
    service = UserService(db)
    return service.toggle_fasting(user_id, fasting)