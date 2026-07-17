def test_health_check(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok", "dopamine_system": "online"}

def test_user_registration_and_login(client):
    # Register
    reg_response = client.post("/auth/register", json={
        "username": "dopamine_hunter",
        "password": "SecretPassword123!"
    })
    assert reg_response.status_code == 201
    reg_data = reg_response.json()
    assert reg_data["username"] == "dopamine_hunter"
    assert reg_data["virtual_balance"] == 5000.00
    assert reg_data["dopamine_level"] == 0

    # Login
    login_response = client.post("/auth/login", json={
        "username": "dopamine_hunter",
        "password": "SecretPassword123!"
    })
    assert login_response.status_code == 200
    login_data = login_response.json()
    assert "access_token" in login_data
    assert login_data["username"] == "dopamine_hunter"

def test_get_products_auto_seeds(client):
    response = client.get("/products")
    assert response.status_code == 200
    products = response.json()
    assert len(products) >= 5
    assert any("Sneaker" in p["name"] for p in products)

def test_virtual_checkout_success(client):
    # Register and login
    client.post("/auth/register", json={"username": "buyer1", "password": "pass12345"})
    login_res = client.post("/auth/login", json={"username": "buyer1", "password": "pass12345"})
    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Get first product
    products = client.get("/products").json()
    product_id = products[0]["id"]
    price = products[0]["price_virtual"]
    dopamine_rating = products[0]["dopamine_rating"]

    # Checkout
    checkout_res = client.post("/checkout", json={"product_id": product_id}, headers=headers)
    assert checkout_res.status_code == 200
    data = checkout_res.json()
    assert data["product_name"] == products[0]["name"]
    assert data["new_virtual_balance"] == 5000.00 - price
    assert data["dopamine_hits_awarded"] == dopamine_rating
    assert data["animation_trigger"] == "EXTREME_CONFETTI_BURST"
    assert "DOPAMINE SURGE" in data["message"]

def test_virtual_checkout_insufficient_balance(client):
    # Register user with 5000 balance
    client.post("/auth/register", json={"username": "spiffy", "password": "pass12345"})
    token = client.post("/auth/login", json={"username": "spiffy", "password": "pass12345"}).json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Buy multiple times to drain balance below Rolex price ($2499)
    products = client.get("/products").json()
    rolex = next(p for p in products if "Rolex" in p["name"])

    # Buy rolex twice (2499 * 2 = 4998 -> balance = 2.00)
    client.post("/checkout", json={"product_id": rolex["id"]}, headers=headers)
    client.post("/checkout", json={"product_id": rolex["id"]}, headers=headers)

    # Third buy should fail due to insufficient balance
    fail_res = client.post("/checkout", json={"product_id": rolex["id"]}, headers=headers)
    assert fail_res.status_code == 400
    assert "Số dư xu ảo không đủ" in fail_res.json()["detail"]

def test_submit_product_review(client):
    # Register user
    client.post("/auth/register", json={"username": "reviewer1", "password": "password123"})
    token = client.post("/auth/login", json={"username": "reviewer1", "password": "password123"}).json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    products = client.get("/products").json()
    product_id = products[0]["id"]

    # Submit review before ordering
    rev_res = client.post(
        f"/products/{product_id}/reviews",
        json={"rating": 5, "comment": "Sản phẩm tuyệt vời!"},
        headers=headers
    )
    assert rev_res.status_code == 200
    assert rev_res.json()["rating"] == 5
    assert rev_res.json()["username"] == "reviewer1"

    # Now checkout and update status to completed ("Hoàn thành") to test reward
    client.post("/checkout", json={"product_id": product_id}, headers=headers)
    orders = client.get("/orders", headers=headers).json()
    order_id = orders[0]["id"]
    client.put(f"/orders/{order_id}/status", json={"status": "Hoàn thành"}, headers=headers)

    # Submit another review when order is completed -> should award +50$ and +30 dopamine
    rev_reward_res = client.post(
        f"/products/{product_id}/reviews",
        json={"rating": 5, "comment": "Đã nhận hàng, tuyệt hảo!"},
        headers=headers
    )
    assert rev_reward_res.status_code == 200
    # Verify balance and dopamine increase
    user_me = client.get("/auth/me", headers=headers).json()
    # Initial balance (5000) - price + 50 reward
    assert user_me["dopamine_level"] >= 30

def test_daily_checkin(client):
    client.post("/auth/register", json={"username": "checkin_user", "password": "password123"})
    token = client.post("/auth/login", json={"username": "checkin_user", "password": "password123"}).json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Day 1 checkin
    res = client.post("/auth/daily-checkin", headers=headers)
    assert res.status_code == 200
    data = res.json()
    assert data["streak"] == 1
    assert data["reward_coins"] == 50.0
    assert data["reward_dopamine"] == 10
    assert data["virtual_balance"] == 5050.0
    assert data["dopamine_level"] == 10

    # Second checkin on same day -> should fail with 400
    res_duplicate = client.post("/auth/daily-checkin", headers=headers)
    assert res_duplicate.status_code == 400
    assert "Bạn đã điểm danh hôm nay rồi" in res_duplicate.json()["detail"]

def test_vouchers_claim_and_list(client):
    client.post("/auth/register", json={"username": "voucher_user", "password": "password123"})
    token = client.post("/auth/login", json={"username": "voucher_user", "password": "password123"}).json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 1. Get active vouchers (will auto-seed)
    active_res = client.get("/vouchers/active", headers=headers)
    assert active_res.status_code == 200
    vouchers = active_res.json()
    assert len(vouchers) >= 3
    voucher_id = vouchers[0]["id"]
    assert vouchers[0]["is_claimed"] == False

    # 2. Claim voucher
    claim_res = client.post(f"/vouchers/{voucher_id}/claim", headers=headers)
    assert claim_res.status_code == 200
    claim_data = claim_res.json()
    assert claim_data["voucher_id"] == voucher_id
    assert claim_data["is_used"] == False

    # 3. Check is_claimed in active list
    active_res_after = client.get("/vouchers/active", headers=headers)
    assert active_res_after.json()[0]["is_claimed"] == True

    # 4. Check my-vouchers list
    my_res = client.get("/vouchers/my-vouchers", headers=headers)
    assert my_res.status_code == 200
    my_vouchers = my_res.json()
    assert len(my_vouchers) == 1
    assert my_vouchers[0]["voucher"]["id"] == voucher_id

    # 5. Duplicate claim should fail
    dup_claim = client.post(f"/vouchers/{voucher_id}/claim", headers=headers)
    assert dup_claim.status_code == 400
