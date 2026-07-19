from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
from app.database import engine, Base
from app.routers import auth, products, checkout, sellers, vouchers, categories, cart, orders, favorites
from app.limiter import limiter

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Create tables on startup if not existing
    try:
        Base.metadata.create_all(bind=engine)
        from sqlalchemy import text
        with engine.connect() as conn:
            alter_queries = [
                "ALTER TABLE Virtual_Products ADD seller_id INTEGER NULL",
                "ALTER TABLE Virtual_Products ADD category_id INTEGER NULL",
                "ALTER TABLE Virtual_Products ADD original_price FLOAT NULL",
                "ALTER TABLE Virtual_Products ADD discount_percentage INTEGER DEFAULT 0",
                "ALTER TABLE Virtual_Products ADD stock_quantity INTEGER DEFAULT 999",
                "ALTER TABLE Virtual_Products ADD sold_count INTEGER DEFAULT 0",
                "ALTER TABLE Virtual_Products ADD average_rating FLOAT DEFAULT 5.0",
                "ALTER TABLE Virtual_Orders ADD voucher_code NVARCHAR(50) NULL",
                "ALTER TABLE Virtual_Orders ADD discount_amount FLOAT DEFAULT 0.0",
                "ALTER TABLE Virtual_Orders ADD quantity INTEGER DEFAULT 1",
                "ALTER TABLE Virtual_Orders ADD status NVARCHAR(50) DEFAULT 'Chờ xác nhận'",
                "ALTER TABLE Users ADD last_checkin_date NVARCHAR(50) NULL",
                "ALTER TABLE Users ADD checkin_streak INTEGER DEFAULT 0",
                "ALTER TABLE Users ALTER COLUMN username NVARCHAR(100) NOT NULL",
                "ALTER TABLE Categories ALTER COLUMN name NVARCHAR(100) NOT NULL",
                "ALTER TABLE Categories ALTER COLUMN icon_name NVARCHAR(50) NOT NULL",
                "ALTER TABLE Categories ALTER COLUMN banner_url NVARCHAR(500) NULL",
                "ALTER TABLE Sellers ALTER COLUMN shop_name NVARCHAR(200) NOT NULL",
                "ALTER TABLE Sellers ALTER COLUMN description NVARCHAR(1000) NULL",
                "ALTER TABLE Sellers ALTER COLUMN logo_url NVARCHAR(500) NULL",
                "ALTER TABLE Vouchers ALTER COLUMN code NVARCHAR(50) NOT NULL",
                "ALTER TABLE Vouchers ALTER COLUMN discount_type NVARCHAR(20) NOT NULL",
                "ALTER TABLE Virtual_Products ALTER COLUMN name NVARCHAR(200) NOT NULL",
                "ALTER TABLE Virtual_Products ALTER COLUMN description NVARCHAR(1000) NULL",
                "ALTER TABLE Virtual_Products ALTER COLUMN image_url NVARCHAR(500) NULL",
                "ALTER TABLE Virtual_Products ALTER COLUMN category NVARCHAR(100) NOT NULL",
                "ALTER TABLE Product_Images ALTER COLUMN image_url NVARCHAR(500) NOT NULL",
                "ALTER TABLE Product_Reviews ALTER COLUMN comment NVARCHAR(1000) NULL",
                "UPDATE Virtual_Products SET discount_percentage = 0 WHERE discount_percentage IS NULL",
                "UPDATE Virtual_Products SET stock_quantity = 999 WHERE stock_quantity IS NULL",
                "UPDATE Virtual_Products SET sold_count = 0 WHERE sold_count IS NULL",
                "UPDATE Virtual_Products SET average_rating = 5.0 WHERE average_rating IS NULL",
                "UPDATE Virtual_Products SET category = 'Chung' WHERE category IS NULL OR category = ''",
                "UPDATE Virtual_Orders SET status = 'Chờ xác nhận' WHERE status = 'DELIVERED' OR status IS NULL"
            ]
            for query in alter_queries:
                try:
                    conn.execute(text(query))
                    conn.commit()
                except Exception:
                    pass
        from app.database import SessionLocal
        db = SessionLocal()
        try:
            from app.models import VirtualProduct, Category, Seller, ProductImage, ProductReview
            # Clean up old records corrupted by lack of UTF-8 encoding (which contained '?' replacing Vietnamese characters)
            corrupted_prod = db.query(VirtualProduct).filter(VirtualProduct.name.contains("?")).first()
            if corrupted_prod:
                db.query(ProductImage).delete()
                db.query(ProductReview).delete()
                db.query(VirtualProduct).delete()
                db.commit()
            corrupted_cat = db.query(Category).filter(Category.name.contains("?")).first()
            if corrupted_cat:
                db.query(Category).delete()
                db.commit()
            corrupted_seller = db.query(Seller).filter(Seller.shop_name.contains("?")).first()
            if corrupted_seller:
                db.query(Seller).delete()
                db.commit()

            from app.routers.sellers import get_sellers
            from app.routers.vouchers import get_active_vouchers
            from app.routers.categories import seed_categories
            from app.routers.products import seed_products_and_related
            get_sellers(db)
            get_active_vouchers(db)
            seed_categories(db)
            seed_products_and_related(db)
        finally:
            db.close()
    except Exception as e:
        print(f"Warning: could not create or migrate tables on startup: {e}")
    yield

app = FastAPI(
    title="Gamified Virtual Shopping Application (Dopamine Booster) API",
    description="High-performance backend simulation with virtual currency and dopamine reward tracking.",
    version="1.0.0",
    lifespan=lifespan
)

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.add_middleware(SlowAPIMiddleware)

# Configure CORS securely for local development and Tailscale public funnels
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https://.*\.ts\.net|http://(localhost|127\.0\.0\.1)(:[0-9]+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(products.router)
app.include_router(checkout.router)
app.include_router(sellers.router)
app.include_router(vouchers.router)
app.include_router(categories.router)
app.include_router(cart.router)
app.include_router(orders.router)
app.include_router(favorites.router)

@app.get("/health")
def health_check():
    return {"status": "ok", "dopamine_system": "online"}

