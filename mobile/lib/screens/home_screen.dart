import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/shoppe_provider.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/checkout_confirm_modal.dart';
import '../widgets/checkout_modal.dart';
import '../widgets/daily_checkin_card.dart';
import '../models/voucher.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const HomeScreen({super.key, required this.onNavigateToTab});

  void _handleBuyClick(BuildContext context, VirtualProduct product) {
    HapticFeedback.mediumImpact();
    CheckoutConfirmModal.show(
      context,
      product: product,
      onConfirm: (voucherCode) => _executeCheckout(context, product.id, voucherCode),
    );
  }

  void _executeCheckout(BuildContext context, int productId, String? voucherCode) async {
    final provider = Provider.of<ShoppeProvider>(context, listen: false);
    final result = await provider.checkoutProduct(productId, voucherCode: voucherCode);

    if (result != null && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CheckoutModal(
          result: result,
          onDismiss: () => Navigator.of(context).pop(),
        ),
      );
    } else if (context.mounted && provider.errorMessage != null) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShoppeProvider>(context);
    final user = provider.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF13131A) : const Color(0xFFFAFAFB),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryOrange,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            await provider.fetchInitialData();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header & Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [AppTheme.primaryOrange, Color(0xFFFF3D00)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.shopping_bag, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Shoppe',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                      color: isDark ? Colors.white : const Color(0xFF111827),
                                    ),
                                  ),
                                  Text(
                                    'Fake',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                      color: AppTheme.primaryOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Spacer(),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Dopamine Level badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.bolt, color: Colors.amber, size: 15),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${user?.dopamineLevel ?? 0} HITS',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.amber,
                                            fontFeatures: [FontFeature.tabularFigures()],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Virtual Balance badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryOrange.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('🪙 ', style: TextStyle(fontSize: 12)),
                                        Text(
                                          user?.virtualBalance.toStringAsFixed(0) ?? "0",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            color: AppTheme.primaryOrange,
                                            fontFeatures: [FontFeature.tabularFigures()],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Search Bar Trigger -> Goes to Search screen (Tab 1)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onNavigateToTab(1);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: AppTheme.primaryOrange.withValues(alpha: 0.25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: AppTheme.primaryOrange, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Tìm kiếm siêu phẩm ảo, voucher giảm giá...',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.white54 : Colors.black45,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'TÌM NGAY',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primaryOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Daily Check-in Card
              const SliverToBoxAdapter(
                child: DailyCheckinCard(),
              ),

              // Claimable Vouchers Section
              SliverToBoxAdapter(
                child: _buildVoucherSection(context, provider, isDark),
              ),

              // Flash Sale Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF5E00), Color(0xFFFF2A00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5E00).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -15,
                          bottom: -15,
                          child: Icon(
                            Icons.bolt,
                            size: 110,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.flash_on, color: Color(0xFFFF2A00), size: 14),
                                        SizedBox(width: 2),
                                        Flexible(
                                          child: Text(
                                            'FLASH SALE DOPAMINE',
                                            style: TextStyle(
                                              color: Color(0xFFFF2A00),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    '⚡ 02:45:19',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      fontFeatures: [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'ĐẠI TIỆC MUA SẮM ẢO\nNHẬN X10 HƯNG PHẤN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Giảm tới 50% toàn bộ gian hàng Mall • Freeship vô cực',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Categories Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DANH MỤC NGÀNH HÀNG',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onNavigateToTab(1),
                        child: const Text(
                          'Xem tất cả >',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 95,
                  child: provider.categories.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: provider.categories.length,
                          itemBuilder: (context, index) {
                            final category = provider.categories[index];
                            return _buildCategoryItem(context, category, isDark);
                          },
                        ),
                ),
              ),

              // Recommended Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.thumb_up_alt, color: AppTheme.primaryOrange, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'GỢI Ý HÔM NAY - SĂN ĐỈNH CAO',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Products Grid
              provider.isLoading && provider.products.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange)),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = provider.products[index];
                            return ProductCard(
                              product: product,
                              onBuyTap: () => _handleBuyClick(context, product),
                            );
                          },
                          childCount: provider.products.length,
                        ),
                      ),
                    ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, Category category, bool isDark) {
    IconData iconData = Icons.category;
    switch (category.iconName) {
      case 'bolt':
        iconData = Icons.bolt;
        break;
      case 'diamond':
        iconData = Icons.diamond;
        break;
      case 'card_membership':
        iconData = Icons.card_membership;
        break;
      case 'stars':
        iconData = Icons.stars;
        break;
      case 'sentiment_very_satisfied':
        iconData = Icons.sentiment_very_satisfied;
        break;
      case 'emoji_events':
        iconData = Icons.emoji_events;
        break;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        final provider = Provider.of<ShoppeProvider>(context, listen: false);
        provider.fetchProducts(category: category);
        onNavigateToTab(1); // switch to search tab with selected category
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryOrange.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(iconData, color: AppTheme.primaryOrange, size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherSection(BuildContext context, ShoppeProvider provider, bool isDark) {
    final activeVouchers = provider.activeVouchers;
    if (activeVouchers.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_activity_rounded, color: AppTheme.primaryOrange, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '🎁 Mã Giảm Giá Khủng',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _showMyVouchersWalletModal(context, provider);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Ví của tôi (${provider.myVouchers.length}) >',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 96,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: activeVouchers.length,
              itemBuilder: (ctx, index) {
                final voucher = activeVouchers[index];
                final isClaimed = voucher.isClaimed;

                return Container(
                  width: 250,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isClaimed
                          ? Colors.green.withValues(alpha: 0.4)
                          : AppTheme.primaryOrange.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isClaimed ? Colors.green : AppTheme.primaryOrange)
                            .withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isClaimed
                              ? Colors.green.withValues(alpha: 0.15)
                              : AppTheme.primaryOrange.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isClaimed ? Icons.check_circle : Icons.confirmation_num_rounded,
                          color: isClaimed ? Colors.green : AppTheme.primaryOrange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              voucher.discountType == 'PERCENT'
                                  ? 'Giảm ${voucher.discountValue.toStringAsFixed(0)}%'
                                  : 'Giảm ${voucher.discountValue.toStringAsFixed(0)} xu',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: isClaimed ? Colors.green : AppTheme.primaryOrange,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Đơn từ ${voucher.minOrderValue.toStringAsFixed(0)} xu',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Mã: ${voucher.code}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      isClaimed
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ĐÃ LƯU',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.green,
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () => _handleClaimVoucher(context, provider, voucher),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                minimumSize: const Size(56, 32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'LƯU',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleClaimVoucher(BuildContext context, ShoppeProvider provider, Voucher voucher) async {
    HapticFeedback.mediumImpact();
    final success = await provider.claimVoucher(voucher.id);
    if (!context.mounted) return;

    if (success) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text('🎉 Đã lưu mã ${voucher.code} vào ví! Dùng ngay tại giỏ hàng.'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (provider.errorMessage != null) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showMyVouchersWalletModal(BuildContext context, ShoppeProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        final myVouchers = provider.myVouchers;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181820) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🎟️ Ví Voucher Của Tôi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    '${myVouchers.length} mã khả dụng',
                    style: const TextStyle(fontSize: 13, color: AppTheme.primaryOrange, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (myVouchers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.confirmation_num_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Bạn chưa lưu mã giảm giá nào trong ví', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: myVouchers.length,
                    itemBuilder: (ctx, idx) {
                      final uv = myVouchers[idx];
                      final v = uv.voucher;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF22222A) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.discountType == 'PERCENT'
                                      ? 'Giảm ${v.discountValue.toStringAsFixed(0)}% tối đa ${v.maxDiscount?.toStringAsFixed(0) ?? '∞'} xu'
                                      : 'Giảm trực tiếp ${v.discountValue.toStringAsFixed(0)} xu',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.primaryOrange),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Đơn tối thiểu ${v.minOrderValue.toStringAsFixed(0)} xu',
                                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
                                ),
                                Text(
                                  'Mã: ${v.code}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.green),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Dùng Ngay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
