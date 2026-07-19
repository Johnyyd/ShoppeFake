from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import Voucher, UserVoucher, User
from app.auth import get_current_user, get_current_user_optional
from app.schemas import VoucherResponse, VoucherValidateRequest, VoucherValidateResponse, UserVoucherResponse

router = APIRouter(prefix="/vouchers", tags=["vouchers"])

@router.get("/active", response_model=List[VoucherResponse])
def get_active_vouchers(
    db: Session = Depends(get_db),
    user: Optional[User] = Depends(get_current_user_optional)
):
    vouchers = db.query(Voucher).filter(Voucher.is_active == True).all()
    existing_codes = {v.code for v in db.query(Voucher).all()}
    baseline_vouchers = [
        Voucher(code="ORANGE50K", discount_type="FIXED", discount_value=50000.00, min_order_value=150000.00, max_discount=None, usage_limit=500, is_active=True),
        Voucher(code="WELCOME20", discount_type="PERCENT", discount_value=20.00, min_order_value=0.00, max_discount=200000.00, usage_limit=1000, is_active=True),
        Voucher(code="SHOPEE100K", discount_type="FIXED", discount_value=100000.00, min_order_value=500000.00, max_discount=None, usage_limit=2000, is_active=True),
        Voucher(code="TECH300K", discount_type="FIXED", discount_value=300000.00, min_order_value=2000000.00, max_discount=None, usage_limit=1000, is_active=True),
        Voucher(code="VIP500K", discount_type="FIXED", discount_value=500000.00, min_order_value=5000000.00, max_discount=None, usage_limit=500, is_active=True)
    ]
    missing = [v for v in baseline_vouchers if v.code not in existing_codes]
    if missing:
        db.add_all(missing)
        db.commit()
        vouchers = db.query(Voucher).filter(Voucher.is_active == True).all()

    claimed_ids = set()
    if user and isinstance(user, User):
        claims = db.query(UserVoucher.voucher_id).filter(
            UserVoucher.user_id == user.id,
            UserVoucher.is_used == False
        ).all()
        claimed_ids = {c[0] for c in claims}

    results = []
    for v in vouchers:
        v_resp = VoucherResponse.model_validate(v)
        v_resp.is_claimed = v.id in claimed_ids
        results.append(v_resp)

    return results

@router.post("/{voucher_id}/claim", response_model=UserVoucherResponse)
def claim_voucher(
    voucher_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    voucher = db.query(Voucher).filter(Voucher.id == voucher_id, Voucher.is_active == True).first()
    if not voucher:
        raise HTTPException(status_code=404, detail="Mã giảm giá không tồn tại hoặc đã hết hạn.")

    if voucher.used_count >= voucher.usage_limit:
        raise HTTPException(status_code=400, detail="Mã giảm giá đã được phát hết lượt.")

    existing_claim = db.query(UserVoucher).filter(
        UserVoucher.user_id == user.id,
        UserVoucher.voucher_id == voucher_id,
        UserVoucher.is_used == False
    ).first()
    if existing_claim:
        raise HTTPException(status_code=400, detail="Bạn đã lưu voucher này rồi trong ví.")

    new_claim = UserVoucher(
        user_id=user.id,
        voucher_id=voucher_id,
        is_used=False
    )
    db.add(new_claim)
    db.commit()
    db.refresh(new_claim)
    return new_claim

@router.get("/my-vouchers", response_model=List[UserVoucherResponse])
def get_my_vouchers(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    claims = db.query(UserVoucher).filter(
        UserVoucher.user_id == user.id,
        UserVoucher.is_used == False
    ).all()
    return claims

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
