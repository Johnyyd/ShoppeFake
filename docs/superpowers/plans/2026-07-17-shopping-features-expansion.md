# Gamified E-Commerce Features Expansion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expand and develop missing features compared to a complete online shopping application (Shopee/E-commerce standards) while maximizing the gamified "Dopamine Booster" experience with high-craft animations and virtual currency rewards.

**Architecture:** Python FastAPI backend connected to SQL Server via SQLAlchemy, providing state and reward verification for Dart Flutter mobile app. All animations strictly adhere to Emil Kowalski's design engineering rules (`review-animations` standard: sub-300ms UI, ease-out curves, GPU-only properties, interruptible springs, and reduced-motion compliance).

**Tech Stack:** Flutter (Dart), Provider, Confetti, FastAPI (Python), SQLAlchemy, SQL Server (Docker).

## Global Constraints

- No real financial transactions; all currency is `Virtual Balance` ($) and rewards are `Dopamine Level` hits.
- Animations must follow `review-animations`: `ease-out` for entrances, sub-300ms UI duration, `transform` / `opacity` only, `prefers-reduced-motion` compliance.
- Backend API must validate all inputs and verify user status before awarding virtual balance or dopamine hits.
- Preserve existing code conventions, Vietnamese copy for UI, and clean separation of concerns.

---

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

---

### Task 2: Post-Order Review & Reward System (Frontend)

**Files:**
- Modify: `mobile/lib/services/api_client.dart`
- Modify: `mobile/lib/providers/shoppe_provider.dart`
- Modify: `mobile/lib/screens/orders_screen.dart`
- Create: `mobile/lib/widgets/product_review_modal.dart`

**Interfaces:**
- Consumes: `POST /products/{product_id}/reviews` from Backend.
- Produces: Interactive modal allowing users to rate 1-5 stars and submit review for completed orders (`status == "Hoàn thành"`), triggering reward celebration (`Confetti` + virtual balance update).

- [ ] **Step 1: Add `submitProductReview` to `api_client.dart` and `shoppe_provider.dart`**
- [ ] **Step 2: Create `mobile/lib/widgets/product_review_modal.dart` with smooth star rating animation**
- [ ] **Step 3: Add "Đánh Giá Nhận Quà (+50$ & +30 Dopamine)" button in `orders_screen.dart` for completed orders**

---

### Task 3: Daily Check-in Reward System (Backend & Frontend)

**Files:**
- Modify: `backend/app/models.py`
- Modify: `backend/app/schemas.py`
- Modify: `backend/app/routers/auth.py`
- Modify: `mobile/lib/models/user.dart`
- Modify: `mobile/lib/services/api_client.dart`
- Modify: `mobile/lib/providers/shoppe_provider.dart`
- Modify: `mobile/lib/screens/home_screen.dart`
- Create: `mobile/lib/widgets/daily_checkin_card.dart`

**Interfaces:**
- Consumes: `User` checkin streak data.
- Produces: `POST /auth/daily-checkin` endpoint and interactive 7-day progression card on `HomeScreen`.

- [ ] **Step 1: Add `last_checkin_date` and `checkin_streak` to backend `User` model and `POST /auth/daily-checkin` endpoint**
- [ ] **Step 2: Update mobile `User` model, `api_client.dart`, and `shoppe_provider.dart` with checkin method**
- [ ] **Step 3: Create `daily_checkin_card.dart` and integrate into `home_screen.dart` with celebratory reward animation**

---

### Task 4: Claimable Vouchers Wallet (Backend & Frontend)

**Files:**
- Modify: `backend/app/models.py`
- Modify: `backend/app/routers/vouchers.py`
- Modify: `mobile/lib/services/api_client.dart`
- Modify: `mobile/lib/providers/shoppe_provider.dart`
- Modify: `mobile/lib/screens/home_screen.dart`
- Modify: `mobile/lib/widgets/checkout_confirm_modal.dart`

**Interfaces:**
- Consumes: `Voucher` model.
- Produces: `POST /vouchers/claim/{code}` & `GET /vouchers/my-vouchers`, allowing users to claim vouchers on `HomeScreen` and pick them instantly inside `CheckoutConfirmModal`.

- [ ] **Step 1: Add `UserVoucher` relationship/table and voucher claim/list routes in backend**
- [ ] **Step 2: Add claim methods in `api_client.dart` and `shoppe_provider.dart`**
- [ ] **Step 3: Add "LƯU" / "ĐÃ LƯU" button on voucher strip in `home_screen.dart`**
- [ ] **Step 4: Update `checkout_confirm_modal.dart` to display and select from claimed vouchers**

---

### Task 5: Wishlist / Favorites & Heart Animation (Backend & Frontend)

**Files:**
- Modify: `backend/app/models.py`
- Modify: `backend/app/routers/products.py`
- Modify: `mobile/lib/models/product.dart`
- Modify: `mobile/lib/services/api_client.dart`
- Modify: `mobile/lib/providers/shoppe_provider.dart`
- Modify: `mobile/lib/widgets/product_card.dart`
- Modify: `mobile/lib/widgets/product_image_viewer.dart`
- Create: `mobile/lib/screens/favorites_screen.dart`

**Interfaces:**
- Consumes: `VirtualProduct` model.
- Produces: Toggle favorite endpoint (`POST /products/{id}/favorite`), heart button with spring pop animation on product cards, and dedicated Favorites screen.

- [ ] **Step 1: Add favorite toggle & get favorites endpoints in backend**
- [ ] **Step 2: Update mobile `VirtualProduct` model with `isFavorite` flag and add methods in `shoppe_provider.dart`**
- [ ] **Step 3: Add heart toggle button (`ScaleTransition` spring animation) on `product_card.dart` and `product_image_viewer.dart`**
- [ ] **Step 4: Create `favorites_screen.dart` and add navigation entry**
