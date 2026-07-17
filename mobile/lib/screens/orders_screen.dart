import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/shoppe_provider.dart';
import '../models/order.dart';
import '../widgets/product_image_viewer.dart';
import '../widgets/product_review_modal.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShoppeProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _changeStatus(BuildContext context, int orderId, String newStatus) async {
    HapticFeedback.mediumImpact();
    final provider = Provider.of<ShoppeProvider>(context, listen: false);
    final success = await provider.updateOrderStatus(orderId, newStatus);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'Đang giao'
                ? '🚚 Đơn hàng đã được chuyển sang trạng thái Đang giao!'
                : '🎉 Chúc mừng! Đơn hàng đã hoàn thành.',
          ),
          backgroundColor: AppTheme.primaryOrange,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<ShoppeProvider>(context);
    final allOrders = provider.orders;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF13131A) : const Color(0xFFFAFAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF13131A) : Colors.white,
        title: Text(
          'Đơn Hàng Ảo',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryOrange),
            onPressed: () => provider.fetchOrders(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryOrange,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
          indicatorColor: AppTheme.primaryOrange,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          onTap: (_) => HapticFeedback.selectionClick(),
          tabs: const [
            Tab(text: 'Chờ xác nhận'),
            Tab(text: 'Đang giao'),
            Tab(text: 'Hoàn thành'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchOrders(),
        color: AppTheme.primaryOrange,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOrderList(isDark, statusLabel: 'Chờ xác nhận', orders: allOrders.where((o) => o.status == 'Chờ xác nhận').toList()),
            _buildOrderList(isDark, statusLabel: 'Đang giao', orders: allOrders.where((o) => o.status == 'Đang giao').toList()),
            _buildOrderList(isDark, statusLabel: 'Hoàn thành', orders: allOrders.where((o) => o.status == 'Hoàn thành' || o.status == 'DELIVERED').toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(bool isDark, {required String statusLabel, required List<VirtualOrderModel> orders}) {
    if (orders.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 68, color: AppTheme.primaryOrange.withValues(alpha: 0.3)),
                const SizedBox(height: 14),
                Text(
                  'Chưa có đơn hàng nào ở trạng thái "$statusLabel"',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white54 : Colors.black54),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final order = orders[index];
        final product = order.product;
        final shopName = product.seller?.shopName ?? 'Luxury Mall';

        Color badgeColor;
        switch (order.status) {
          case 'Chờ xác nhận':
            badgeColor = Colors.orange;
            break;
          case 'Đang giao':
            badgeColor = Colors.blue;
            break;
          default:
            badgeColor = Colors.green;
        }

        return GestureDetector(
          onTap: () {
            if (product.id != 0) {
              ProductImageViewer.show(
                context,
                product: product,
                onBuyTap: () async {
                  final provider = Provider.of<ShoppeProvider>(context, listen: false);
                  final result = await provider.checkoutProduct(product.id);
                  if (result != null && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🎉 Mua lại thành công! Đơn hàng mới đã được thêm vào danh sách.'),
                        backgroundColor: AppTheme.primaryOrange,
                      ),
                    );
                  }
                },
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E24) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.18)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.storefront, size: 16, color: AppTheme.primaryOrange),
                        const SizedBox(width: 6),
                        Text(
                          shopName,
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.status == 'DELIVERED' ? 'Hoàn thành' : order.status,
                        style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                          ? Image.network(
                              product.imageUrl!,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 64,
                                height: 64,
                                color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                                child: const Icon(Icons.auto_awesome, color: AppTheme.primaryOrange, size: 28),
                              ),
                            )
                          : Container(
                              width: 64,
                              height: 64,
                              color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                              child: const Icon(Icons.auto_awesome, color: AppTheme.primaryOrange, size: 28),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name.isNotEmpty ? product.name : 'Vật phẩm Virtual Shoppe',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '🪙 ${order.virtualPricePaid.toStringAsFixed(0)} xu (${order.quantity} cái) • +${order.dopamineHitsAwarded} HITS',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryOrange,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (order.status == 'Chờ xác nhận')
                      ElevatedButton.icon(
                        onPressed: () => _changeStatus(context, order.id, 'Đang giao'),
                        icon: const Icon(Icons.local_shipping_outlined, size: 16, color: Colors.white),
                        label: const Text('🚀 Giao ngay (Demo)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      )
                    else if (order.status == 'Đang giao')
                      ElevatedButton.icon(
                        onPressed: () => _changeStatus(context, order.id, 'Hoàn thành'),
                        icon: const Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
                        label: const Text('📦 Đã nhận hàng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () {
                          ProductReviewModal.show(
                            context,
                            product: product,
                            isCompletedOrder: true,
                            onReviewSubmitted: () {
                              Provider.of<ShoppeProvider>(context, listen: false).fetchOrders();
                            },
                          );
                        },
                        icon: const Icon(Icons.star, size: 16, color: Colors.amber),
                        label: const Text('Đánh giá nhận quà (+50🪙 & +30⚡)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryOrange,
                          side: const BorderSide(color: AppTheme.primaryOrange),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

