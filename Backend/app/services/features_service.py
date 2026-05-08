from sqlalchemy.orm import Session
from .. import models

class FeaturesService:
    def __init__(self, db: Session):
        self.db = db

    # البند 9: إضافة مشروب جديد لقاعدة البيانات
    def add_custom_beverage(self, name: str, factor: float):
        new_bev = models.BeverageType(name=name, hydration_factor=factor)
        self.db.add(new_bev)
        self.db.commit()
        self.db.refresh(new_bev)
        return new_bev

    # البند 8: اختصار واجهة المستخدم (Mock Response)
    def create_shortcut(self, label: str, amount: int):
        # بما أنه لا يوجد جدول في الـ ERD، نرجع استجابة نجاح للفرونت إند مباشرة
        return {
            "status": "success", 
            "message": f"تم إنشاء اختصار '{label}' بـ {amount} مل بنجاح",
            "shortcut_data": {"label": label, "amount": amount}
        }