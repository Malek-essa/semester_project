from pydantic import BaseModel
from datetime import time, date, datetime
from typing import List, Optional

class UserCreate(BaseModel):
    name: str
    email: str
    password: str
    weight: Optional[float] = None
    height: Optional[float] = None       
    gender: Optional[str] = None         
    birth_date: Optional[date] = None    

class UserLogin(BaseModel):
    email: str
    password: str

class ProfileUpdate(BaseModel):
    name: Optional[str] = None
    weight: Optional[float] = None
    bed_time: Optional[time] = None
    wakeup_time: Optional[time] = None  

class GoalUpdate(BaseModel):
    water_goal_ml: int
    sleep_goal_hours: float

class FastingUpdate(BaseModel):
    is_active: bool
    start_time: Optional[str] = None
    duration_hours: Optional[int] = None

# --- ثالثاً: الأنشطة (Tracking) ---
class WaterLogCreate(BaseModel):
    amount_ml: int
    beverage_id: int
    date: date
    time: time

class WaterLogUpdate(BaseModel):
    log_type: str = "water"              
    log_id: int
    new_value: int

class SleepLogCreate(BaseModel):
    start_time: datetime
    end_time: datetime
    quality_rating: Optional[int] = None

class SleepLogResponse(BaseModel):
    sleep_id: int
    total_hours: float
    class Config:
        from_attributes = True

class SleepAlarmSet(BaseModel):
    alarm_time: time
    
    class Config:
        from_attributes = True

class DailyProgressResponse(BaseModel):
    water_progress_percent: float
    sleep_progress_percent: float
    water_consumed_ml: int
    water_goal_ml: int
    sleep_hours_logged: float
    sleep_goal_hours: float
    new_achievements: List[str] = []
    
class TipResponse(BaseModel):
    tip_title: str
    tip_content: str
    relevance_score: float

class NotificationSettingsResponse(BaseModel):
    allow_reminders: bool
    frequency_minutes: int    

class ShortcutCreate(BaseModel):
    label: str
    amount: int

class BeverageCreate(BaseModel):
    name: str
    hydration_factor: float    
    
    
class ReportResponse(BaseModel):
    download_url: str    