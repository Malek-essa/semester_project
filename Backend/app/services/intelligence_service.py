from sqlalchemy.orm import Session
import random
from datetime import date
from ..repositories.user_repo import UserRepo
from ..repositories.progress_repo import ProgressRepo

class IntelligenceService:
    def __init__(self, db: Session):
        self.user_repo = UserRepo(db)
        self.progress_repo = ProgressRepo(db)

    def generate_daily_tip(self, user_id: int):
        today = date.today()
        user = self.user_repo.get_user_by_id(user_id)
        if not user: return None

        water_sum = self.progress_repo.get_today_water_sum(user_id, today)
        sleep_sum = self.progress_repo.get_today_sleep_sum(user_id, today)

        tips = []
        
        if user.water_goal > 0 and water_sum < (user.water_goal * 0.5):
            tips.append({
                "tip_title": "تنبيه الجفاف 💧", 
                "tip_content": "جسمك يحتاج للماء الآن لرفع مستوى التركيز. اشرب كوباً لتنشيط دورتك الدموية.", 
                "relevance_score": 0.95
            })
            
        if user.sleep_goal > 0 and sleep_sum < (user.sleep_goal - 2):
            tips.append({
                "tip_title": "أهمية النوم 🌙", 
                "tip_content": "النوم أقل من المعدل يضعف الذاكرة. حاول النوم الليلة أبكر بـ 30 دقيقة.", 
                "relevance_score": 0.90
            })

        if not tips:
            tips.append({
                "tip_title": "عمل رائع! 🌟", 
                "tip_content": "أنت تسير بخطى ممتازة نحو أهدافك الصحية. استمر على هذا المنوال!", 
                "relevance_score": 0.85
            })

        return random.choice(tips)