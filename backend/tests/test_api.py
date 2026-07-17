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
    assert any("Sneakers" in p["name"] for p in products)

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
    assert "Insufficient virtual balance" in fail_res.json()["detail"]
