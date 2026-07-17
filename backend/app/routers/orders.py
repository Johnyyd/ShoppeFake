from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from app.database import get_db
from app.models import User, VirtualOrder
from app.schemas import OrderResponse, OrderStatusUpdate
from app.auth import get_current_user

router = APIRouter(prefix="/orders", tags=["orders"])

@router.get("", response_model=List[OrderResponse])
def get_user_orders(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    orders = (
        db.query(VirtualOrder)
        .options(joinedload(VirtualOrder.product))
        .filter(VirtualOrder.user_id == current_user.id)
        .order_by(VirtualOrder.created_at.desc())
        .all()
    )
    return orders

@router.put("/{order_id}/status", response_model=OrderResponse)
def update_order_status(
    order_id: int,
    status_update: OrderStatusUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    order = (
        db.query(VirtualOrder)
        .options(joinedload(VirtualOrder.product))
        .filter(VirtualOrder.id == order_id, VirtualOrder.user_id == current_user.id)
        .first()
    )
    if not order:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Đơn hàng không tồn tại")
    
    order.status = status_update.status
    db.commit()
    db.refresh(order)
    return order
