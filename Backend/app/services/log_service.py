from sqlalchemy.orm import Session
from fastapi import HTTPException
from ..repositories.water_repo import SQLWaterRepo
from ..repositories.sleep_repo import SQLSleepRepo
from .. import models

class LogService:
    def __init__(self, db: Session):
        self.water_repo = SQLWaterRepo(db)
        self.sleep_repo = SQLSleepRepo(db)
        self.db = db

    # 1. تعديل سجل (موجود مسبقاً)
    def update_log_entry(self, log_type: str, log_id: int, new_value: float):
        if log_type.lower() == "water":
            updated_log = self.water_repo.update_log(log_id, {"amount_ml": int(new_value)})
            if not updated_log: raise HTTPException(status_code=404, detail="السجل غير موجود")
            return {"status": "success", "new_value": updated_log.amount_ml}
            
        elif log_type.lower() == "sleep":
            updated_log = self.sleep_repo.update_sleep_log(log_id, {"total_hours": float(new_value)})
            if not updated_log: raise HTTPException(status_code=404, detail="السجل غير موجود")
            return {"status": "success", "new_value": updated_log.total_hours}
        else:
            raise HTTPException(status_code=400, detail="نوع السجل غير معروف")

    # 2. الحذف النهائي (الفجوة المخفية في UC-03)
    def delete_log_entry(self, log_type: str, log_id: int):
        if log_type.lower() == "water":
            success = self.water_repo.delete_log(log_id)
        elif log_type.lower() == "sleep":
            # نحتاج استخدام أوامر الحذف المباشرة من الـ db إذا لم تكن موجودة في المستودع
            log = self.db.query(models.SleepLog).filter(models.SleepLog.sleep_id == log_id).first()
            if log:
                self.db.delete(log)
                self.db.commit()
                success = True
            else:
                success = False
        else:
            raise HTTPException(status_code=400, detail="نوع السجل غير معروف")
            
        if not success:
            raise HTTPException(status_code=404, detail="السجل غير موجود ليتم حذفه")
        return {"status": "success", "message": "تم الحذف بنجاح"}

    # 3. جلب سجل التاريخ (الفجوة المخفية في UC-03 لتشغيل الواجهة)
    def get_user_history(self, user_id: int):
        water_logs = self.db.query(models.WaterLog).filter(models.WaterLog.user_id == user_id).order_by(models.WaterLog.log_date.desc()).all()
        sleep_logs = self.db.query(models.SleepLog).filter(models.SleepLog.user_id == user_id).order_by(models.SleepLog.log_date.desc()).all()
        
        # تنسيق البيانات لترسل للفرونت إند
        history = []
        for w in water_logs:
            history.append({"log_id": w.log_id, "type": "water", "value": w.amount_ml, "date": w.log_date, "time": w.log_time})
        for s in sleep_logs:
            history.append({"log_id": s.sleep_id, "type": "sleep", "value": s.total_hours, "date": s.log_date, "time": None})
            
        return {"history": history}