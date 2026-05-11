from sqlalchemy.orm import Session
from ..repositories.user_repo import UserRepo
from passlib.context import CryptContext
import jwt

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
SECRET_KEY = "super_secret_key" 

class AuthService:
    def __init__(self, db: Session):
        self.repo = UserRepo(db)

    def register_user(self, user_schema):
        user_data = user_schema.dict()
        user_data['password_hash'] = pwd_context.hash(user_data.pop('password'))
        db_data = {k: v for k, v in user_data.items() if k in ['name', 'email', 'password_hash', 'weight']}
        return self.repo.create_user(db_data)

    def login_user(self, login_schema):
        user = self.repo.get_user_by_email(login_schema.email)
        if user and pwd_context.verify(login_schema.password, user.password_hash):
            token = jwt.encode({"sub": user.email, "id": user.user_id}, SECRET_KEY)
            return {
                "token": token,
                "user_id": user.user_id,
                "name": user.name,
                "settings": {"water_goal": user.water_goal, "sleep_goal": user.sleep_goal}
            }
        return None