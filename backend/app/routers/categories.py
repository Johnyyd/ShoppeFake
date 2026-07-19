from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import Category
from app.schemas import CategoryResponse

router = APIRouter(prefix="/categories", tags=["categories"])

def seed_categories(db: Session):
    existing_names = {c.name for c in db.query(Category).all()}
    categories = [
        Category(name="Điện tử & Công nghệ", icon_name="phone_android", banner_url="https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=800&q=80"),
        Category(name="Thời trang & Phụ kiện", icon_name="checkroom", banner_url="https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=800&q=80"),
        Category(name="Đồng hồ & Trang sức VIP", icon_name="watch", banner_url="https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=800&q=80"),
        Category(name="Xe hơi & Phương tiện ảo", icon_name="directions_car", banner_url="https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=80"),
        Category(name="Vật phẩm Đặc quyền", icon_name="stars", banner_url="https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=800&q=80"),
        Category(name="Kho Voucher & Thẻ quà", icon_name="card_giftcard", banner_url="https://images.unsplash.com/photo-1513885535751-8b9238bd345a?auto=format&fit=crop&w=800&q=80"),
    ]
    missing = [c for c in categories if c.name not in existing_names]
    if missing:
        db.add_all(missing)
        db.commit()

@router.get("", response_model=List[CategoryResponse])
def get_categories(db: Session = Depends(get_db)):
    seed_categories(db)
    return db.query(Category).all()
