from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session, joinedload
from app.database import get_db
from app.models import User, VirtualProduct, VirtualOrder, Voucher, CartItem
from app.schemas import CheckoutRequest, CheckoutResponse
from app.auth import get_current_user
from app.limiter import limiter

router = APIRouter(prefix="/checkout", tags=["checkout"])

@router.post("", response_model=CheckoutResponse)
@limiter.limit("30/minute")
def process_virtual_checkout(
    request: Request,
    checkout_in: CheckoutRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    orders_to_create = []
    total_raw_price = 0.0
    total_dopamine = 0
    product_names = []
    cart_items_to_delete = []

    if checkout_in.item_ids and len(checkout_in.item_ids) > 0:
        # Cart Checkout
        cart_items = (
            db.query(CartItem)
            .options(joinedload(CartItem.product))
            .filter(CartItem.id.in_(checkout_in.item_ids), CartItem.user_id == current_user.id)
            .all()
        )
        if not cart_items:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Không tìm thấy sản phẩm hợp lệ trong giỏ hàng.")

        for item in cart_items:
            item_price = item.quantity * item.product.price_virtual
            item_dopamine = item.quantity * item.product.dopamine_rating
            total_raw_price += item_price
            total_dopamine += item_dopamine
            product_names.append(f"{item.product.name} (x{item.quantity})")
            cart_items_to_delete.append(item)
            orders_to_create.append({
                "product_id": item.product.id,
                "quantity": item.quantity,
                "virtual_price_paid": item_price,
                "dopamine_hits_awarded": item_dopamine,
                "product": item.product
            })
    elif checkout_in.product_id:
        # Single Item Buy Now
        product = db.query(VirtualProduct).filter(VirtualProduct.id == checkout_in.product_id).first()
        if not product:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Sản phẩm không tồn tại.")
        
        qty = checkout_in.quantity if checkout_in.quantity > 0 else 1
        total_raw_price = product.price_virtual * qty
        total_dopamine = product.dopamine_rating * qty
        product_names.append(f"{product.name}" + (f" (x{qty})" if qty > 1 else ""))
        orders_to_create.append({
            "product_id": product.id,
            "quantity": qty,
            "virtual_price_paid": total_raw_price,
            "dopamine_hits_awarded": total_dopamine,
            "product": product
        })
    else:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Vui lòng chọn ít nhất 1 sản phẩm để thanh toán.")

    # Process Voucher if provided
    discount_amount = 0.0
    voucher = None
    if checkout_in.voucher_code:
        voucher = db.query(Voucher).filter(Voucher.code == checkout_in.voucher_code.upper(), Voucher.is_active == True).first()
        if not voucher:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Mã giảm giá không hợp lệ hoặc không tồn tại.")
        if voucher.used_count >= voucher.usage_limit:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Mã giảm giá đã hết lượt sử dụng.")
        if total_raw_price < voucher.min_order_value:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Đơn hàng cần đạt tối thiểu {voucher.min_order_value:.0f} xu để dùng voucher này.")
        
        if voucher.discount_type == "PERCENT":
            discount_amount = total_raw_price * (voucher.discount_value / 100.0)
            if voucher.max_discount and discount_amount > voucher.max_discount:
                discount_amount = voucher.max_discount
        else:
            discount_amount = voucher.discount_value
        
        if discount_amount > total_raw_price:
            discount_amount = total_raw_price

    final_price = total_raw_price - discount_amount

    # Verify virtual balance
    if current_user.virtual_balance < final_price:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Số dư xu ảo không đủ ({current_user.virtual_balance:.1f} hiện có vs {final_price:.1f} cần thanh toán sau giảm giá)."
        )

    # Atomic transaction
    try:
        current_user.virtual_balance -= final_price
        current_user.dopamine_level += total_dopamine

        if voucher:
            voucher.used_count += 1

        first_order = None
        for idx, o_data in enumerate(orders_to_create):
            # Pro-rate discount for the items if multiple, or assign all to first order
            item_discount = discount_amount if idx == 0 else 0.0
            order = VirtualOrder(
                user_id=current_user.id,
                product_id=o_data["product_id"],
                quantity=o_data["quantity"],
                virtual_price_paid=o_data["virtual_price_paid"] - item_discount,
                dopamine_hits_awarded=o_data["dopamine_hits_awarded"],
                voucher_code=voucher.code if voucher else None,
                discount_amount=item_discount,
                status="Chờ xác nhận"
            )
            # Update sold count
            o_data["product"].sold_count += o_data["quantity"]
            db.add(order)
            if idx == 0:
                first_order = order

        for c_item in cart_items_to_delete:
            db.delete(c_item)

        db.commit()
        if first_order:
            db.refresh(first_order)
        db.refresh(current_user)
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi giao dịch thanh toán ảo: {str(e)}"
        )

    display_name = ", ".join(product_names[:2]) + (f" và {len(product_names)-2} sản phẩm khác" if len(product_names) > 2 else "")

    return CheckoutResponse(
        order_id=first_order.id if first_order else 1,
        product_name=display_name,
        virtual_price_paid=final_price,
        discount_amount=discount_amount,
        new_virtual_balance=current_user.virtual_balance,
        dopamine_hits_awarded=total_dopamine,
        new_dopamine_level=current_user.dopamine_level,
        animation_trigger="EXTREME_CONFETTI_BURST",
        message=f"DOPAMINE SURGE! Bạn đã sở hữu {display_name}" + (f" (Giảm {discount_amount:.0f} xu nhờ mã {voucher.code})" if voucher else "") + f" và nhận +{total_dopamine} điểm Dopamine!"
    )

