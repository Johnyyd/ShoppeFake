from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session, joinedload
from app.database import get_db
from app.models import VirtualProduct, Seller, Category, ProductImage, ProductReview, User
from app.schemas import ProductResponse
from app.routers.categories import seed_categories
from app.routers.sellers import get_sellers

router = APIRouter(prefix="/products", tags=["products"])

def seed_products_and_related(db: Session):
    seed_categories(db)
    get_sellers(db)

    products_count = db.query(VirtualProduct).count()
    if products_count >= 15:
        return

    # Ensure system default user exists for reviews
    admin_user = db.query(User).filter(User.username == "shopee_mall_bot").first()
    if not admin_user:
        admin_user = User(username="shopee_mall_bot", password_hash="dummy", virtual_balance=999999, dopamine_level=9999)
        db.add(admin_user)
        db.commit()
        db.refresh(admin_user)

    seller = db.query(Seller).first()
    seller_id = seller.id if seller else 1

    cat_map = {c.name: c.id for c in db.query(Category).all()}
    cat_dientu = cat_map.get("Điện tử & Công nghệ", 1)
    cat_thoitrang = cat_map.get("Thời trang & Phụ kiện", 2)
    cat_dongho = cat_map.get("Đồng hồ & Trang sức VIP", 3)
    cat_xe = cat_map.get("Xe hơi & Phương tiện ảo", 4)
    cat_dacquyen = cat_map.get("Vật phẩm Đặc quyền", 5)

    raw_items = [
        # Điện tử
        {
            "name": "Tai nghe Bluetooth Chống Ồn AI Pro Mk.IV",
            "desc": "Âm thanh vòm 3D spatial audio cực đỉnh, chống ồn tuyệt đối, pin 60 giờ.",
            "price": 699.0, "orig_price": 999.0, "discount": 30, "cat_name": "Điện tử & Công nghệ", "cat_id": cat_dientu, "dopamine": 150, "sold": 1240, "rating": 4.9,
            "img": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=600&q=80",
            "gallery": [
                "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80",
                "https://images.unsplash.com/photo-1484704849700-f032a568e944?auto=format&fit=crop&w=800&q=80",
                "https://images.unsplash.com/photo-1546435770-a3e426bf472b?auto=format&fit=crop&w=800&q=80"
            ]
        },
        {
            "name": "Bàn phím cơ Custom RGB Holographic 75%",
            "desc": "Keycap trong suốt phản quang, switch gasket mount êm ái, kết nối 3 mode siêu tốc.",
            "price": 450.0, "orig_price": 550.0, "discount": 18, "cat_name": "Điện tử & Công nghệ", "cat_id": cat_dientu, "dopamine": 120, "sold": 890, "rating": 4.8,
            "img": "https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=600&q=80",
            "gallery": [
                "https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=800&q=80",
                "https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?auto=format&fit=crop&w=800&q=80"
            ]
        },
        {
            "name": "Siêu Máy Tính Gaming Rig Dual 4090",
            "desc": "Tản nhiệt chất lỏng custom RGB aura, hiệu năng phá vỡ mọi định luật vật lý.",
            "price": 1899.5, "orig_price": 2499.0, "discount": 24, "cat_name": "Điện tử & Công nghệ", "cat_id": cat_dientu, "dopamine": 350, "sold": 450, "rating": 5.0,
            "img": "https://images.unsplash.com/photo-1587202372775-e229f172b9d7?auto=format&fit=crop&w=600&q=80",
            "gallery": [
                "https://images.unsplash.com/photo-1587202372775-e229f172b9d7?auto=format&fit=crop&w=800&q=80",
                "https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=800&q=80"
            ]
        },
        {
            "name": "Kính Thực Tế Ảo VR Vision Master Pro",
            "desc": "Màn hình Micro-OLED 8K mỗi mắt, theo dõi cử chỉ tay không độ trễ.",
            "price": 3499.0, "orig_price": 3999.0, "discount": 12, "cat_name": "Điện tử & Công nghệ", "cat_id": cat_dientu, "dopamine": 600, "sold": 310, "rating": 4.9,
            "img": "https://images.unsplash.com/photo-1622979135225-d2ba269bc1df?auto=format&fit=crop&w=600&q=80",
            "gallery": [
                "https://images.unsplash.com/photo-1622979135225-d2ba269bc1df?auto=format&fit=crop&w=800&q=80",
                "https://images.unsplash.com/photo-1592478411213-6153e4ebc07d?auto=format&fit=crop&w=800&q=80"
            ]
        },
        # Thời trang
        {
            "name": "Giày Sneaker Cyber-Neon Glowing Mk.VII",
            "desc": "Đế giày phát sáng hào quang cyber, tự động thắt dây, tăng 50% độ ngầu.",
            "price": 499.99, "orig_price": 799.0, "discount": 37, "cat_name": "Thời trang & Phụ kiện", "cat_id": cat_thoitrang, "dopamine": 180, "sold": 2100, "rating": 4.9,
            "img": "https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&w=600&q=80",
            "gallery": [
                "https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&w=800&q=80",
                "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80"
            ]
        },
        {
            "name": "Áo Khoác Bomber Techwear Chống Nước AI",
            "desc": "Chất liệu nano siêu nhẹ tự kiểm soát nhiệt độ, nhiều túi tiện ích.",
            "price": 320.0, "orig_price": 400.0, "discount": 20, "cat_name": "Thời trang & Phụ kiện", "cat_id": cat_thoitrang, "dopamine": 90, "sold": 1560, "rating": 4.7,
            "img": "https://images.unsplash.com/photo-1551028719-00167b16eac5?auto=format&fit=crop&w=600&q=80",
            "gallery": [
                "https://images.unsplash.com/photo-1551028719-00167b16eac5?auto=format&fit=crop&w=800&q=80",
                "https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=800&q=80"
            ]
        },
        {
            "name": "Kính Mát Cyberpunk HUD AR Glass",
            "desc": "Hiển thị thông tin thực tế tăng cường trên tròng kính, chống tia UV 100%.",
            "price": 280.0, "orig_price": 350.0, "discount": 20, "cat_name": "Thời trang & Phụ kiện", "cat_id": cat_thoitrang, "dopamine": 110, "sold": 980, "rating": 4.8,
            "img": "https://images.unsplash.com/photo-1511499767150-a48a237f0083?auto=format&fit=crop&w=600&q=80",
            "gallery": [
                "https://images.unsplash.com/photo-1511499767150-a48a237f0083?auto=format&fit=crop&w=800&q=80"
            ]
        },
        # Đồng hồ VIP
        {
            "name": "Đồng Hồ Vàng Lượng Tử Golden Quantum Rolex",
            "desc": "Vượt qua dòng chảy thời gian, đính kim cương ảo lấp lánh hào quang vĩnh cửu.",
            "price": 2499.0, "orig_price": 3500.0, "discount": 28, "cat_name": "Đồng hồ & Trang sức VIP", "cat_id": cat_dongho, "dopamine": 500, "sold": 180, "rating": 5.0,
            "img": "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=600&q=80",
            "gallery": [
                "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=800&q=80",
                "https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&w=800&q=80"
            ]
        },
        {
            "name": "Vòng Tay Kim Cương Celestial Aura",
            "desc": "Tạo vòng sáng bao quanh cổ tay, tăng độ nhận diện trong các phòng chat VIP.",
            "price": 1250.0, "orig_price": 1500.0, "discount": 16, "cat_name": "Đồng hồ & Trang sức VIP", "cat_id": cat_dongho, "dopamine": 280, "sold": 320, "rating": 4.9,
            "img": "https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=600&q=80",
            "gallery": [
                "https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=800&q=80"
            ]
        },
        # Xe hơi
        {
            "name": "Ván Trượt Hàng Không Celestial Hoverboard",
            "desc": "Lướt trên không trung không trọng lực với dải vệt sáng sao băng phía sau.",
            "price": 899.0, "orig_price": 1200.0, "discount": 25, "cat_name": "Xe hơi & Phương tiện ảo", "cat_id": cat_xe, "dopamine": 250, "sold": 670, "rating": 4.9,
            "img": "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80",
            "gallery": [
                "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=800&q=80"
            ]
        },
        {
            "name": "Siêu Xe Thể Thao Cyber-GT Hypercar",
            "desc": "Tốc độ ánh sáng trong metaverse, âm thanh động cơ gầm rú uy lực tuyệt đối.",
            "price": 4999.0, "orig_price": 5999.0, "discount": 16, "cat_name": "Xe hơi & Phương tiện ảo", "cat_id": cat_xe, "dopamine": 1200, "sold": 95, "rating": 5.0,
            "img": "https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=600&q=80",
            "gallery": [
                "https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=80",
                "https://images.unsplash.com/photo-1544829099-b9a0c07fad1a?auto=format&fit=crop&w=800&q=80"
            ]
        },
        {
            "name": "Phi Thuyền Cá Nhân Galactic Cruiser",
            "desc": "Cực phẩm di chuyển qua các hành tinh metaverse, trang bị khiên năng lượng.",
            "price": 8888.0, "orig_price": 9999.0, "discount": 11, "cat_name": "Xe hơi & Phương tiện ảo", "cat_id": cat_xe, "dopamine": 2500, "sold": 42, "rating": 5.0,
            "img": "https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=600&q=80",
            "gallery": [
                "https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=800&q=80"
            ]
        },
        # Đặc quyền
        {
            "name": "Vương Miện Bạch Kim Platinum VIP Crown",
            "desc": "Hào quang danh giá vĩnh viễn trong mọi sảnh chờ và diễn đàn ảo.",
            "price": 3999.99, "orig_price": 5000.0, "discount": 20, "cat_name": "Vật phẩm Đặc quyền", "cat_id": cat_dacquyen, "dopamine": 1000, "sold": 150, "rating": 5.0,
            "img": "https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=600&q=80",
            "gallery": [
                "https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=800&q=80"
            ]
        },
        {
            "name": "Huy Hiệu Huyền Thoại Legendary Mythic Badge",
            "desc": "Tỏa sáng lấp lánh cạnh tên người dùng, mở khóa quyền lực chat VIP không giới hạn.",
            "price": 1500.0, "orig_price": 2000.0, "discount": 25, "cat_name": "Vật phẩm Đặc quyền", "cat_id": cat_dacquyen, "dopamine": 450, "sold": 540, "rating": 4.9,
            "img": "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=600&q=80",
            "gallery": [
                "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=80"
            ]
        },
        {
            "name": "Thẻ Đặc Quyền Vô Cực Infinity Privilege Card",
            "desc": "Nhân đôi toàn bộ điểm Dopamine kiếm được trong tương lai.",
            "price": 6666.0, "orig_price": 7777.0, "discount": 14, "cat_name": "Vật phẩm Đặc quyền", "cat_id": cat_dacquyen, "dopamine": 1888, "sold": 88, "rating": 5.0,
            "img": "https://images.unsplash.com/photo-1563013792-51c7eb8066f8?auto=format&fit=crop&w=600&q=80",
            "gallery": [
                "https://images.unsplash.com/photo-1563013792-51c7eb8066f8?auto=format&fit=crop&w=800&q=80"
            ]
        }
    ]

    for item in raw_items:
        p = db.query(VirtualProduct).filter(VirtualProduct.name == item["name"]).first()
        if not p:
            p = VirtualProduct(
                name=item["name"],
                description=item["desc"],
                price_virtual=item["price"],
                original_price=item["orig_price"],
                discount_percentage=item["discount"],
                image_url=item["img"],
                dopamine_rating=item["dopamine"],
                category_name=item["cat_name"],
                category_id=item["cat_id"],
                seller_id=seller_id,
                sold_count=item["sold"],
                average_rating=item["rating"]
            )
            db.add(p)
            db.commit()
            db.refresh(p)

            # Add images
            for idx, g_url in enumerate(item.get("gallery", [])):
                img = ProductImage(product_id=p.id, image_url=g_url, display_order=idx)
                db.add(img)

            # Add reviews
            rev1 = ProductReview(product_id=p.id, user_id=admin_user.id, rating=5, comment="Sản phẩm cực chất, nhận điểm Dopamine ngay tắp lự! Giao diện 10 điểm không có nhưng.")
            rev2 = ProductReview(product_id=p.id, user_id=admin_user.id, rating=5, comment="Đóng gói ảo siêu cẩn thận, mã giảm giá áp vào cực kỳ hợp lý. Sẽ ủng hộ shop dài dài!")
            db.add_all([rev1, rev2])
            db.commit()

@router.get("", response_model=List[ProductResponse])
def get_products(
    category_id: Optional[int] = Query(None, description="Lọc theo ID danh mục"),
    search_query: Optional[str] = Query(None, description="Tìm kiếm theo từ khóa"),
    sort_by: Optional[str] = Query(None, description="Sắp xếp: price_asc, price_desc, sold_desc, dopamine_desc"),
    db: Session = Depends(get_db)
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

    return query.all()

