import os
import sys
from sqlalchemy.orm import Session

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.database import SessionLocal, engine
from app.models import VirtualProduct, Seller, Category, ProductImage, ProductReview, User, VirtualOrder, CartItem, UserFavorite
from app.routers.categories import seed_categories
from app.routers.sellers import get_sellers

REAL_SHOPEE_CATALOG = [
    # ========================== 1. ĐIỆN TỬ & CÔNG NGHỆ ==========================
    {
        "name": "Apple iPhone 16 Pro Max 256GB - Chính hãng VN/A",
        "desc": "Thiết kế Titan sa mạc đẳng cấp, chip A18 Pro mạnh nhất thế giới, camera 48MP Control Button mới tinh xảo. Bảo hành chính hãng 12 tháng tại Apple Vietnam.",
        "price": 34490000.0, "orig_price": 37990000.0, "discount": 9, "cat_name": "Điện tử & Công nghệ", "seller_name": "Apple Flagship Store", "sold": 4520, "rating": 5.0,
        "img": "https://images.unsplash.com/photo-1695048133142-1a20484d2569?auto=format&fit=crop&w=600&q=80",
        "gallery": [
            "https://images.unsplash.com/photo-1695048133142-1a20484d2569?auto=format&fit=crop&w=800&q=80",
            "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?auto=format&fit=crop&w=800&q=80"
        ]
    },
    {
        "name": "Samsung Galaxy S24 Ultra 512GB - Galaxy AI Pro",
        "desc": "Quyền năng Galaxy AI đỉnh cao, khung viền Titan siêu bền bỉ, bút S-Pen tích hợp, camera mắt thần bóng đêm 200MP siêu zoom 100x.",
        "price": 29990000.0, "orig_price": 36990000.0, "discount": 19, "cat_name": "Điện tử & Công nghệ", "seller_name": "Samsung Official Store", "sold": 3180, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Tai Nghe Bluetooth Apple AirPods Pro 2 USB-C (MagSafe)",
        "desc": "Chống ồn chủ động ANC gấp 2 lần, chế độ Xuyên Âm thông minh, âm thanh không gian cá nhân hóa với theo dõi chuyển động đầu.",
        "price": 5890000.0, "orig_price": 6990000.0, "discount": 16, "cat_name": "Điện tử & Công nghệ", "seller_name": "Apple Flagship Store", "sold": 12800, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?auto=format&fit=crop&w=600&q=80",
        "gallery": [
            "https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?auto=format&fit=crop&w=800&q=80",
            "https://images.unsplash.com/photo-1588423771073-b8903fbb85b5?auto=format&fit=crop&w=800&q=80"
        ]
    },
    {
        "name": "Tai Nghe Chống Ồn Sony WH-1000XM5 Hi-Res Audio",
        "desc": "Đỉnh cao chống ồn với bộ xử lý HD QN1, thời lượng pin cực khủng 30 giờ, gọi rảnh tay siêu rõ nét với công nghệ đàm thoại AI.",
        "price": 7990000.0, "orig_price": 9490000.0, "discount": 16, "cat_name": "Điện tử & Công nghệ", "seller_name": "Baseus Vietnam Official", "sold": 2150, "rating": 4.8,
        "img": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Chuột Không Dây Logitech MX Master 3S - Quiet Click",
        "desc": "Cảm biến 8000 DPI di chuyển trên mọi bề mặt kể cả kính, phím click êm ái giảm 90% tiếng ồn, cuộn siêu tốc MagSpeed 1000 dòng/giây.",
        "price": 2350000.0, "orig_price": 2850000.0, "discount": 18, "cat_name": "Điện tử & Công nghệ", "seller_name": "Baseus Vietnam Official", "sold": 6400, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Bàn Phím Cơ Không Dây NuPhy Air75 V2 Low-Profile",
        "desc": "Bàn phím cơ mỏng nhẹ nhất thế giới, switch Gateron Low-profile gõ cực êm, kết nối không dây 2.4Ghz/Bluetooth 5.0 cùng lúc 3 thiết bị.",
        "price": 2750000.0, "orig_price": 3200000.0, "discount": 14, "cat_name": "Điện tử & Công nghệ", "seller_name": "Baseus Vietnam Official", "sold": 1890, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Sạc Dự Phòng Anker Prime 20.000mAh 200W Siêu Nhanh",
        "desc": "Công suất siêu khủng 200W sạc nhanh cùng lúc 2 laptop và điện thoại, màn hình thông minh hiển thị chính xác công suất từng cổng.",
        "price": 2150000.0, "orig_price": 2690000.0, "discount": 20, "cat_name": "Điện tử & Công nghệ", "seller_name": "Baseus Vietnam Official", "sold": 4500, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1609592424089-67d4128f654f?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1609592424089-67d4128f654f?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Củ Sạc GaN Siêu Nhỏ Baseus 65W 2xUSB-C + USB-A",
        "desc": "Công nghệ GaN6 mới nhất giúp củ sạc nhỏ gọn hơn 50%, hỗ trợ chuẩn sạc nhanh PD 3.0 / PPS cho MacBook, iPhone 16 và Samsung S24.",
        "price": 450000.0, "orig_price": 650000.0, "discount": 31, "cat_name": "Điện tử & Công nghệ", "seller_name": "Baseus Vietnam Official", "sold": 18900, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1583863788434-e58a36330cf0?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1583863788434-e58a36330cf0?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Apple iPad Pro 13 inch M4 (2024) 256GB Wi-Fi - VN/A",
        "desc": "Thiết kế siêu mỏng kỉ lục chỉ 5.1mm, màn hình Ultra Retina XDR OLED kép đỉnh cao, chip M4 hiệu năng vượt trội mọi laptop PC.",
        "price": 37990000.0, "orig_price": 39990000.0, "discount": 5, "cat_name": "Điện tử & Công nghệ", "seller_name": "Apple Flagship Store", "sold": 1420, "rating": 5.0,
        "img": "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "MacBook Air 13 inch M3 16GB/512GB - Chính hãng Apple VN",
        "desc": "Thiết kế vỏ nhôm tái chế cực mỏng nhẹ, pin sử dụng thực tế lên đến 18 giờ, RAM 16GB đa nhiệm mượt mà tác vụ lập trình và đồ họa.",
        "price": 31500000.0, "orig_price": 34990000.0, "discount": 10, "cat_name": "Điện tử & Công nghệ", "seller_name": "Apple Flagship Store", "sold": 2890, "rating": 5.0,
        "img": "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Loa Bluetooth Marshall Emberton II Chính Hãng ASH",
        "desc": "Âm thanh 360 độ True Stereophonic đặc trưng Marshall, chuẩn kháng nước bụi IP67, pin trâu 30 giờ liên tục cho mọi chuyến đi.",
        "price": 3990000.0, "orig_price": 4690000.0, "discount": 15, "cat_name": "Điện tử & Công nghệ", "seller_name": "Baseus Vietnam Official", "sold": 3450, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1545454675-3531b543be5d?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1545454675-3531b543be5d?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Màn Hình Cong Gaming Samsung Odyssey G5 34 inch WQHD 165Hz",
        "desc": "Độ cong 1000R ôm trọn tầm mắt, tần số quét 165Hz siêu mượt mà, thời gian phản hồi 1ms cùng công nghệ AMD FreeSync Premium.",
        "price": 8990000.0, "orig_price": 11500000.0, "discount": 22, "cat_name": "Điện tử & Công nghệ", "seller_name": "Samsung Official Store", "sold": 980, "rating": 4.8,
        "img": "https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?auto=format&fit=crop&w=800&q=80"]
    },

    # ========================== 2. THỜI TRANG & PHỤ KIỆN ==========================
    {
        "name": "Áo Thun Cotton Compact Form Boxy Coolmate Clean Dzign",
        "desc": "Chất liệu 100% Cotton Compact siêu mềm mịn, định lượng 230gsm đứng form không nhão, công nghệ xử lý chống xù lông và phai màu sau 50 lần giặt.",
        "price": 189000.0, "orig_price": 249000.0, "discount": 24, "cat_name": "Thời trang & Phụ kiện", "seller_name": "Coolmate Official Store", "sold": 45000, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Quần Short chạy bộ nam Coolmate Fast & Free co giãn 4 chiều",
        "desc": "Vải siêu nhẹ nhanh khô với công nghệ Ex-Dry, tích hợp túi khóa kéo phía sau đựng điện thoại tiện lợi, dải phản quang an toàn ban đêm.",
        "price": 229000.0, "orig_price": 299000.0, "discount": 23, "cat_name": "Thời trang & Phụ kiện", "seller_name": "Coolmate Official Store", "sold": 28400, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1591195853828-11db59a44f6b?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1591195853828-11db59a44f6b?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Áo Khoác Gió Nam Coolmate Daily Windbreaker Chống Nước UV",
        "desc": "Áo khoác 2 lớp siêu nhẹ chống gió và mưa nhỏ tuyệt đối, chống nắng UPF 50+, gấp gọn vào túi áo tiện lợi mang theo mọi lúc.",
        "price": 389000.0, "orig_price": 499000.0, "discount": 22, "cat_name": "Thời trang & Phụ kiện", "seller_name": "Coolmate Official Store", "sold": 16500, "rating": 4.8,
        "img": "https://images.unsplash.com/photo-1551028719-00167b16eac5?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1551028719-00167b16eac5?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Giày Thể Thao Nike Air Force 1 '07 All White Chính Hãng",
        "desc": "Biểu tượng kinh điển của thời trang streetwear thế giới, chất liệu da thật cao cấp, bộ đệm Nike Air êm ái cho mọi bước chân.",
        "price": 2929000.0, "orig_price": 3239000.0, "discount": 10, "cat_name": "Thời trang & Phụ kiện", "seller_name": "Shopee Mall Official", "sold": 8900, "rating": 5.0,
        "img": "https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Giày Chạy Bộ Adidas Ultraboost Light 23 Siêu Nhẹ",
        "desc": "Công nghệ hạt Light BOOST nhẹ hơn 30% so với thế hệ trước, hoàn trả năng lượng tối đa, thân giày Primeknit ôm chân như vớ.",
        "price": 3450000.0, "orig_price": 5200000.0, "discount": 34, "cat_name": "Thời trang & Phụ kiện", "seller_name": "Shopee Mall Official", "sold": 4120, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Balo Laptop Chống Nước Mark Ryden Business Travel 15.6 inch",
        "desc": "Thiết kế đa ngăn thông minh có cổng sạc USB tích hợp, vải Oxford chống nước bám bẩn cực tốt, đệm lưng thoáng khí giảm tải trọng.",
        "price": 590000.0, "orig_price": 890000.0, "discount": 34, "cat_name": "Thời trang & Phụ kiện", "seller_name": "Shopee Mall Official", "sold": 11200, "rating": 4.8,
        "img": "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Kính Mát Thời Trang Ray-Ban Aviator Classic Chống UV400",
        "desc": "Gọng kim loại mạ vàng sang trọng siêu nhẹ, tròng kính thủy tinh cường lực chống chói Polarized và tia UV 100% chuẩn Ý.",
        "price": 3650000.0, "orig_price": 4200000.0, "discount": 13, "cat_name": "Thời trang & Phụ kiện", "seller_name": "Shopee Mall Official", "sold": 1950, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1572635196237-14b3f281503f?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1572635196237-14b3f281503f?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Combo 5 Đôi Vớ Khử Mùi Coolmate Active Antibacterial",
        "desc": "Chất liệu Cotton kết hợp sợi bạc kháng khuẩn khử mùi hôi chân hiệu quả đến 99%, đệm xù êm ái gót chân khi chơi thể thao.",
        "price": 149000.0, "orig_price": 199000.0, "discount": 25, "cat_name": "Thời trang & Phụ kiện", "seller_name": "Coolmate Official Store", "sold": 68000, "rating": 5.0,
        "img": "https://images.unsplash.com/photo-1586350977771-b3b0abd50c82?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1586350977771-b3b0abd50c82?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Thắt Lưng Da Bò Thật Khóa Tự Động Cao Cấp Pedro",
        "desc": "Da bò nguyên tấm 100% càng dùng càng bóng đẹp, mặt khóa hợp kim chống xước tinh tế, phù hợp quần tây và quần kaki công sở.",
        "price": 790000.0, "orig_price": 1100000.0, "discount": 28, "cat_name": "Thời trang & Phụ kiện", "seller_name": "Shopee Mall Official", "sold": 4300, "rating": 4.8,
        "img": "https://images.unsplash.com/photo-1624222247344-550fb60583dc?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1624222247344-550fb60583dc?auto=format&fit=crop&w=800&q=80"]
    },

    # ========================== 3. ĐỒNG HỒ & TRANG SỨC VIP (Mỹ phẩm & Sức khỏe & VIP) ==========================
    {
        "name": "Serum L'Oreal Paris Revitalift Hyaluronic Acid 1.5% Cấp Ẩm",
        "desc": "Công thức 1.5% Hyaluronic Acid tinh khiết với hai kích thước phân tử giúp cấp ẩm sâu tức thì, da căng mọng rạng rỡ giảm nếp nhăn sau 7 ngày.",
        "price": 379000.0, "orig_price": 529000.0, "discount": 28, "cat_name": "Đồng hồ & Trang sức VIP", "seller_name": "L'Oreal Paris Official Store", "sold": 52000, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Kem Chống Nắng L'Oreal Paris UV Defender Serum Protector 50ml",
        "desc": "Chỉ số SPF 50+ PA++++ bảo vệ da tối đa trước tia UVA/UVB và bụi mịn thành phố, kiềm dầu suốt 8 giờ không gây bít tắc lỗ chân lông.",
        "price": 249000.0, "orig_price": 349000.0, "discount": 29, "cat_name": "Đồng hồ & Trang sức VIP", "seller_name": "L'Oreal Paris Official Store", "sold": 78000, "rating": 5.0,
        "img": "https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Nước Tẩy Trang L'Oreal Paris Micellar Water 3-in-1 Deep Clean 400ml",
        "desc": "Công nghệ Micellar kết hợp lớp dầu hữu cơ hút sạch lớp trang điểm lâu trôi và bụi mịn PM2.5, không cồn không gây rát da.",
        "price": 169000.0, "orig_price": 239000.0, "discount": 29, "cat_name": "Đồng hồ & Trang sức VIP", "seller_name": "L'Oreal Paris Official Store", "sold": 115000, "rating": 5.0,
        "img": "https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Nước Hoa Nam Bleu de Chanel Eau de Parfum 100ml Chính Hãng",
        "desc": "Hương thơm nam tính tự do và lịch lãm từ gỗ Đàn Hương New Caledonia kết hợp hương cam chanh sảng khoái, lưu hương trên 12 giờ.",
        "price": 3850000.0, "orig_price": 4250000.0, "discount": 9, "cat_name": "Đồng hồ & Trang sức VIP", "seller_name": "Shopee Mall Official", "sold": 3400, "rating": 5.0,
        "img": "https://images.unsplash.com/photo-1523293182086-7651a899d37f?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1523293182086-7651a899d37f?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Sữa Rửa Mặt CeraVe Foaming Cleanser Cho Da Dầu Nhạy Cảm 473ml",
        "desc": "Chứa 3 Ceramides thiết yếu, Niacinamide và Hyaluronic Acid giúp làm sạch sâu bã nhờn mà vẫn giữ nguyên hàng rào độ ẩm tự nhiên của da.",
        "price": 389000.0, "orig_price": 460000.0, "discount": 15, "cat_name": "Đồng hồ & Trang sức VIP", "seller_name": "L'Oreal Paris Official Store", "sold": 64000, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Son Thỏi MAC Matte Lipstick Chili Đỏ Gạch Siêu Lì",
        "desc": "Màu son đỏ gạch huyền thoại không kén tông da, chất son lì mịn màng mượt môi, giữ màu chuẩn đẹp liên tục đến 8 giờ.",
        "price": 580000.0, "orig_price": 680000.0, "discount": 15, "cat_name": "Đồng hồ & Trang sức VIP", "seller_name": "Shopee Mall Official", "sold": 18200, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1586495777744-4413f21062fa?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1586495777744-4413f21062fa?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Đồng Hồ Nam Casio G-Shock GA-2100-1A1DR (CasiOak All Black)",
        "desc": "Cấu trúc bảo vệ lõi carbon siêu bền bỉ chống va đập, chống nước độ sâu 200m, thiết kế mặt bát giác mỏng gọn sang trọng.",
        "price": 2650000.0, "orig_price": 3490000.0, "discount": 24, "cat_name": "Đồng hồ & Trang sức VIP", "seller_name": "Shopee Mall Official", "sold": 8900, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1524805444758-089113d48a6d?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1524805444758-089113d48a6d?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Đồng Hồ Thông Minh Apple Watch Series 10 GPS 42mm - VN/A",
        "desc": "Màn hình OLED góc rộng lớn nhất từ trước đến nay, sạc nhanh 80% chỉ trong 30 phút, theo dõi ngưng thở khi ngủ và điện tâm đồ ECG.",
        "price": 10890000.0, "orig_price": 11990000.0, "discount": 9, "cat_name": "Đồng hồ & Trang sức VIP", "seller_name": "Apple Flagship Store", "sold": 3100, "rating": 5.0,
        "img": "https://images.unsplash.com/photo-1546868871-7041f2a55e12?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1546868871-7041f2a55e12?auto=format&fit=crop&w=800&q=80"]
    },

    # ========================== 4. XE HƠI & PHƯƠNG TIỆN ẢO (Gia dụng & Đời sống & Nhà cửa) ==========================
    {
        "name": "Nồi Chiên Không Dầu Philips HD9252/90 4.1L - Hàng Chính Hãng",
        "desc": "Công nghệ Rapid Air độc quyền giảm 90% lượng chất béo, màn hình cảm ứng 7 chương trình nấu cài đặt sẵn tiện lợi cho gia đình.",
        "price": 1850000.0, "orig_price": 2990000.0, "discount": 38, "cat_name": "Xe hơi & Phương tiện ảo", "seller_name": "Shopee Mall Official", "sold": 19400, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1585515320310-259814833e62?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1585515320310-259814833e62?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Robot Hút Bụi Lau Nhà Roborock Q Revo MaxV - Giặt giẻ nước nóng",
        "desc": "Lực hút cực mạnh 7000Pa, tự động giặt giẻ lau bằng nước nóng 60 độ C và sấy khô bằng khí nóng, camera AI nhận diện vật cản.",
        "price": 16990000.0, "orig_price": 22990000.0, "discount": 26, "cat_name": "Xe hơi & Phương tiện ảo", "seller_name": "Shopee Mall Official", "sold": 1850, "rating": 5.0,
        "img": "https://images.unsplash.com/photo-1518609878373-06d740f60d8b?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1518609878373-06d740f60d8b?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Nước Giặt OMO Matic Khử Mùi Comfort Túi Lớn 3.6Kg",
        "desc": "Công nghệ màn chắn kháng bẩn Polyshield đánh bay vết bẩn cứng đầu trong lồng giặt, hương hoa thơm ngát bền lâu cả ngày dài.",
        "price": 189000.0, "orig_price": 245000.0, "discount": 23, "cat_name": "Xe hơi & Phương tiện ảo", "seller_name": "Shopee Mall Official", "sold": 142000, "rating": 5.0,
        "img": "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Bàn Chải Điện Oral-B Pro 3 3000 Chăm Sóc Nướu Chuyên Sâu",
        "desc": "Công nghệ 3D làm sạch mảng bám hơn 100% so với bàn chải thường, cảm biến lực gõ tự động giảm tốc khi chải quá mạnh.",
        "price": 1150000.0, "orig_price": 1650000.0, "discount": 30, "cat_name": "Xe hơi & Phương tiện ảo", "seller_name": "Shopee Mall Official", "sold": 8400, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1559591937-abc1441a1a5b?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1559591937-abc1441a1a5b?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "máy Lọc Không Khí Xiaomi Smart Air Purifier 4 Compact",
        "desc": "Bộ lọc 3 trong 1 loại bỏ 99.97% bụi mịn PM0.3, phấn hoa và lông thú cưng, điều khiển thông minh qua app Mi Home siêu êm ái.",
        "price": 1790000.0, "orig_price": 2590000.0, "discount": 31, "cat_name": "Xe hơi & Phương tiện ảo", "seller_name": "Baseus Vietnam Official", "sold": 12600, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1585771724684-38269d6639fd?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1585771724684-38269d6639fd?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Bộ Nồi Inox 3 Đáy Cao Cấp Sunhouse SHG304 Đáy Từ",
        "desc": "Chất liệu inox cao cấp không han gỉ, truyền nhiệt nhanh tỏa nhiệt đều giúp nấu chín thức ăn giữ trọn dinh dưỡng, dùng tốt trên bếp từ.",
        "price": 550000.0, "orig_price": 890000.0, "discount": 38, "cat_name": "Xe hơi & Phương tiện ảo", "seller_name": "Shopee Mall Official", "sold": 15800, "rating": 4.8,
        "img": "https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Bình Giữ Nhiệt Lock&Lock Feather Light Ring 500ml LHC4131",
        "desc": "Trọng lượng cực nhẹ chỉ 230g tiện mang đi học đi làm, khả năng giữ nóng lên đến 8 giờ và giữ lạnh đá trên 12 giờ tuyệt đối không đọng nước.",
        "price": 239000.0, "orig_price": 450000.0, "discount": 47, "cat_name": "Xe hơi & Phương tiện ảo", "seller_name": "Shopee Mall Official", "sold": 38900, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Ghế Công Thái Học Ergonomic Sihoo M57 Lưới Toàn Phần",
        "desc": "Tựa lưng đàn hồi hỗ trợ cột sống thắt lưng chuẩn y khoa, tay vịn 3D linh hoạt, lưới cao cấp siêu thoáng khí không gây nóng lưng khi ngồi lâu.",
        "price": 3490000.0, "orig_price": 4500000.0, "discount": 22, "cat_name": "Xe hơi & Phương tiện ảo", "seller_name": "Shopee Mall Official", "sold": 6200, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1580481077494-e3299ac2fef6?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1580481077494-e3299ac2fef6?auto=format&fit=crop&w=800&q=80"]
    },

    # ========================== 5. VẬT PHẨM ĐẶC QUYỀN (Sách & Tri thức & Đặc quyền) ==========================
    {
        "name": "Sách - Tâm Lý Học Tội Phạm (Bộ 2 Tập) - Khám Phá Góc Khuất",
        "desc": "Phân tích tâm lý sâu sắc và khoa học đằng sau những hành vi hồ sơ tội phạm chấn động, sách bìa cứng giấy cao cấp không mỏi mắt.",
        "price": 198000.0, "orig_price": 280000.0, "discount": 29, "cat_name": "Vật phẩm Đặc quyền", "seller_name": "Shopee Mall Official", "sold": 34200, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Sách - Nhà Giả Kim (Paulo Coelho) - Bìa Cứng Đặc Biệt",
        "desc": "Cuốn sách bán chạy thứ hai mọi thời đại sau Kinh Thánh, hành trình theo đuổi ước mơ và lắng nghe tiếng nói trái tim đầy cảm hứng.",
        "price": 68000.0, "orig_price": 89000.0, "discount": 24, "cat_name": "Vật phẩm Đặc quyền", "seller_name": "Shopee Mall Official", "sold": 185000, "rating": 5.0,
        "img": "https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Sách - Atomic Habits (Thói Quen Nguyên Tử) - James Clear",
        "desc": "Phương pháp khoa học đã được chứng minh giúp thay đổi hành vi nhỏ tạo ra kết quả phi thường trong công việc và cuộc sống hàng ngày.",
        "price": 145000.0, "orig_price": 189000.0, "discount": 23, "cat_name": "Vật phẩm Đặc quyền", "seller_name": "Shopee Mall Official", "sold": 67000, "rating": 5.0,
        "img": "https://images.unsplash.com/photo-1589829085413-56de8ae18c73?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1589829085413-56de8ae18c73?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Gói Bảo Hành Rơi Vỡ & Ngấm Nước Toàn Diện AppleCare+ (2 Năm)",
        "desc": "Bảo hành tuyệt đối cho iPhone/iPad trong 2 năm, thay pin miễn phí khi dưới 80%, hỗ trợ kỹ thuật trực tiếp từ chuyên gia Apple.",
        "price": 4590000.0, "orig_price": 5490000.0, "discount": 16, "cat_name": "Vật phẩm Đặc quyền", "seller_name": "Apple Flagship Store", "sold": 5420, "rating": 5.0,
        "img": "https://images.unsplash.com/photo-1563013792-51c7eb8066f8?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1563013792-51c7eb8066f8?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Đèn Bàn Học Bảo Vệ Mắt Xiaomi Mijia Desk Lamp 1S Smart LED",
        "desc": "Ánh sáng tự nhiên Ra95 không nhấp nháy chống cận thị, 4 chế độ sáng chuyên sâu cho đọc sách/lập trình, tương thích Apple HomeKit.",
        "price": 790000.0, "orig_price": 1100000.0, "discount": 28, "cat_name": "Vật phẩm Đặc quyền", "seller_name": "Baseus Vietnam Official", "sold": 14200, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1534073828943-f801091bb18c?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1534073828943-f801091bb18c?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Máy Đọc Sách Kindle Paperwhite 5 (11th Gen) 16GB Màn 6.8 inch",
        "desc": "Màn hình E-Ink 300ppi sắc nét không chói dưới nắng rực rỡ, hệ thống đèn nền ấm chống mỏi mắt ban đêm, pin 10 tuần kháng nước IPX8.",
        "price": 3690000.0, "orig_price": 4200000.0, "discount": 12, "cat_name": "Vật phẩm Đặc quyền", "seller_name": "Shopee Mall Official", "sold": 6100, "rating": 4.9,
        "img": "https://images.unsplash.com/photo-1592496431122-2349e0fbc666?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1592496431122-2349e0fbc666?auto=format&fit=crop&w=800&q=80"]
    },

    # ========================== 6. KHO VOUCHER & THẺ QUÀ ==========================
    {
        "name": "Thẻ Quà Tặng Shopee Mall E-Voucher Trị Giá 1.000.000đ",
        "desc": "Áp dụng thanh toán cho tất cả gian hàng chính hãng Shopee Mall toàn quốc, không giới hạn thời gian sử dụng, có thể tặng bạn bè.",
        "price": 950000.0, "orig_price": 1000000.0, "discount": 5, "cat_name": "Kho Voucher & Thẻ quà", "seller_name": "Shopee Mall Official", "sold": 18400, "rating": 5.0,
        "img": "https://images.unsplash.com/photo-1513885535751-8b9238bd345a?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1513885535751-8b9238bd345a?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Thẻ Quà Tặng Apple Store Gift Card Trị Giá 2.000.000đ",
        "desc": "Sử dụng mua sắm thiết bị phần cứng, phụ kiện, dung lượng iCloud hoặc ứng dụng trên App Store chính hãng Apple tại Việt Nam.",
        "price": 1950000.0, "orig_price": 2000000.0, "discount": 3, "cat_name": "Kho Voucher & Thẻ quà", "seller_name": "Apple Flagship Store", "sold": 12500, "rating": 5.0,
        "img": "https://images.unsplash.com/photo-1549465220-1a8b9238cd48?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1549465220-1a8b9238cd48?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Thẻ Quà Tặng Starbucks E-Gift Card Trị Giá 500.000đ",
        "desc": "Thưởng thức cà phê và đồ uống cao cấp tại hơn 100 cửa hàng Starbucks trên toàn quốc, quét mã QR thanh toán tức thì nhanh chóng.",
        "price": 475000.0, "orig_price": 500000.0, "discount": 5, "cat_name": "Kho Voucher & Thẻ quà", "seller_name": "Shopee Mall Official", "sold": 25000, "rating": 5.0,
        "img": "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80"]
    },
    {
        "name": "Voucher GrabFood / GrabBike E-Voucher Trị Giá 200.000đ",
        "desc": "Áp dụng cho mọi dịch vụ giao đồ ăn GrabFood, di chuyển GrabBike và GrabCar tại tất cả các tỉnh thành Việt Nam, tích lũy điểm GrabRewards.",
        "price": 185000.0, "orig_price": 200000.0, "discount": 8, "cat_name": "Kho Voucher & Thẻ quà", "seller_name": "Shopee Mall Official", "sold": 45000, "rating": 5.0,
        "img": "https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?auto=format&fit=crop&w=600&q=80",
        "gallery": ["https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?auto=format&fit=crop&w=800&q=80"]
    },
]

def enrich_database():
    db: Session = SessionLocal()
    try:
        print("Connected to DB engine:", engine.url)
        seed_categories(db)
        get_sellers(db)

        cat_map = {c.name: c.id for c in db.query(Category).all()}
        seller_map = {s.shop_name: s.id for s in db.query(Seller).all()}
        default_seller_id = list(seller_map.values())[0] if seller_map else 1

        print(f"Total categories: {len(cat_map)}, Total sellers: {len(seller_map)}")

        # Upsert products cleanly
        added = 0
        updated = 0
        for item in REAL_SHOPEE_CATALOG:
            cat_id = cat_map.get(item["cat_name"])
            seller_id = seller_map.get(item["seller_name"], default_seller_id)

            p = db.query(VirtualProduct).filter(VirtualProduct.name == item["name"]).first()
            if not p:
                p = VirtualProduct(
                    name=item["name"],
                    description=item["desc"],
                    price_virtual=item["price"],
                    original_price=item["orig_price"],
                    discount_percentage=item["discount"],
                    image_url=item["img"],
                    dopamine_rating=100,
                    category_name=item["cat_name"],
                    category_id=cat_id,
                    seller_id=seller_id,
                    sold_count=item["sold"],
                    average_rating=item["rating"]
                )
                db.add(p)
                db.commit()
                db.refresh(p)
                added += 1

                for g_url in item.get("gallery", []):
                    db.add(ProductImage(product_id=p.id, image_url=g_url))
                db.commit()
            else:
                p.description = item["desc"]
                p.price_virtual = item["price"]
                p.original_price = item["orig_price"]
                p.discount_percentage = item["discount"]
                p.image_url = item["img"]
                p.category_name = item["cat_name"]
                if cat_id:
                    p.category_id = cat_id
                if seller_id:
                    p.seller_id = seller_id
                p.sold_count = item["sold"]
                p.average_rating = item["rating"]
                db.commit()
                updated += 1

        total_now = db.query(VirtualProduct).count()
        print(f"[SUCCESS] Catalog enrichment completed! Added: {added}, Updated: {updated}. Total products in DB: {total_now}")

    finally:
        db.close()

if __name__ == "__main__":
    enrich_database()
