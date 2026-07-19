import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/shoppe_provider.dart';
import '../theme/app_theme.dart';

import 'favorites_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShoppeProvider>(context);
    final user = provider.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF13131A) : const Color(0xFFFAFAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryOrange, Color(0xFFFF3D00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(Icons.person, color: AppTheme.primaryOrange, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.username ?? 'Thành Viên ShoppeFake',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.bolt, color: Colors.amber, size: 14),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${user?.dopamineLevel ?? 0} HITS',
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '🪙 ${user?.virtualBalance.toStringAsFixed(0) ?? 0} xu',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'TIỆN ÍCH SĂN DOPAMINE',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Quick Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                childAspectRatio: 0.85,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildQuickAction(Icons.confirmation_number, 'Trạm Voucher', Colors.orange, isDark),
                  _buildQuickAction(Icons.storefront, 'Gian hàng Mall', Colors.blue, isDark),
                  _buildQuickAction(Icons.local_fire_department, 'Săn Dopamine', Colors.red, isDark),
                  _buildQuickAction(
                    Icons.favorite,
                    'Đã thích',
                    Colors.pink,
                    isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text(
                'CÀI ĐẶT HỆ THỐNG',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              _buildSettingsTile(
                icon: Icons.brightness_6,
                title: 'Giao diện ứng dụng',
                subtitle: 'Đang theo thiết lập hệ thống chuẩn Apple Design',
                isDark: isDark,
                onTap: () {
                  HapticFeedback.selectionClick();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chế độ Theme tự động đồng bộ theo cấu trúc bảng màu AppTheme'),
                      backgroundColor: AppTheme.primaryOrange,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildSettingsTile(
                icon: Icons.dns_outlined,
                title: 'Địa chỉ Máy chủ (Tailscale/API URL)',
                subtitle: provider.tailscaleUrl,
                isDark: isDark,
                onTap: () => _showUrlEditDialog(context, provider),
              ),
              const SizedBox(height: 10),
              _buildSettingsTile(
                icon: Icons.security,
                title: 'Bảo mật & Quyền riêng tư',
                subtitle: 'Mã hóa JWT & Bảo vệ phiên đăng nhập',
                isDark: isDark,
                onTap: () {},
              ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    provider.logout();
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text(
                    'ĐĂNG XUẤT TÀI KHOẢN',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, bool isDark, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E24) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E24) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryOrange, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: isDark ? Colors.white38 : Colors.black38),
          ],
        ),
      ),
    );
  }

  void _showUrlEditDialog(BuildContext context, ShoppeProvider provider) {
    final TextEditingController urlController = TextEditingController(text: provider.tailscaleUrl);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text('Cấu hình Server URL'),
          content: TextField(
            controller: urlController,
            decoration: InputDecoration(
              hintText: 'https://app.taild6d848.ts.net',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                provider.updateTailscaleUrl(urlController.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }
}
