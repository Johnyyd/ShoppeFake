### Task 1: Post-Order Review & Reward System (Backend)

**Files:**
- Modify: `backend/app/models.py`
- Modify: `backend/app/schemas.py`
- Modify: `backend/app/routers/products.py`

**Interfaces:**
- Consumes: `User` model, `VirtualOrder` model, `VirtualProduct` model, `get_current_user` auth dependency.
- Produces: `POST /products/{product_id}/reviews` endpoint accepting `{ "rating": int, "comment": str }`, returning updated `ProductReviewResponse` and awarding `+50.0` virtual balance and `+30` dopamine level.

- [ ] **Step 1: Add review submission schema in `schemas.py`**
- [ ] **Step 2: Add `POST /products/{product_id}/reviews` route in `backend/app/routers/products.py`**
- [ ] **Step 3: Verify endpoint with curl or pytest/python verification script**
