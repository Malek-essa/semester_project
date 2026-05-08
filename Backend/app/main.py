from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from .database import engine, Base
from fastapi.middleware.cors import CORSMiddleware

from .controllers import auth_controller
from .controllers import user_controller  
from .controllers import water_controller
from .controllers import sleep_controller
from .controllers import progress_controller
from .controllers import intelligence_controller
from .controllers import features_controller
from .controllers import report_controller 
from .controllers import log_controller

Base.metadata.create_all(bind=engine)
app = FastAPI(title="Smart Health Assistant")

# إعدادات CORS للسماح للفرونت إند بالاتصال
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # يسمح لأي جهة بالاتصال (للتطوير المحلي)
    allow_credentials=True,
    allow_methods=["*"],  # يسمح بكل أنواع الطلبات (GET, POST, PUT, DELETE)
    allow_headers=["*"],
)

# السماح بقراءة الملفات المحفوظة (مثل ملفات الـ PDF)
import os
os.makedirs("static/reports", exist_ok=True)
app.mount("/static", StaticFiles(directory="static"), name="static")

# تسجيل الروابط
app.include_router(auth_controller.router)
app.include_router(user_controller.router)
app.include_router(water_controller.router)
app.include_router(sleep_controller.router)
app.include_router(progress_controller.router)
app.include_router(intelligence_controller.router)
app.include_router(features_controller.router)
app.include_router(report_controller.router) 
app.include_router(log_controller.router)