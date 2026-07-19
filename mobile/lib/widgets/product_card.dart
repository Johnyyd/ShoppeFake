import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import 'product_image_viewer.dart';
import 'heart_button.dart';
import '../utils/currency_format.dart';

class ProductCard extends StatefulWidget {
  final VirtualProduct product;
  final VoidCallback onBuyTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onBuyTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Micro-animation <= 200ms using only compositor scale prop
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    HapticFeedback.selectionClick();
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: () {
        ProductImageViewer.show(
          context,
          product: widget.product,
          onBuyTap: widget.onBuyTap,
        );
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E24) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppTheme.primaryOrange.withValues(alpha: isDark ? 0.28 : 0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryOrange.withValues(alpha: isDark ? 0.08 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image / Preview area with Double-Bezel
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF25252D) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty
                            ? Image.network(
                                widget.product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(isDark),
                              )
                            : _buildImagePlaceholder(isDark),

                        // Top-left Badges (Mall + Discount + Category)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD0011B), // Shopee Mall red
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Mall',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  if ((widget.product.discountPercentage) > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFCC00),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '-${(widget.product.discountPercentage).toString()}%',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFD0011B),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD0011B).withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.product.category.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Wishlist Heart
                        Positioned(
                          top: 8,
                          right: 8,
                          child: HeartButton(
                            product: widget.product,
                            size: 16.0,
                          ),
                        ),

                        // Zoom overlay hint
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.zoom_in, color: Colors.white70, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Shop name / verification
              Row(
                children: [
                  const Icon(Icons.storefront, size: 13, color: AppTheme.primaryOrange),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.product.seller?.shopName ?? "Gian Hàng Mall",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.product.seller?.isVerified ?? true)
                    const Padding(
                      padding: EdgeInsets.only(left: 3),
                      child: Icon(Icons.verified, size: 12, color: Colors.blue),
                    ),
                ],
              ),
              const SizedBox(height: 4),

              // Title
              Text(
                widget.product.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Rating and sold count
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 13),
                  const SizedBox(width: 3),
                  Text(
                    (widget.product.averageRating).toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      ' | Đã bán ${(widget.product.soldCount) > 999 ? "${((widget.product.soldCount) / 1000).toStringAsFixed(1)}k" : (widget.product.soldCount).toString()}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Price & CTA button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.product.originalPrice != null && widget.product.originalPrice! > widget.product.priceVirtual)
                          Text(
                            widget.product.originalPrice!.toVND(),
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white38 : Colors.grey.shade600,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          widget.product.priceVirtual.toVND(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryOrange,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      widget.onBuyTap();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_bag, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'MUA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF2A2A35) : const Color(0xFFE5E7EB),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          size: 36,
          color: AppTheme.primaryOrange.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
