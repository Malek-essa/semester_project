from sqlalchemy import Column, Integer, String, Float, Boolean, Date, Time, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from .database import Base

# ----------------------------------------------------
# 1. جدول المستخدمين (Users)
# ----------------------------------------------------
class User(Base):
    __tablename__ = "users"

    user_id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50))
    email = Column(String(100), unique=True, index=True)
    password_hash = Column(String(255)) 
    weight = Column(Float, nullable=True)
    bed_time = Column(Time, nullable=True)       # وقت النوم المعتاد
    wake_up_time = Column(Time, nullable=True)   # وقت الاستيقاظ المعتاد
    water_goal = Column(Integer, default=2000)
    sleep_goal = Column(Float, default=8.0)
    is_fasting_mode = Column(Boolean, default=False)
    created_at = Column(Date, default=datetime.utcnow) # تاريخ إنشاء الحساب

    # العلاقات (عشان نقدر نجيب بيانات الماء والنوم تبع هذا المستخدم بسهولة)
    water_logs = relationship("WaterLog", back_populates="user")
    sleep_logs = relationship("SleepLog", back_populates="user")
    achievements = relationship("Achievement", back_populates="user")

# ----------------------------------------------------
# 2. جدول أنواع المشروبات (Beverage_Types)
# ----------------------------------------------------
class BeverageType(Base):
    __tablename__ = "beverage_types"

    beverage_id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50))              # اسم المشروب (ماء، قهوة، شاي)
    hydration_factor = Column(Float)       # معامل الترطيب (مثلاً الماء 1.0، القهوة 0.8)

    water_logs = relationship("WaterLog", back_populates="beverage")

# ----------------------------------------------------
# 3. سجل الماء (Water_Logs)
# ----------------------------------------------------
class WaterLog(Base):
    __tablename__ = "water_logs"

    log_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id"))
    beverage_id = Column(Integer, ForeignKey("beverage_types.beverage_id"))
    amount_ml = Column(Integer)
    log_date = Column(Date)
    log_time = Column(Time)

    user = relationship("User", back_populates="water_logs")
    beverage = relationship("BeverageType", back_populates="water_logs")

# ----------------------------------------------------
# 4. سجل النوم (Sleep_Logs)
# ----------------------------------------------------
class SleepLog(Base):
    __tablename__ = "sleep_logs"

    sleep_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id"))
    sleep_start = Column(DateTime)
    wake_up_end = Column(DateTime)
    total_hours = Column(Float)
    log_date = Column(Date)

    user = relationship("User", back_populates="sleep_logs")

# ----------------------------------------------------
# 5. جدول الإنجازات (Achievements)
# ----------------------------------------------------
class Achievement(Base):
    __tablename__ = "achievements"

    achievement_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id"))
    title = Column(String(100))
    type = Column(String(50))
    achieved_date = Column(Date)

    user = relationship("User", back_populates="achievements")