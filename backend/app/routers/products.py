from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import VirtualProduct
from app.schemas import ProductResponse

router = APIRouter(prefix="/products", tags=["products"])

@router.get("", response_model=List[ProductResponse])
def get_products(db: Session = Depends(get_db)):
    products = db.query(VirtualProduct).all()
    if not products:
        # Auto-seed baseline items if table is empty
        baseline_items = [
            VirtualProduct(name="Neon Cyber-Sneakers Mk.VII", description="Glowing holographic sneakers that boost virtual swagger.", price_virtual=499.99, image_url="https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&w=600&q=80", dopamine_rating=100, category="Footwear"),
            VirtualProduct(name="Golden Quantum Rolex", description="Transcends time itself. Pure status symbol.", price_virtual=2499.00, image_url="https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=600&q=80", dopamine_rating=500, category="Watches"),
            VirtualProduct(name="Prismatic Gaming Rig 9000", description="Liquid-cooled dual-4090 virtual setup with RGB aura.", price_virtual=1899.50, image_url="https://images.unsplash.com/photo-1587202372775-e229f172b9d7?auto=format&fit=crop&w=600&q=80", dopamine_rating=350, category="Electronics"),
            VirtualProduct(name="Celestial Hoverboard", description="Anti-gravity street surfing board with starlight trail.", price_virtual=899.00, image_url="https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80", dopamine_rating=250, category="Vehicles"),
            VirtualProduct(name="Platinum VIP Crown", description="Permanent aura of prestige across all virtual chatrooms.", price_virtual=3999.99, image_url="https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=600&q=80", dopamine_rating=1000, category="Prestige")
        ]
        db.add_all(baseline_items)
        db.commit()
        products = db.query(VirtualProduct).all()
    return products
