-- init_db.sql
-- Database initialization for Gamified Virtual Shopping Application (Dopamine Booster)
-- Executed against Microsoft SQL Server

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'ShoppeDB')
BEGIN
    CREATE DATABASE ShoppeDB;
END
GO

USE ShoppeDB;
GO

-- Users Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        id INT IDENTITY(1,1) PRIMARY KEY,
        username NVARCHAR(100) UNIQUE NOT NULL,
        password_hash NVARCHAR(255) NOT NULL,
        virtual_balance DECIMAL(18, 2) NOT NULL DEFAULT 5000.00,
        dopamine_level INT NOT NULL DEFAULT 0,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END
GO

-- Sellers Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Sellers')
BEGIN
    CREATE TABLE Sellers (
        id INT IDENTITY(1,1) PRIMARY KEY,
        shop_name NVARCHAR(200) NOT NULL,
        description NVARCHAR(1000) NULL,
        logo_url NVARCHAR(500) NULL,
        rating DECIMAL(3, 2) NOT NULL DEFAULT 5.00,
        is_verified BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END
GO

-- Seed Baseline Sellers
IF NOT EXISTS (SELECT * FROM Sellers)
BEGIN
    INSERT INTO Sellers (shop_name, description, logo_url, rating, is_verified)
    VALUES 
    ('Quantum Prestige Co.', 'Nhà cung cấp vật phẩm siêu cấp độc quyền cho giới thượng lưu ảo.', 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=200&q=80', 5.00, 1),
    ('Cyber Pulse Studio', 'Gian hàng công nghệ tương lai, thiết bị AI và phụ kiện Cyberpunk.', 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=200&q=80', 4.95, 1),
    ('Aero Dynamics Ltd.', 'Chuyên phương tiện bay phản trọng lực và khí cụ thám hiểm.', 'https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=200&q=80', 4.88, 1);
END
GO

-- Vouchers Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Vouchers')
BEGIN
    CREATE TABLE Vouchers (
        id INT IDENTITY(1,1) PRIMARY KEY,
        code NVARCHAR(50) UNIQUE NOT NULL,
        discount_type NVARCHAR(20) NOT NULL DEFAULT 'PERCENT', -- 'PERCENT' or 'FIXED'
        discount_value DECIMAL(18, 2) NOT NULL,
        min_order_value DECIMAL(18, 2) NOT NULL DEFAULT 0,
        max_discount DECIMAL(18, 2) NULL,
        usage_limit INT NOT NULL DEFAULT 1000,
        used_count INT NOT NULL DEFAULT 0,
        is_active BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END
GO

-- Seed Baseline Vouchers
IF NOT EXISTS (SELECT * FROM Vouchers)
BEGIN
    INSERT INTO Vouchers (code, discount_type, discount_value, min_order_value, max_discount, usage_limit, is_active)
    VALUES 
    ('ORANGE500', 'FIXED', 500.00, 1000.00, NULL, 500, 1),
    ('WELCOME20', 'PERCENT', 20.00, 0.00, 1000.00, 1000, 1),
    ('CYBER10', 'PERCENT', 10.00, 500.00, 300.00, 2000, 1);
END
GO

-- Virtual Products Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Virtual_Products')
BEGIN
    CREATE TABLE Virtual_Products (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(200) NOT NULL,
        description NVARCHAR(1000) NULL,
        price_virtual DECIMAL(18, 2) NOT NULL,
        image_url NVARCHAR(500) NULL,
        dopamine_rating INT NOT NULL DEFAULT 10,
        category NVARCHAR(100) NOT NULL DEFAULT 'Luxury',
        seller_id INT NULL FOREIGN KEY REFERENCES Sellers(id),
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END
ELSE
BEGIN
    -- Add seller_id column if not exists for existing database migrations
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Virtual_Products') AND name = 'seller_id')
    BEGIN
        ALTER TABLE Virtual_Products ADD seller_id INT NULL FOREIGN KEY REFERENCES Sellers(id);
    END
END
GO

-- Virtual Orders Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Virtual_Orders')
BEGIN
    CREATE TABLE Virtual_Orders (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL FOREIGN KEY REFERENCES Users(id),
        product_id INT NOT NULL FOREIGN KEY REFERENCES Virtual_Products(id),
        virtual_price_paid DECIMAL(18, 2) NOT NULL,
        dopamine_hits_awarded INT NOT NULL,
        voucher_code NVARCHAR(50) NULL,
        discount_amount DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END
ELSE
BEGIN
    -- Add voucher_code and discount_amount columns if not exists
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Virtual_Orders') AND name = 'voucher_code')
    BEGIN
        ALTER TABLE Virtual_Orders ADD voucher_code NVARCHAR(50) NULL;
    END
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Virtual_Orders') AND name = 'discount_amount')
    BEGIN
        ALTER TABLE Virtual_Orders ADD discount_amount DECIMAL(18, 2) NOT NULL DEFAULT 0.00;
    END
END
GO

-- Seed baseline virtual products for high dopamine shopping (with seller assignment)
IF NOT EXISTS (SELECT * FROM Virtual_Products)
BEGIN
    INSERT INTO Virtual_Products (name, description, price_virtual, image_url, dopamine_rating, category, seller_id)
    VALUES 
    ('Neon Cyber-Sneakers Mk.VII', 'Glowing holographic sneakers that boost virtual swagger.', 499.99, 'https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&w=600&q=80', 100, 'Footwear', 2),
    ('Golden Quantum Rolex', 'Transcends time itself. Pure status symbol.', 2499.00, 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=600&q=80', 500, 'Watches', 1),
    ('Prismatic Gaming Rig 9000', 'Liquid-cooled dual-4090 virtual setup with RGB aura.', 1899.50, 'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?auto=format&fit=crop&w=600&q=80', 350, 'Electronics', 2),
    ('Celestial Hoverboard', 'Anti-gravity street surfing board with starlight trail.', 899.00, 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80', 250, 'Vehicles', 3),
    ('Platinum VIP Crown', 'Permanent aura of prestige across all virtual chatrooms.', 3999.99, 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=600&q=80', 1000, 'Prestige', 1);
END
ELSE
BEGIN
    -- Update existing seed products to have seller_id if null
    UPDATE Virtual_Products SET seller_id = 1 WHERE seller_id IS NULL AND category IN ('Watches', 'Prestige');
    UPDATE Virtual_Products SET seller_id = 2 WHERE seller_id IS NULL AND category IN ('Footwear', 'Electronics');
    UPDATE Virtual_Products SET seller_id = 3 WHERE seller_id IS NULL AND category IN ('Vehicles');
END
GO
