from typing import List, Optional
from fastapi import APIRouter, Depends, Query, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from app.database import get_db
from app.models import VirtualProduct, Seller, Category, ProductImage, ProductReview, User, VirtualOrder, UserFavorite
from app.schemas import ProductResponse, ProductReviewCreate, ProductReviewResponse, FavoriteToggleResponse
from app.auth import get_current_user, get_current_user_optional
from app.routers.categories import seed_categories
from app.routers.sellers import get_sellers
from app.enrich_shopee_catalog import REAL_SHOPEE_CATALOG

router = APIRouter(prefix="/products", tags=["products"])

def seed_products_and_related(db: Session):
    seed_categories(db)
    get_sellers(db)

    # Check if we need to migrate from old imaginary coin scale (< 10000) or if count mismatch with REAL_SHOPEE_CATALOG
    products_count = db.query(VirtualProduct).count()
    old_scale = db.query(VirtualProduct).filter(VirtualProduct.price_virtual < 10000).first()
    if old_scale or products_count != len(REAL_SHOPEE_CATALOG):
        # Clear old non-VND items and references to re-seed realistic Shopee Vietnam data
        from app.models import VirtualOrder, CartItem, UserFavorite
        db.query(VirtualOrder).delete()
        db.query(CartItem).delete()
        db.query(UserFavorite).delete()
        db.query(ProductImage).delete()
        db.query(ProductReview).delete()
        db.query(VirtualProduct).delete()
        db.commit()

    if db.query(VirtualProduct).count() == len(REAL_SHOPEE_CATALOG):
        return

    # Ensure system default user exists for reviews
    admin_user = db.query(User).filter(User.username == "shopee_mall_bot").first()
    if not admin_user:
        admin_user = User(username="shopee_mall_bot", password_hash="dummy", virtual_balance=999999999, dopamine_level=9999)
        db.add(admin_user)
        db.commit()
        db.refresh(admin_user)

    sellers = {s.shop_name: s.id for s in db.query(Seller).all()}
    s_apple = sellers.get("Apple Flagship Store", 1)
    s_samsung = sellers.get("Samsung Official Store", 2)
    s_xiaomi = sellers.get("Xiaomi Vietnam Flagship", 3)
    s_coolmate = sellers.get("Coolmate Official Store", 4)
    s_mall = sellers.get("Shopee Mall Official", 7)

    cat_map = {c.name: c.id for c in db.query(Category).all()}

    raw_items = REAL_SHOPEE_CATALOG

    for item in raw_items:
        p = db.query(VirtualProduct).filter(VirtualProduct.name == item["name"]).first()
        if not p:
            cat_id = cat_map.get(item["cat_name"])
            seller_id = sellers.get(item.get("seller_name", ""), s_mall)
            p = VirtualProduct(
                name=item["name"],
                description=item["desc"],
                price_virtual=item["price"],
                original_price=item["orig_price"],
                discount_percentage=item["discount"],
                image_url=item["img"],
                dopamine_rating=100,
                category_name=item["cat_name"],
                category_id=cat_id,
                seller_id=seller_id,
                sold_count=item["sold"],
                average_rating=item["rating"]
            )
            db.add(p)
            db.commit()
            db.refresh(p)

            for idx, g_url in enumerate(item.get("gallery", [])):
                img = ProductImage(product_id=p.id, image_url=g_url, display_order=idx)
                db.add(img)

            rev1 = ProductReview(product_id=p.id, user_id=admin_user.id, rating=5, comment="Sản phẩm cực chuẩn chính hãng, đóng gói kỹ càng, giao hỏa tốc 2 giờ siêu nhanh. Sẽ tiếp tục ủng hộ shop!")
            rev2 = ProductReview(product_id=p.id, user_id=admin_user.id, rating=5, comment="Hàng y hình, chất lượng vượt mong đợi so với giá tiền. Mua đợt sale áp được voucher giảm sâu cực kỳ hài lòng.")
            db.add_all([rev1, rev2])
            db.commit()

@router.get("", response_model=List[ProductResponse])
def get_products(
    category_id: Optional[int] = Query(None, description="Lọc theo ID danh mục"),
    search_query: Optional[str] = Query(None, description="Tìm kiếm theo từ khóa"),
    sort_by: Optional[str] = Query(None, description="Sắp xếp: price_asc, price_desc, sold_desc, dopamine_desc"),
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)
):
    seed_products_and_related(db)

    query = db.query(VirtualProduct).options(
        joinedload(VirtualProduct.seller),
        joinedload(VirtualProduct.images),
        joinedload(VirtualProduct.reviews).joinedload(ProductReview.user)
    )

    if category_id:
        query = query.filter(VirtualProduct.category_id == category_id)

    if search_query and search_query.strip():
        k = f"%{search_query.strip()}%"
        query = query.filter(
            (VirtualProduct.name.ilike(k)) | (VirtualProduct.description.ilike(k))
        )

    if sort_by == "price_asc":
        query = query.order_by(VirtualProduct.price_virtual.asc())
    elif sort_by == "price_desc":
        query = query.order_by(VirtualProduct.price_virtual.desc())
    elif sort_by == "sold_desc":
        query = query.order_by(VirtualProduct.sold_count.desc())
    elif sort_by == "dopamine_desc":
        query = query.order_by(VirtualProduct.dopamine_rating.desc())
    else:
        query = query.order_by(VirtualProduct.id.asc())

    products = query.all()

    if current_user:
        favs = db.query(UserFavorite.product_id).filter(UserFavorite.user_id == current_user.id).all()
        fav_ids = set(f[0] for f in favs)
        for p in products:
            p.is_favorite = (p.id in fav_ids)
    else:
        for p in products:
            p.is_favorite = False

    return products


@router.get("/{product_id}", response_model=ProductResponse)
def get_product(
    product_id: int,
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)
):
    product = db.query(VirtualProduct).options(
        joinedload(VirtualProduct.seller),
        joinedload(VirtualProduct.images),
        joinedload(VirtualProduct.reviews).joinedload(ProductReview.user)
    ).filter(VirtualProduct.id == product_id).first()

    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Không tìm thấy sản phẩm")

    if current_user:
        fav = db.query(UserFavorite).filter(
            UserFavorite.user_id == current_user.id,
            UserFavorite.product_id == product.id
        ).first()
        product.is_favorite = (fav is not None)
    else:
        product.is_favorite = False

    return product


@router.post("/{product_id}/favorite", response_model=FavoriteToggleResponse)
@router.post("/{product_id}/toggle-favorite", response_model=FavoriteToggleResponse)
def toggle_product_favorite(
    product_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    from app.routers.favorites import toggle_favorite
    return toggle_favorite(product_id=product_id, current_user=current_user, db=db)



@router.post("/{product_id}/reviews", response_model=ProductReviewResponse)
def submit_product_review(
    product_id: int,
    review_data: ProductReviewCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    product = db.query(VirtualProduct).filter(VirtualProduct.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Không tìm thấy sản phẩm")

    # Check if user already reviewed this product
    existing_review = db.query(ProductReview).filter(
        ProductReview.product_id == product.id,
        ProductReview.user_id == current_user.id
    ).first()

    if existing_review:
        existing_review.rating = review_data.rating
        existing_review.comment = review_data.comment
        db.commit()
        db.refresh(existing_review)
        review = existing_review
    else:
        review = ProductReview(
            product_id=product.id,
            user_id=current_user.id,
            rating=review_data.rating,
            comment=review_data.comment
        )
        db.add(review)
        db.commit()
        db.refresh(review)

        # Check if user has a completed order for this product to award virtual balance and dopamine hits
        completed_order = db.query(VirtualOrder).filter(
            VirtualOrder.user_id == current_user.id,
            VirtualOrder.product_id == product.id,
            VirtualOrder.status == "Hoàn thành"
        ).first()

        if completed_order:
            current_user.virtual_balance += 50.0
            current_user.dopamine_level += 30
            db.commit()

    # Recalculate average rating for product
    all_reviews = db.query(ProductReview).filter(ProductReview.product_id == product.id).all()
    if all_reviews:
        product.average_rating = round(sum(r.rating for r in all_reviews) / len(all_reviews), 1)
        db.commit()

    return review

