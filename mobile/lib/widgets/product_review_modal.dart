import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../models/product.dart';
import '../providers/shoppe_provider.dart';
import '../theme/app_theme.dart';

class ProductReviewModal extends StatefulWidget {
  final VirtualProduct product;
  final bool isCompletedOrder;
  final VoidCallback? onReviewSubmitted;

  const ProductReviewModal({
    super.key,
    required this.product,
    this.isCompletedOrder = false,
    this.onReviewSubmitted,
  });

  static void show(
    BuildContext context, {
    required VirtualProduct product,
    bool isCompletedOrder = false,
    VoidCallback? onReviewSubmitted,
  }) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => ProductReviewModal(
        product: product,
        isCompletedOrder: isCompletedOrder,
        onReviewSubmitted: onReviewSubmitted,
      ),
    );
  }

  @override
  State<ProductReviewModal> createState() => _ProductReviewModalState();
}

class _ProductReviewModalState extends State<ProductReviewModal>
    with TickerProviderStateMixin {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  late AnimationController _entranceController;
  late Animation<double> _entranceScale;

  late AnimationController _starBounceController;
  late Animation<double> _starBounceScale;

  late ConfettiController _confettiController;
  bool _isSubmitted = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    // Entrance pop-in animation (<= 200ms compositor ease-out according to review-animations)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _entranceScale = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    );
    _entranceController.forward();

    // Star tap spring bounce
    _starBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _starBounceScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _starBounceController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _commentController.dispose();
    _entranceController.dispose();
    _starBounceController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onStarTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _rating = index;
    });
    _starBounceController.forward(from: 0.0);
  }

  Future<void> _submitReview() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    final provider = Provider.of<ShoppeProvider>(context, listen: false);
    final comment = _commentController.text.trim();
    final result = await provider.submitProductReview(
      widget.product.id,
      _rating,
      comment.isEmpty ? null : comment,
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _isSubmitted = true;
        _isSubmitting = false;
      });

      if (widget.isCompletedOrder) {
        _confettiController.play();
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 120));
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.mediumImpact();
      }

      widget.onReviewSubmitted?.call();
    } else {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Có lỗi xảy ra khi gửi đánh giá'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.center,
      children: [
        ScaleTransition(
          scale: _entranceScale,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 380),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryOrange.withValues(alpha: 0.25),
                    blurRadius: 30,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              child: _isSubmitted ? _buildSuccessView(isDark) : _buildFormView(isDark),
            ),
          ),
        ),
        // Confetti burst on top of dialog
        Positioned(
          top: 100,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: math.pi / 2,
            maxBlastForce: 25,
            minBlastForce: 8,
            emissionFrequency: 0.05,
            numberOfParticles: 25,
            gravity: 0.2,
            colors: const [
              Colors.orange,
              Colors.amber,
              Colors.pinkAccent,
              Colors.yellow,
              Colors.cyan,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormView(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: AppTheme.primaryOrange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Đánh Giá Sản Phẩm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                color: isDark ? Colors.white54 : Colors.black54,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Product name banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 18, color: AppTheme.primaryOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.product.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (widget.isCompletedOrder) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryOrange.withValues(alpha: 0.15),
                    Colors.amber.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: AppTheme.primaryOrange, size: 22),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đánh giá đơn hoàn thành nhận ngay +50 xu & +30 Dopamine ⚡!',
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
          ],
          const SizedBox(height: 20),
          // Star rating widget with scale bounce
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              final isSelected = starIndex <= _rating;

              return GestureDetector(
                onTap: () => _onStarTapped(starIndex),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AnimatedBuilder(
                    animation: _starBounceScale,
                    builder: (context, child) {
                      final scale = (_rating == starIndex) ? _starBounceScale.value : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: Icon(
                          isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: isSelected ? Colors.amber : (isDark ? Colors.white24 : Colors.grey.shade300),
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Text(
            _getRatingText(_rating),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 20),
          // Comment box
          TextField(
            controller: _commentController,
            maxLines: 4,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Chia sẻ trải nghiệm sử dụng, chất lượng, độ hài lòng...',
              hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade50,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Submit button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: AppTheme.primaryOrange.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          widget.isCompletedOrder ? 'Gửi Đánh Giá & Nhận Quà 🎁' : 'Gửi Đánh Giá',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
          ),
          const SizedBox(height: 18),
          Text(
            widget.isCompletedOrder ? '🎉 DOPAMINE SURGE!' : '🎉 Cảm ơn bạn!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.isCompletedOrder
                ? 'Đánh giá của bạn đã được ghi nhận. Hệ thống vừa thưởng nóng cho bạn!'
                : 'Đánh giá của bạn đã được ghi nhận, giúp cộng đồng mua sắm tốt hơn.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.isCompletedOrder) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildRewardColumn('Dopamine', '+30 ⚡', Colors.amber),
                  Container(
                    width: 1,
                    height: 36,
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300,
                  ),
                  _buildRewardColumn('Thưởng Xu', '+50 🪙', AppTheme.primaryOrange),
                ],
              ),
            ),
          ],
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Tuyệt Vời! Đóng lại',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardColumn(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
        ),
      ],
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Tệ';
      case 2:
        return 'Không hài lòng';
      case 3:
        return 'Bình thường';
      case 4:
        return 'Hài lòng';
      case 5:
      default:
        return 'Tuyệt vời, cực kỳ hài lòng!';
    }
  }
}
