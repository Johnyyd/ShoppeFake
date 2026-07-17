from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import Voucher
from app.schemas import VoucherResponse, VoucherValidateRequest, VoucherValidateResponse

router = APIRouter(prefix="/vouchers", tags=["vouchers"])

@router.get("/active", response_model=List[VoucherResponse])
def get_active_vouchers(db: Session = Depends(get_db)):
    vouchers = db.query(Voucher).filter(Voucher.is_active == True).all()
    if not vouchers:
        # Auto-seed baseline vouchers if table is empty
        baseline_vouchers = [
            Voucher(code="ORANGE500", discount_type="FIXED", discount_value=500.00, min_order_value=1000.00, max_discount=None, usage_limit=500, is_active=True),
            Voucher(code="WELCOME20", discount_type="PERCENT", discount_value=20.00, min_order_value=0.00, max_discount=1000.00, usage_limit=1000, is_active=True),
            Voucher(code="CYBER10", discount_type="PERCENT", discount_value=10.00, min_order_value=500.00, max_discount=300.00, usage_limit=2000, is_active=True)
        ]
        db.add_all(baseline_vouchers)
        db.commit()
        vouchers = db.query(Voucher).filter(Voucher.is_active == True).all()
    return vouchers

@router.post("/validate", response_model=VoucherValidateResponse)
def validate_voucher(req: VoucherValidateRequest, db: Session = Depends(get_db)):
    voucher = db.query(Voucher).filter(Voucher.code == req.code.upper(), Voucher.is_active == True).first()
    if not voucher:
        return VoucherValidateResponse(valid=False, discount_amount=0.0, message="Mã giảm giá không tồn tại hoặc đã hết hạn.")
    
    if voucher.used_count >= voucher.usage_limit:
        return VoucherValidateResponse(valid=False, discount_amount=0.0, message="Mã giảm giá đã hết lượt sử dụng.")

    if req.order_amount < voucher.min_order_value:
        return VoucherValidateResponse(valid=False, discount_amount=0.0, message=f"Đơn hàng cần đạt tối thiểu {voucher.min_order_value:.0f} xu để sử dụng mã này.")

    discount = 0.0
    if voucher.discount_type == "PERCENT":
        discount = req.order_amount * (voucher.discount_value / 100.0)
        if voucher.max_discount and discount > voucher.max_discount:
            discount = voucher.max_discount
    else:
        discount = voucher.discount_value

    if discount > req.order_amount:
        discount = req.order_amount

    return VoucherValidateResponse(
        valid=True,
        discount_amount=discount,
        message=f"Áp dụng mã giảm giá {voucher.code} thành công! Giảm {discount:.0f} xu."
    )
