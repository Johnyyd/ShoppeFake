from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import User
from app.schemas import UserCreate, UserLogin, Token, UserResponse, DailyCheckinResponse
from app.auth import get_password_hash, verify_password, create_access_token, get_current_user
from app.limiter import limiter

router = APIRouter(prefix="/auth", tags=["auth"])

@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user

@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
@limiter.limit("10/minute")
def register_user(request: Request, user_in: UserCreate, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.username == user_in.username).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already registered."
        )
    hashed_pwd = get_password_hash(user_in.password)
    new_user = User(
        username=user_in.username,
        password_hash=hashed_pwd,
        virtual_balance=5000.00,
        dopamine_level=0,
        last_checkin_date=None,
        checkin_streak=0
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

@router.post("/login", response_model=Token)
@limiter.limit("20/minute")
def login_user(request: Request, user_in: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == user_in.username).first()
    if not user or not verify_password(user_in.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token = create_access_token(data={"sub": user.username})
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "username": user.username,
        "virtual_balance": user.virtual_balance if user.virtual_balance is not None else 5000.0,
        "dopamine_level": user.dopamine_level if user.dopamine_level is not None else 0,
        "last_checkin_date": user.last_checkin_date,
        "checkin_streak": user.checkin_streak if user.checkin_streak is not None else 0
    }

@router.post("/daily-checkin", response_model=DailyCheckinResponse)
def daily_checkin(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    today = datetime.utcnow().strftime("%Y-%m-%d")
    if current_user.last_checkin_date == today:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Bạn đã điểm danh hôm nay rồi! Hãy quay lại vào ngày mai."
        )

    yesterday = (datetime.utcnow() - timedelta(days=1)).strftime("%Y-%m-%d")
    if current_user.last_checkin_date == yesterday:
        current_user.checkin_streak += 1
    else:
        current_user.checkin_streak = 1

    streak_day = ((current_user.checkin_streak - 1) % 7) + 1
    rewards = {
        1: (50.0, 10),
        2: (70.0, 15),
        3: (100.0, 20),
        4: (120.0, 25),
        5: (150.0, 30),
        6: (200.0, 40),
        7: (300.0, 50),
    }
    reward_coins, reward_dopamine = rewards.get(streak_day, (50.0, 10))

    current_user.virtual_balance += reward_coins
    current_user.dopamine_level += reward_dopamine
    current_user.last_checkin_date = today

    db.commit()
    db.refresh(current_user)

    return DailyCheckinResponse(
        message=f"Điểm danh ngày {streak_day} thành công! Nhận ngay +{reward_coins:.0f} xu và +{reward_dopamine} Dopamine.",
        reward_coins=reward_coins,
        reward_dopamine=reward_dopamine,
        streak=current_user.checkin_streak,
        virtual_balance=current_user.virtual_balance,
        dopamine_level=current_user.dopamine_level
    )
