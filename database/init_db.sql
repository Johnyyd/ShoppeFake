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
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
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
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END
GO

-- Seed baseline virtual products for high dopamine shopping
IF NOT EXISTS (SELECT * FROM Virtual_Products)
BEGIN
    INSERT INTO Virtual_Products (name, description, price_virtual, image_url, dopamine_rating, category)
    VALUES 
    ('Neon Cyber-Sneakers Mk.VII', 'Glowing holographic sneakers that boost virtual swagger.', 499.99, 'https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&w=600&q=80', 100, 'Footwear'),
    ('Golden Quantum Rolex', 'Transcends time itself. Pure status symbol.', 2499.00, 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=600&q=80', 500, 'Watches'),
    ('Prismatic Gaming Rig 9000', 'Liquid-cooled dual-4090 virtual setup with RGB aura.', 1899.50, 'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?auto=format&fit=crop&w=600&q=80', 350, 'Electronics'),
    ('Celestial Hoverboard', 'Anti-gravity street surfing board with starlight trail.', 899.00, 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80', 250, 'Vehicles'),
    ('Platinum VIP Crown', 'Permanent aura of prestige across all virtual chatrooms.', 3999.99, 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=600&q=80', 1000, 'Prestige');
END
GO
