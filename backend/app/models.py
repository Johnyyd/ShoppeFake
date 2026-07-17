from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Boolean, Unicode
from sqlalchemy.orm import relationship
from app.database import Base

class User(Base):
    __tablename__ = "Users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(Unicode(100), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    virtual_balance = Column(Float, default=5000.00, nullable=False)
    dopamine_level = Column(Integer, default=0, nullable=False)
    last_checkin_date = Column(String(50), nullable=True)
    checkin_streak = Column(Integer, default=0, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    orders = relationship("VirtualOrder", back_populates="user")
    cart_items = relationship("CartItem", back_populates="user", cascade="all, delete-orphan")
    reviews = relationship("ProductReview", back_populates="user", cascade="all, delete-orphan")
    claimed_vouchers = relationship("UserVoucher", back_populates="user", cascade="all, delete-orphan")
    favorites = relationship("UserFavorite", back_populates="user", cascade="all, delete-orphan")


class Category(Base):
    __tablename__ = "Categories"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(Unicode(100), unique=True, index=True, nullable=False)
    icon_name = Column(Unicode(50), default="category", nullable=False)
    banner_url = Column(Unicode(500), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    products = relationship("VirtualProduct", back_populates="category")


class Seller(Base):
    __tablename__ = "Sellers"

    id = Column(Integer, primary_key=True, index=True)
    shop_name = Column(Unicode(200), nullable=False)
    description = Column(Unicode(1000), nullable=True)
    logo_url = Column(Unicode(500), nullable=True)
    rating = Column(Float, default=5.00, nullable=False)
    is_verified = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    products = relationship("VirtualProduct", back_populates="seller")


class Voucher(Base):
    __tablename__ = "Vouchers"

    id = Column(Integer, primary_key=True, index=True)
    code = Column(Unicode(50), unique=True, index=True, nullable=False)
    discount_type = Column(Unicode(20), default="PERCENT", nullable=False)
    discount_value = Column(Float, nullable=False)
    min_order_value = Column(Float, default=0.0, nullable=False)
    max_discount = Column(Float, nullable=True)
    usage_limit = Column(Integer, default=1000, nullable=False)
    used_count = Column(Integer, default=0, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    user_claims = relationship("UserVoucher", back_populates="voucher", cascade="all, delete-orphan")


class UserVoucher(Base):
    __tablename__ = "User_Vouchers"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("Users.id"), nullable=False)
    voucher_id = Column(Integer, ForeignKey("Vouchers.id"), nullable=False)
    is_used = Column(Boolean, default=False, nullable=False)
    claimed_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="claimed_vouchers")
    voucher = relationship("Voucher", back_populates="user_claims")


class VirtualProduct(Base):
    __tablename__ = "Virtual_Products"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(Unicode(200), nullable=False)
    description = Column(Unicode(1000), nullable=True)
    price_virtual = Column(Float, nullable=False)
    original_price = Column(Float, nullable=True)
    discount_percentage = Column(Integer, default=0, nullable=False)
    image_url = Column(Unicode(500), nullable=True)
    dopamine_rating = Column(Integer, default=10, nullable=False)
    category_name = Column("category", Unicode(100), default="Luxury", nullable=False)
    category_id = Column(Integer, ForeignKey("Categories.id"), nullable=True)
    seller_id = Column(Integer, ForeignKey("Sellers.id"), nullable=True)
    stock_quantity = Column(Integer, default=999, nullable=False)
    sold_count = Column(Integer, default=0, nullable=False)
    average_rating = Column(Float, default=5.0, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    seller = relationship("Seller", back_populates="products")
    category = relationship("Category", back_populates="products")
    images = relationship("ProductImage", back_populates="product", cascade="all, delete-orphan", order_by="ProductImage.display_order")
    reviews = relationship("ProductReview", back_populates="product", cascade="all, delete-orphan")
    orders = relationship("VirtualOrder", back_populates="product")
    cart_items = relationship("CartItem", back_populates="product", cascade="all, delete-orphan")
    favorited_by = relationship("UserFavorite", back_populates="product", cascade="all, delete-orphan")


class ProductImage(Base):
    __tablename__ = "Product_Images"

    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer, ForeignKey("Virtual_Products.id"), nullable=False, index=True)
    image_url = Column(Unicode(500), nullable=False)
    display_order = Column(Integer, default=0, nullable=False)

    product = relationship("VirtualProduct", back_populates="images")


class ProductReview(Base):
    __tablename__ = "Product_Reviews"

    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer, ForeignKey("Virtual_Products.id"), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey("Users.id"), nullable=False, index=True)
    rating = Column(Integer, default=5, nullable=False)
    comment = Column(Unicode(1000), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    product = relationship("VirtualProduct", back_populates="reviews")
    user = relationship("User", back_populates="reviews")

    @property
    def username(self):
        return self.user.username if self.user else "Anonymous"


class CartItem(Base):
    __tablename__ = "Cart_Items"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("Users.id"), nullable=False, index=True)
    product_id = Column(Integer, ForeignKey("Virtual_Products.id"), nullable=False, index=True)
    quantity = Column(Integer, default=1, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="cart_items")
    product = relationship("VirtualProduct", back_populates="cart_items")


class VirtualOrder(Base):
    __tablename__ = "Virtual_Orders"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("Users.id"), nullable=False)
    product_id = Column(Integer, ForeignKey("Virtual_Products.id"), nullable=False)
    quantity = Column(Integer, default=1, nullable=False)
    virtual_price_paid = Column(Float, nullable=False)
    dopamine_hits_awarded = Column(Integer, nullable=False)
    voucher_code = Column(Unicode(50), nullable=True)
    discount_amount = Column(Float, default=0.0, nullable=False)
    status = Column(Unicode(50), default="DELIVERED", nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="orders")
    product = relationship("VirtualProduct", back_populates="orders")


class UserFavorite(Base):
    __tablename__ = "User_Favorites"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("Users.id"), nullable=False, index=True)
    product_id = Column(Integer, ForeignKey("Virtual_Products.id"), nullable=False, index=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="favorites")
    product = relationship("VirtualProduct", back_populates="favorited_by")

