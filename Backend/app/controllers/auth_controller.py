from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..services.auth_service import AuthService
from .. import schemas

router = APIRouter(prefix="/api/auth", tags=["Auth (UC-01)"])

@router.post("/register")
def register(user: schemas.UserCreate, db: Session = Depends(get_db)):
    auth_service = AuthService(db)
    auth_service.register_user(user)
    return {"status": "success", "message": "User created"}

@router.post("/login")
def login(user: schemas.UserLogin, db: Session = Depends(get_db)):
    auth_service = AuthService(db)
    result = auth_service.login_user(user)
    if not result:
        raise HTTPException(status_code=401, detail="إيميل أو كلمة مرور خاطئة")
    return result