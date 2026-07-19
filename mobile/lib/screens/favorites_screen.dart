import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/shoppe_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/product_image_viewer.dart';
import '../models/product.dart';

class FavoritesScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const FavoritesScreen({super.key, this.onNavigateToTab});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final provider = Provider.of<ShoppeProvider>(context, listen: false);
    if (!provider.isAuthenticated) return;
    setState(() => _isLoading = true);
    await provider.fetchFavorites();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShoppeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final favProducts = provider.favoriteProducts;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121214) : const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, color: Color(0xFFFF007F), size: 22),
            const SizedBox(width: 8),
            Text(
              'Wishlist Yêu Thích (${favProducts.length})',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFF007F),
        onRefresh: _loadFavorites,
        child: !provider.isAuthenticated
            ? _buildNotAuthenticatedState(isDark)
            : _isLoading && favProducts.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF007F)),
                  )
                : favProducts.isEmpty
                    ? _buildEmptyState(isDark)
                    : CustomScrollView(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFF007F).withValues(alpha: 0.15),
                                    const Color(0xFFFFD700).withValues(alpha: 0.15),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFFF007F).withValues(alpha: 0.3),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF007F).withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.bolt, color: Colors.amber, size: 24),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Danh Sách Sản Phẩm Yêu Thích',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFFFF007F),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Bạn đang theo dõi ${favProducts.length} sản phẩm yêu thích. Nhận thông báo giảm giá nhanh nhất cho các sản phẩm đã lưu!',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? Colors.white70 : Colors.black87,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 16,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final product = favProducts[index];
                                  return ProductCard(
                                    key: ValueKey(product.id),
                                    product: product,
                                    onBuyTap: () => _openDetail(context, product),
                                  );
                                },
                                childCount: favProducts.length,
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 40)),
                        ],
                      ),
      ),
    );
  }

  void _openDetail(BuildContext context, VirtualProduct product) {
    ProductImageViewer.show(
      context,
      product: product,
      onBuyTap: () {},
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFF007F).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_border_rounded, size: 64, color: Color(0xFFFF007F)),
            ),
            const SizedBox(height: 20),
            Text(
              'Chưa Có Sản Phẩm Yêu Thích',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy chạm vào biểu tượng trái tim 💖 trên các món đồ bạn yêu thích để thêm vào danh sách này nhé!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                if (widget.onNavigateToTab != null) {
                  widget.onNavigateToTab!(0);
                } else {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.explore),
              label: const Text('Khám Phá Ngay', style: TextStyle(fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotAuthenticatedState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'Vui Lòng Đăng Nhập',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đăng nhập tài khoản để đồng bộ và quản lý danh sách sản phẩm yêu thích (Wishlist) của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
