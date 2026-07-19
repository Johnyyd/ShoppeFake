from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from app.database import get_db
from app.models import UserFavorite, VirtualProduct, User
from app.schemas import ProductResponse, FavoriteToggleResponse
from app.auth import get_current_user

router = APIRouter(prefix="/favorites", tags=["favorites"])

@router.get("", response_model=List[ProductResponse])
def get_user_favorites(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    favs = db.query(UserFavorite).filter(UserFavorite.user_id == current_user.id).order_by(UserFavorite.created_at.desc()).all()
    fav_product_ids = [f.product_id for f in favs]

    if not fav_product_ids:
        return []

    products = db.query(VirtualProduct).options(
        joinedload(VirtualProduct.seller),
        joinedload(VirtualProduct.images),
        joinedload(VirtualProduct.reviews).joinedload(VirtualProduct.reviews.property.mapper.class_.user)
    ).filter(VirtualProduct.id.in_(fav_product_ids)).all()

    # Sort products by order of favorited (newest first)
    prod_map = {p.id: p for p in products}
    sorted_products = []
    for pid in fav_product_ids:
        if pid in prod_map:
            p = prod_map[pid]
            p.is_favorite = True
            sorted_products.append(p)

    return sorted_products

@router.post("/{product_id}/toggle", response_model=FavoriteToggleResponse)
def toggle_favorite(
    product_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    product = db.query(VirtualProduct).filter(VirtualProduct.id == product_id).first()
    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Không tìm thấy sản phẩm")

    favorite = db.query(UserFavorite).filter(
        UserFavorite.user_id == current_user.id,
        UserFavorite.product_id == product_id
    ).first()

    if favorite:
        db.delete(favorite)
        db.commit()
        return FavoriteToggleResponse(
            product_id=product_id,
            is_favorite=False,
            message="Đã xóa khỏi danh sách yêu thích"
        )
    else:
        new_fav = UserFavorite(user_id=current_user.id, product_id=product_id)
        db.add(new_fav)
        # Thưởng dopamine cho hành động thả tim
        current_user.dopamine_level = (current_user.dopamine_level or 0) + 5
        db.commit()
        return FavoriteToggleResponse(
            product_id=product_id,
            is_favorite=True,
            message="Đã thêm vào yêu thích! +5 Dopamine 💖"
        )
