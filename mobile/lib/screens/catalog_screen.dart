import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/shoppe_provider.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/checkout_modal.dart';
import '../widgets/checkout_confirm_modal.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shopping_bag, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              user?.username ?? 'Shopper',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ],
        ),
        actions: [
          // Dopamine Level badge
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: Row(
              children: [
                const Icon(Icons.bolt, color: Colors.amber, size: 15),
                const SizedBox(width: 3),
                Text(
                  '${user?.dopamineLevel ?? 0} HITS',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.amber,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          // Virtual Balance badge
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: Row(
              children: [
                const Text('🪙 ', style: TextStyle(fontSize: 12)),
                Text(
                  user?.virtualBalance.toStringAsFixed(0) ?? "0",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryOrange,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout, size: 20, color: isDark ? Colors.white70 : Colors.black87),
            onPressed: () {
              HapticFeedback.lightImpact();
              provider.logout();
            },
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: provider.isLoading && provider.products.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryOrange),
            )
          : RefreshIndicator(
              color: AppTheme.primaryOrange,
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                await provider.fetchProducts();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department, color: AppTheme.primaryOrange, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CHỢ ẢO SHOPPE FAKE - SĂN DOPAMINE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Chạm để xem chi tiết & áp mã giảm giá thần tốc',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: provider.products.length,
                        itemBuilder: (context, index) {
                          final product = provider.products[index];
                          return ProductCard(
                            product: product,
                            onBuyTap: () => _handleBuyClick(context, product),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
