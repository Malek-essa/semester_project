import os
from fpdf import FPDF
from datetime import date
from sqlalchemy.orm import Session
from ..repositories.user_repo import UserRepo

class ReportService:
    def __init__(self, db: Session):
        self.user_repo = UserRepo(db)
        os.makedirs("static/reports", exist_ok=True)

    def generate_weekly_report(self, user_id: int):
        user = self.user_repo.get_user_by_id(user_id)
        if not user:
            return None
        
        pdf = FPDF()
        pdf.add_page()
        pdf.set_font("Arial", "B", 16)
        
        pdf.cell(200, 10, txt="Smart Health Assistant - Weekly Report", ln=True, align="C")
        pdf.ln(10)
        
        pdf.set_font("Arial", size=12)
        pdf.cell(200, 10, txt=f"User Name: {user.name}", ln=True)
        pdf.cell(200, 10, txt=f"Report Date: {date.today()}", ln=True)
        
        pdf.ln(10)
        pdf.set_font("Arial", "B", 14)
        pdf.cell(200, 10, txt="Daily Goals Settings:", ln=True)
        pdf.set_font("Arial", size=12)
        pdf.cell(200, 10, txt=f"- Water Goal: {user.water_goal} ml", ln=True)
        pdf.cell(200, 10, txt=f"- Sleep Goal: {user.sleep_goal} hours", ln=True)
        
        
        file_name = f"report_user_{user_id}_{date.today()}.pdf"
        file_path = f"static/reports/{file_name}"
        pdf.output(file_path)
        
        return f"/static/reports/{file_name}"