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

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ShoppeProvider>(context, listen: false);
    _searchController.text = provider.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchSubmit(String value) {
    HapticFeedback.selectionClick();
    final provider = Provider.of<ShoppeProvider>(context, listen: false);
    provider.fetchProducts(
      category: provider.selectedCategory,
      searchQuery: value,
      sortBy: provider.sortBy,
    );
  }

  void _handleCategorySelect(Category? category) {
    HapticFeedback.selectionClick();
    final provider = Provider.of<ShoppeProvider>(context, listen: false);
    provider.fetchProducts(
      category: category,
      searchQuery: _searchController.text,
      sortBy: provider.sortBy,
    );
  }

  void _handleSortSelect(String sortBy) {
    HapticFeedback.selectionClick();
    final provider = Provider.of<ShoppeProvider>(context, listen: false);
    provider.fetchProducts(
      category: provider.selectedCategory,
      searchQuery: _searchController.text,
      sortBy: sortBy,
    );
  }

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF13131A) : const Color(0xFFFAFAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF13131A) : Colors.white,
        titleSpacing: 16,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E24) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.3)),
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _handleSearchSubmit,
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm vật phẩm ảo...',
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryOrange, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _handleSearchSubmit('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _handleSearchSubmit(_searchController.text),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Tìm',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter & Sort section
          Container(
            color: isDark ? const Color(0xFF13131A) : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        context,
                        label: 'Tất cả',
                        isSelected: provider.selectedCategory == null,
                        onTap: () => _handleCategorySelect(null),
                        isDark: isDark,
                      ),
                      ...provider.categories.map((cat) {
                        return _buildFilterChip(
                          context,
                          label: cat.name,
                          isSelected: provider.selectedCategory?.id == cat.id,
                          onTap: () => _handleCategorySelect(cat),
                          isDark: isDark,
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Sort Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildSortPill(context, 'Phổ biến', 'popular', provider.sortBy, isDark),
                      _buildSortPill(context, 'Giá thấp tới cao', 'price_asc', provider.sortBy, isDark),
                      _buildSortPill(context, 'Giá cao tới thấp', 'price_desc', provider.sortBy, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Results Grid
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
                : provider.products.isEmpty
                    ? _buildEmptyState(isDark)
                    : RefreshIndicator(
                        color: AppTheme.primaryOrange,
                        onRefresh: () async {
                          _handleSearchSubmit(_searchController.text);
                        },
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, {required String label, required bool isSelected, required VoidCallback onTap, required bool isDark}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange : (isDark ? const Color(0xFF1E1E24) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppTheme.primaryOrange : (isDark ? Colors.white12 : Colors.black12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildSortPill(BuildContext context, String label, String sortValue, String currentSort, bool isDark) {
    final isSelected = currentSort == sortValue || (currentSort.isEmpty && sortValue == 'popular');
    return GestureDetector(
      onTap: () => _handleSortSelect(sortValue),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryOrange : (isDark ? Colors.white24 : Colors.grey.shade300),
          ),
        ),
        child: Row(
          children: [
            if (isSelected) const Icon(Icons.check, color: AppTheme.primaryOrange, size: 14),
            if (isSelected) const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppTheme.primaryOrange : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
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
              child: const Icon(Icons.search_off, size: 64, color: AppTheme.primaryOrange),
            ),
            const SizedBox(height: 18),
            Text(
              'Không tìm thấy sản phẩm nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Hãy thử từ khóa khác hoặc bỏ chọn bộ lọc danh mục.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
