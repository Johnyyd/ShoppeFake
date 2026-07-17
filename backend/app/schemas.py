from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field

class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    password: str = Field(..., min_length=6)

class UserLogin(BaseModel):
    username: str
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    username: str
    virtual_balance: float
    dopamine_level: int

class UserResponse(BaseModel):
    id: int
    username: str
    virtual_balance: float
    dopamine_level: int
    created_at: datetime

    class Config:
        from_attributes = True

class ProductResponse(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    price_virtual: float
    image_url: Optional[str] = None
    dopamine_rating: int
    category: str

    class Config:
        from_attributes = True

class CheckoutRequest(BaseModel):
    product_id: int

class CheckoutResponse(BaseModel):
    order_id: int
    product_name: str
    virtual_price_paid: float
    new_virtual_balance: float
    dopamine_hits_awarded: int
    new_dopamine_level: int
    animation_trigger: str = "EXTREME_CONFETTI_BURST"
    message: str
