from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from app.database import get_db
from app.models import User, VirtualProduct, CartItem
from app.schemas import CartItemCreate, CartItemUpdate, CartItemResponse, CartSummaryResponse
from app.auth import get_current_user

router = APIRouter(prefix="/cart", tags=["cart"])

@router.get("", response_model=CartSummaryResponse)
def get_cart(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    items = (
        db.query(CartItem)
        .options(
            joinedload(CartItem.product).joinedload(VirtualProduct.seller),
            joinedload(CartItem.product).joinedload(VirtualProduct.images)
        )
        .filter(CartItem.user_id == current_user.id)
        .all()
    )
    
    total_items = sum(item.quantity for item in items)
    total_price = sum(item.quantity * item.product.price_virtual for item in items)
    total_dopamine = sum(item.quantity * item.product.dopamine_rating for item in items)

    return CartSummaryResponse(
        items=items,
        total_items=total_items,
        total_price=total_price,
        total_dopamine=total_dopamine
    )

@router.post("/add", response_model=CartItemResponse)
def add_to_cart(
    item_in: CartItemCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    product = db.query(VirtualProduct).filter(VirtualProduct.id == item_in.product_id).first()
    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Sản phẩm không tồn tại.")

    cart_item = (
        db.query(CartItem)
        .filter(CartItem.user_id == current_user.id, CartItem.product_id == item_in.product_id)
        .first()
    )

    if cart_item:
        cart_item.quantity += item_in.quantity
    else:
        cart_item = CartItem(
            user_id=current_user.id,
            product_id=item_in.product_id,
            quantity=item_in.quantity
        )
        db.add(cart_item)

    db.commit()
    db.refresh(cart_item)
    
    # Reload with relationships
    cart_item = (
        db.query(CartItem)
        .options(
            joinedload(CartItem.product).joinedload(VirtualProduct.seller),
            joinedload(CartItem.product).joinedload(VirtualProduct.images)
        )
        .filter(CartItem.id == cart_item.id)
        .first()
    )
    return cart_item

@router.put("/{item_id}", response_model=CartItemResponse)
def update_cart_item(
    item_id: int,
    item_in: CartItemUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    cart_item = (
        db.query(CartItem)
        .filter(CartItem.id == item_id, CartItem.user_id == current_user.id)
        .first()
    )
    if not cart_item:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Sản phẩm không có trong giỏ hàng.")

    cart_item.quantity = item_in.quantity
    db.commit()
    db.refresh(cart_item)

    cart_item = (
        db.query(CartItem)
        .options(
            joinedload(CartItem.product).joinedload(VirtualProduct.seller),
            joinedload(CartItem.product).joinedload(VirtualProduct.images)
        )
        .filter(CartItem.id == cart_item.id)
        .first()
    )
    return cart_item

@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_cart_item(
    item_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    cart_item = (
        db.query(CartItem)
        .filter(CartItem.id == item_id, CartItem.user_id == current_user.id)
        .first()
    )
    if not cart_item:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Sản phẩm không có trong giỏ hàng.")

    db.delete(cart_item)
    db.commit()
    return None

@router.delete("/clear", status_code=status.HTTP_204_NO_CONTENT)
def clear_cart(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db.query(CartItem).filter(CartItem.user_id == current_user.id).delete()
    db.commit()
    return None
