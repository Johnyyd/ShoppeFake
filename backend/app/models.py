from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base

class User(Base):
    __tablename__ = "Users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(100), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    virtual_balance = Column(Float, default=5000.00, nullable=False)
    dopamine_level = Column(Integer, default=0, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    orders = relationship("VirtualOrder", back_populates="user")


class VirtualProduct(Base):
    __tablename__ = "Virtual_Products"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200), nullable=False)
    description = Column(String(1000), nullable=True)
    price_virtual = Column(Float, nullable=False)
    image_url = Column(String(500), nullable=True)
    dopamine_rating = Column(Integer, default=10, nullable=False)
    category = Column(String(100), default="Luxury", nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    orders = relationship("VirtualOrder", back_populates="product")


class VirtualOrder(Base):
    __tablename__ = "Virtual_Orders"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("Users.id"), nullable=False)
    product_id = Column(Integer, ForeignKey("Virtual_Products.id"), nullable=False)
    virtual_price_paid = Column(Float, nullable=False)
    dopamine_hits_awarded = Column(Integer, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="orders")
    product = relationship("VirtualProduct", back_populates="orders")
