from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import User, VirtualProduct, VirtualOrder
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
    # Fetch product
    product = db.query(VirtualProduct).filter(VirtualProduct.id == checkout_in.product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Virtual product not found."
        )

    # Verify virtual currency balance
    if current_user.virtual_balance < product.price_virtual:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Insufficient virtual balance ({current_user.virtual_balance:.2f} available vs {product.price_virtual:.2f} needed)."
        )

    # Atomic transaction using parameterized ORM properties
    try:
        current_user.virtual_balance -= product.price_virtual
        current_user.dopamine_level += product.dopamine_rating

        order = VirtualOrder(
            user_id=current_user.id,
            product_id=product.id,
            virtual_price_paid=product.price_virtual,
            dopamine_hits_awarded=product.dopamine_rating
        )
        db.add(order)
        db.commit()
        db.refresh(order)
        db.refresh(current_user)
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Transaction failed during virtual checkout processing."
        )

    return CheckoutResponse(
        order_id=order.id,
        product_name=product.name,
        virtual_price_paid=order.virtual_price_paid,
        new_virtual_balance=current_user.virtual_balance,
        dopamine_hits_awarded=order.dopamine_hits_awarded,
        new_dopamine_level=current_user.dopamine_level,
        animation_trigger="EXTREME_CONFETTI_BURST",
        message=f"DOPAMINE SURGE! You successfully acquired {product.name} and gained +{product.dopamine_rating} dopamine points!"
    )
