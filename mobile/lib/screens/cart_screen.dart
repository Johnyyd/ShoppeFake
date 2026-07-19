import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/shoppe_provider.dart';
import '../models/cart_item.dart';
import '../theme/app_theme.dart';
import '../widgets/checkout_modal.dart';
import '../utils/currency_format.dart';

class CartScreen extends StatefulWidget {
  final Function(int) onNavigateToTab;

  const CartScreen({super.key, required this.onNavigateToTab});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _voucherController = TextEditingController();
  bool _isAllSelected = true;

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  void _handleCheckout() async {
    final provider = Provider.of<ShoppeProvider>(context, listen: false);
    final selectedCount = provider.cartItems.where((i) => i.isSelected).length;

    if (selectedCount == 0) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất 1 món đồ để thanh toán!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    final result = await provider.checkoutSelectedCartItems(
      voucherCode: _voucherController.text.trim().isNotEmpty ? _voucherController.text.trim() : null,
    );

    if (result != null && mounted) {
      _voucherController.clear();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CheckoutModal(
          result: result,
          onDismiss: () => Navigator.of(context).pop(),
        ),
      );
    } else if (mounted && provider.errorMessage != null) {
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF13131A) : const Color(0xFFFAFAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF13131A) : Colors.white,
        title: Text(
          'Giỏ Hàng (${provider.cartItems.length})',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        actions: [
          if (provider.cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _isAllSelected = !_isAllSelected;
                });
                provider.selectAllCartItems(_isAllSelected);
              },
              child: Text(
                _isAllSelected ? 'Bỏ chọn' : 'Chọn tất cả',
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primaryOrange),
              ),
            ),
        ],
      ),
      body: provider.isLoading && provider.cartItems.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
          : provider.cartItems.isEmpty
              ? _buildEmptyCart(isDark)
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        color: AppTheme.primaryOrange,
                        onRefresh: () async => await provider.fetchCart(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.cartItems.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final item = provider.cartItems[index];
                            return _buildCartItemCard(context, item, isDark);
                          },
                        ),
                      ),
                    ),

                    // Voucher & Checkout Bottom Bar
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Quick select voucher chips if available
                          if (provider.myVouchers.isNotEmpty || provider.activeVouchers.isNotEmpty) ...[
                            SizedBox(
                              height: 34,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (provider.myVouchers.isNotEmpty
                                        ? provider.myVouchers.map((uv) => uv.voucher)
                                        : provider.activeVouchers)
                                    .length,
                                itemBuilder: (context, idx) {
                                  final v = (provider.myVouchers.isNotEmpty
                                      ? provider.myVouchers.map((uv) => uv.voucher).toList()
                                      : provider.activeVouchers)[idx];
                                  final isSelected = _voucherController.text == v.code;
                                  return GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        if (_voucherController.text == v.code) {
                                          _voucherController.clear();
                                        } else {
                                          _voucherController.text = v.code;
                                        }
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppTheme.primaryOrange : AppTheme.primaryOrange.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.local_offer, size: 13, color: isSelected ? Colors.white : AppTheme.primaryOrange),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${v.code} (${v.discountType == "PERCENT" ? "-${v.discountValue.toStringAsFixed(0)}%" : "-${v.discountValue.toVND()}"})',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? Colors.white : AppTheme.primaryOrange,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          // Voucher row
                          Row(
                            children: [
                              const Icon(Icons.confirmation_number_outlined, color: AppTheme.primaryOrange, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: TextField(
                                    controller: _voucherController,
                                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                                    decoration: InputDecoration(
                                      hintText: 'Nhập mã giảm giá (VD: MALL50K)',
                                      hintStyle: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      filled: true,
                                      fillColor: isDark ? const Color(0xFF26262F) : const Color(0xFFF3F4F6),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Total & Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tổng thanh toán:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white60 : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    provider.cartTotalAmount.toVND(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.primaryOrange,
                                      fontFeatures: [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: _handleCheckout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryOrange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'MUA HÀNG (${provider.cartItems.where((i) => i.isSelected).length})',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
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
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItem item, bool isDark) {
    final provider = Provider.of<ShoppeProvider>(context, listen: false);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: item.isSelected,
            activeColor: AppTheme.primaryOrange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            onChanged: (val) {
              HapticFeedback.selectionClick();
              provider.toggleCartItemSelection(item.id);
            },
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 68,
              height: 68,
              color: isDark ? const Color(0xFF2A2A35) : const Color(0xFFF3F4F6),
              child: item.product.imageUrl != null && item.product.imageUrl!.isNotEmpty
                  ? Image.network(item.product.imageUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.shopping_bag, color: AppTheme.primaryOrange, size: 28),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      item.product.priceVirtual.toVND(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryOrange,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const Spacer(),
                    // Quantity controls
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF26262F) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              provider.updateCartQuantity(item.id, item.quantity - 1);
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Icon(Icons.remove, size: 16),
                            ),
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              provider.updateCartQuantity(item.id, item.quantity + 1);
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Icon(Icons.add, size: 16, color: AppTheme.primaryOrange),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        provider.removeCartItem(item.id);
                      },
                      child: Icon(Icons.delete_outline, color: Colors.redAccent.withValues(alpha: 0.8), size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart_outlined, size: 64, color: AppTheme.primaryOrange),
            ),
            const SizedBox(height: 18),
            Text(
              'Giỏ hàng ảo đang trống trơn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Hãy chọn thêm các siêu phẩm chính hãng vào giỏ hàng ngay!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                widget.onNavigateToTab(0); // Switch to Home
              },
              child: const Text('KHÁM PHÁ NGAY'),
            ),
          ],
        ),
      ),
    );
  }
}
