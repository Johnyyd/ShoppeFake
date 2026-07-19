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
    existing_names = {s.shop_name for s in sellers}
    baseline_sellers = [
        Seller(shop_name="Apple Flagship Store", description="Gian hàng chính hãng Apple Việt Nam - Bảo hành 12 tháng chính hãng.", logo_url="https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=200&q=80", rating=5.00, is_verified=True),
        Seller(shop_name="Samsung Official Store", description="Gian hàng chính hãng Samsung Flagship Store Việt Nam.", logo_url="https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=200&q=80", rating=4.95, is_verified=True),
        Seller(shop_name="Xiaomi Vietnam Flagship", description="Gian hàng Xiaomi chính hãng - Công nghệ thông minh cho nhà cửa và đời sống.", logo_url="https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=200&q=80", rating=4.92, is_verified=True),
        Seller(shop_name="Coolmate Official Store", description="Thương hiệu thời trang nam chất lượng cao, tự hào sản xuất tại Việt Nam.", logo_url="https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=200&q=80", rating=4.98, is_verified=True),
        Seller(shop_name="Baseus Vietnam Official", description="Phụ kiện công nghệ, sạc nhanh và thiết bị ô tô thông chính hãng Baseus.", logo_url="https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=200&q=80", rating=4.89, is_verified=True),
        Seller(shop_name="L'Oreal Paris Official Store", description="Gian hàng chính hãng mỹ phẩm và chăm sóc sắc đẹp hàng đầu từ Pháp.", logo_url="https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=200&q=80", rating=4.91, is_verified=True),
        Seller(shop_name="Shopee Mall Official", description="Trung tâm phân phối các mặt hàng cao cấp và vật phẩm đặc quyền chính hãng.", logo_url="https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=200&q=80", rating=5.00, is_verified=True)
    ]
    missing = [s for s in baseline_sellers if s.shop_name not in existing_names]
    if missing:
        db.add_all(missing)
        db.commit()
        sellers = db.query(Seller).all()
    return sellers

@router.get("/{seller_id}", response_model=SellerResponse)
def get_seller(seller_id: int, db: Session = Depends(get_db)):
    seller = db.query(Seller).filter(Seller.id == seller_id).first()
    if not seller:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Seller not found.")
    return seller
