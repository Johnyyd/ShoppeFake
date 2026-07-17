from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field, field_validator

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
    virtual_balance: Optional[float] = 5000.0
    dopamine_level: Optional[int] = 0
    last_checkin_date: Optional[str] = None
    checkin_streak: Optional[int] = 0

class UserResponse(BaseModel):
    id: int
    username: str
    virtual_balance: Optional[float] = 5000.0
    dopamine_level: Optional[int] = 0
    last_checkin_date: Optional[str] = None
    checkin_streak: Optional[int] = 0
    created_at: datetime

    class Config:
        from_attributes = True

class DailyCheckinResponse(BaseModel):
    message: str
    reward_coins: float
    reward_dopamine: int
    streak: int
    virtual_balance: float
    dopamine_level: int

class CategoryResponse(BaseModel):
    id: int
    name: str
    icon_name: str
    banner_url: Optional[str] = None

    class Config:
        from_attributes = True

class SellerResponse(BaseModel):
    id: int
    shop_name: str
    description: Optional[str] = None
    logo_url: Optional[str] = None
    rating: float
    is_verified: bool

    class Config:
        from_attributes = True

class VoucherResponse(BaseModel):
    id: int
    code: str
    discount_type: str
    discount_value: float
    min_order_value: float
    max_discount: Optional[float] = None
    is_active: bool
    is_claimed: bool = False

    class Config:
        from_attributes = True

class UserVoucherResponse(BaseModel):
    id: int
    voucher_id: int
    is_used: bool
    claimed_at: datetime
    voucher: VoucherResponse

    class Config:
        from_attributes = True

class VoucherValidateRequest(BaseModel):
    code: str
    order_amount: float

class VoucherValidateResponse(BaseModel):
    valid: bool
    discount_amount: float
    message: str

class ProductImageResponse(BaseModel):
    id: int
    image_url: str
    display_order: int

    class Config:
        from_attributes = True

class ProductReviewCreate(BaseModel):
    rating: int = Field(..., ge=1, le=5)
    comment: Optional[str] = None

class ProductReviewResponse(BaseModel):
    id: int
    rating: int
    comment: Optional[str] = None
    created_at: datetime
    username: Optional[str] = None

    class Config:
        from_attributes = True

class ProductResponse(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    price_virtual: float
    original_price: Optional[float] = None
    discount_percentage: Optional[int] = 0
    image_url: Optional[str] = None
    dopamine_rating: int
    category_name: str = Field("Chung", alias="category")
    category_id: Optional[int] = None
    seller_id: Optional[int] = None
    stock_quantity: Optional[int] = 999
    sold_count: Optional[int] = 0
    average_rating: Optional[float] = 5.0
    seller: Optional[SellerResponse] = None
    images: List[ProductImageResponse] = []
    reviews: List[ProductReviewResponse] = []
    is_favorite: bool = False

    @field_validator("category_name", mode="before")
    @classmethod
    def resolve_category_str(cls, v):
        if hasattr(v, "name"):
            return v.name
        return str(v) if v is not None else "Chung"

    @field_validator("discount_percentage", "stock_quantity", "sold_count", mode="before")
    @classmethod
    def resolve_int_defaults(cls, v):
        return v if v is not None else 0

    @field_validator("average_rating", mode="before")
    @classmethod
    def resolve_float_defaults(cls, v):
        return float(v) if v is not None else 5.0

    class Config:
        from_attributes = True
        populate_by_name = True

class CartItemCreate(BaseModel):
    product_id: int
    quantity: int = 1

class CartItemUpdate(BaseModel):
    quantity: int = Field(..., ge=1)

class CartItemResponse(BaseModel):
    id: int
    product_id: int
    quantity: int
    product: ProductResponse
    created_at: datetime

    class Config:
        from_attributes = True

class CartSummaryResponse(BaseModel):
    items: List[CartItemResponse]
    total_items: int
    total_price: float
    total_dopamine: int

class CheckoutRequest(BaseModel):
    product_id: Optional[int] = None
    item_ids: Optional[List[int]] = None # List of CartItem IDs for Cart Checkout
    quantity: int = 1
    voucher_code: Optional[str] = None

class CheckoutResponse(BaseModel):
    order_id: int
    product_name: str
    virtual_price_paid: float
    discount_amount: float = 0.0
    new_virtual_balance: float
    dopamine_hits_awarded: int
    new_dopamine_level: int
    animation_trigger: str = "EXTREME_CONFETTI_BURST"
    message: str

class OrderResponse(BaseModel):
    id: int
    product_id: int
    quantity: int
    virtual_price_paid: float
    dopamine_hits_awarded: int
    voucher_code: Optional[str] = None
    discount_amount: float = 0.0
    status: str
    created_at: datetime
    product: ProductResponse

    class Config:
        from_attributes = True

class OrderStatusUpdate(BaseModel):
    status: str


class FavoriteToggleResponse(BaseModel):
    product_id: int
    is_favorite: bool
    message: str



