# 📦 ShoppeFake Mobile v1 - Release APK Scripts & Artifacts

Thư mục này chứa các kịch bản (scripts) tự động hóa để đóng gói ứng dụng di động **ShoppeFake** sang tệp **APK Release** chuẩn để cài đặt trên thiết bị Android.

---

## 🚀 Cách Sử Dụng Script Build APK

Bạn có thể chọn 1 trong 2 cách sau tùy theo môi trường dòng lệnh:

### Cách 1: Chạy trực tiếp bằng Windows Explorer (Đơn giản nhất)
Nhấp đúp chuột vào tệp:
👉 `build_apk.bat`

Hệ thống sẽ tự động gọi PowerShell, dọn dẹp cache, cập nhật thư viện và tiến hành build APK release.

---

### Cách 2: Chạy bằng PowerShell / Terminal
Mở terminal PowerShell tại thư mục này (`release\v1`) hoặc từ thư mục gốc, sau đó chạy lệnh:

```powershell
# Chạy script PowerShell
.\build_apk.ps1
```

---

## 📂 Quá Trình & Kết Quả Xuất File

Script thực hiện tuần tự 5 bước tự động:
1. **Kiểm tra SDK**: Kiểm tra phiên bản `flutter` trong môi trường `PATH`.
2. **Dọn dẹp (`flutter clean`)**: Xóa các tệp dựng tạm thời cũ để đảm bảo bản build hoàn toàn sạch.
3. **Tải thư viện (`flutter pub get`)**: Tải và đồng bộ các gói phụ thuộc (dependencies).
4. **Biên dịch APK (`flutter build apk --release`)**: Build gói APK tối ưu hóa hiệu năng và dung lượng.
5. **Sao chép sản phẩm ra `release/v1`**: Sau khi hoàn thành, script tự động chép tệp APK ra ngay tại thư mục này với 2 tên gọi:
   - `ShoppeFake-v1-release.apk` (Tên chính thức phiên bản v1)
   - `app-release.apk` (Tên gốc từ trình biên dịch Flutter)

---

## 🌐 Lưu ý về cấu hình máy chủ API
Ứng dụng di động khi build ra mặc định kết nối tới máy chủ Tailscale qua `baseUrl` được cấu hình tại `mobile/lib/services/api_client.dart` (`https://app.taild6d848.ts.net`).
Người dùng sau khi cài APK trên điện thoại cũng có thể tùy chỉnh địa chỉ máy chủ động ngay trong mục **Cài Đặt Server** ở màn hình **Tài khoản (`ProfileScreen`)**.
