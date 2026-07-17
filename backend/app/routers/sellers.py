from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import Seller
from app.schemas import SellerResponse

router = APIRouter(prefix="/sellers", tags=["sellers"])

@router.get("", response_model=List[SellerResponse])
def get_sellers(db: Session = Depends(get_db)):
    sellers = db.query(Seller).all()
    if not sellers:
        # Auto-seed baseline sellers if table is empty
        baseline_sellers = [
            Seller(shop_name="Quantum Prestige Co.", description="Nhà cung cấp vật phẩm siêu cấp độc quyền cho giới thượng lưu ảo.", logo_url="https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=200&q=80", rating=5.00, is_verified=True),
            Seller(shop_name="Cyber Pulse Studio", description="Gian hàng công nghệ tương lai, thiết bị AI và phụ kiện Cyberpunk.", logo_url="https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=200&q=80", rating=4.95, is_verified=True),
            Seller(shop_name="Aero Dynamics Ltd.", description="Chuyên phương tiện bay phản trọng lực và khí cụ thám hiểm.", logo_url="https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=200&q=80", rating=4.88, is_verified=True)
        ]
        db.add_all(baseline_sellers)
        db.commit()
        sellers = db.query(Seller).all()
    return sellers

@router.get("/{seller_id}", response_model=SellerResponse)
def get_seller(seller_id: int, db: Session = Depends(get_db)):
    seller = db.query(Seller).filter(Seller.id == seller_id).first()
    if not seller:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Seller not found.")
    return seller
