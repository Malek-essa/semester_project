from sqlalchemy.orm import Session
from fastapi import HTTPException
from ..repositories.user_repo import UserRepo

class UserService:
    def __init__(self, db: Session):
        self.repo = UserRepo(db)

    # البند 3: تحديث الملف الشخصي (Profile)
    def update_profile(self, user_id: int, profile_data):
        user = self.repo.get_user_by_id(user_id)
        if not user:
            raise HTTPException(status_code=404, detail="المستخدم غير موجود")
        
        data = profile_data.dict(exclude_unset=True)
        # إعادة حساب هدف الماء تلقائياً إذا تم تعديل الوزن (الوزن * 35 مل)
        if 'weight' in data and data['weight']:
            data['water_goal'] = int(data['weight'] * 35)
            
        updated_user = self.repo.update_user(user_id, data)
        return {"status": "updated", "message": "تم تحديث الملف الشخصي بنجاح"}

    # البند 4: تعديل الأهداف يدوياً (Goals)
    def update_goals(self, user_id: int, goals_data):
        updated_user = self.repo.update_user(user_id, {
            "water_goal": goals_data.water_goal_ml,
            "sleep_goal": goals_data.sleep_goal_hours
        })
        return {
            "new_goals": {
                "water_goal_ml": updated_user.water_goal,
                "sleep_goal_hours": updated_user.sleep_goal
            }
        }

    # البند 10: وضع الصيام (Fasting)
    def toggle_fasting(self, user_id: int, fasting_data):
        # نحفظ فقط is_active كـ is_fasting_mode في الداتا بيز حسب ERD
        updated_user = self.repo.update_user(user_id, {
            "is_fasting_mode": fasting_data.is_active
        })
        return {
            "status": "success", 
            "is_fasting": updated_user.is_fasting_mode
        }