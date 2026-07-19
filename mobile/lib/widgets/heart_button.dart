import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/shoppe_provider.dart';
import '../theme/app_theme.dart';

class HeartButton extends StatefulWidget {
  final VirtualProduct product;
  final double size;
  final bool showDopaminePopup;

  const HeartButton({
    super.key,
    required this.product,
    this.size = 22.0,
    this.showDopaminePopup = true,
  });

  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _sparkController;
  late AnimationController _popupController;
  late Animation<double> _popupTranslate;
  late Animation<double> _popupOpacity;

  bool _showPopup = false;

  @override
  void initState() {
    super.initState();

    // Spring scale animation for tactile feel
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.45).chain(CurveTween(curve: Curves.easeOut)), weight: 35),
      TweenSequenceItem(tween: Tween<double>(begin: 1.45, end: 0.90).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 0.90, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 35),
    ]).animate(_scaleController);

    // Spark particles burst animation
    _sparkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    // +5 Dopamine floating text badge animation
    _popupController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _popupTranslate = Tween<double>(begin: 0.0, end: -35.0).animate(
      CurvedAnimation(parent: _popupController, curve: Curves.easeOutCubic),
    );
    _popupOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_popupController);

    _popupController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _showPopup = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _sparkController.dispose();
    _popupController.dispose();
    super.dispose();
  }

  void _onHeartTap() async {
    final provider = Provider.of<ShoppeProvider>(context, listen: false);
    if (!provider.isAuthenticated) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('💖 Vui lòng đăng nhập để thả tim và tích lũy Dopamine!'),
          backgroundColor: AppTheme.primaryOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    final willBeFav = !widget.product.isFavorite;

    // Apple tactile feedback
    HapticFeedback.mediumImpact();
    _scaleController.forward(from: 0.0);

    if (willBeFav) {
      // Trigger particles and dopamine popup only when favoriting
      _sparkController.forward(from: 0.0);
      if (widget.showDopaminePopup) {
        setState(() {
          _showPopup = true;
        });
        _popupController.forward(from: 0.0);
      }
      Future.delayed(const Duration(milliseconds: 150), () {
        HapticFeedback.selectionClick();
      });
    }

    // Call API
    final res = await provider.toggleFavorite(widget.product.id);
    if (res['success'] == true && willBeFav && mounted) {
      // Notify user subtlely or let the animation wow them
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFav = widget.product.isFavorite;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Spark particles layer behind/around heart icon
        AnimatedBuilder(
          animation: _sparkController,
          builder: (context, child) {
            if (!_sparkController.isAnimating && _sparkController.value == 0) {
              return const SizedBox.shrink();
            }
            return CustomPaint(
              size: Size(widget.size * 2.8, widget.size * 2.8),
              painter: _HeartSparksPainter(progress: _sparkController.value),
            );
          },
        ),

        // Floating +5 Dopamine badge
        if (_showPopup)
          Positioned(
            top: -10,
            child: AnimatedBuilder(
              animation: _popupController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _popupTranslate.value),
                  child: Opacity(
                    opacity: _popupOpacity.value.clamp(0.0, 1.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF007F), Color(0xFFFF4D4D)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF007F).withValues(alpha: 0.45),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        '+5 💖',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        // Heart Icon Button with Bouncy Scale
        GestureDetector(
          onTap: _onHeartTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: Container(
              padding: EdgeInsets.all(widget.size * 0.28),
              decoration: BoxDecoration(
                color: isFav
                    ? const Color(0xFFFF007F).withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.45),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isFav
                      ? const Color(0xFFFF007F)
                      : Colors.white.withValues(alpha: 0.3),
                  width: 1.2,
                ),
                boxShadow: isFav
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF007F).withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border_rounded,
                color: isFav ? const Color(0xFFFF007F) : Colors.white,
                size: widget.size,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeartSparksPainter extends CustomPainter {
  final double progress;

  _HeartSparksPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final currentRadius = 6.0 + (maxRadius - 6.0) * math.pow(progress, 0.6);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    const int count = 8;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    final colors = [
      const Color(0xFFFF007F),
      const Color(0xFFFFD700),
      const Color(0xFFFF2A6D),
      const Color(0xFF00E5FF),
    ];

    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi / count) + (progress * 0.4);
      final dx = center.dx + currentRadius * math.cos(angle);
      final dy = center.dy + currentRadius * math.sin(angle);

      paint.color = colors[i % colors.length].withValues(alpha: opacity);
      final particleSize = 3.2 * (1.0 - progress * 0.5);

      canvas.drawCircle(Offset(dx, dy), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeartSparksPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
