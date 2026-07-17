import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/shoppe_provider.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';

class DailyCheckinCard extends StatefulWidget {
  const DailyCheckinCard({super.key});

  @override
  State<DailyCheckinCard> createState() => _DailyCheckinCardState();
}

class _DailyCheckinCardState extends State<DailyCheckinCard>
    with SingleTickerProviderStateMixin {
  bool _isCheckingIn = false;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> _rewards = [
    {'day': 1, 'coins': 50, 'dopamine': 10},
    {'day': 2, 'coins': 70, 'dopamine': 15},
    {'day': 3, 'coins': 100, 'dopamine': 20},
    {'day': 4, 'coins': 120, 'dopamine': 25},
    {'day': 5, 'coins': 150, 'dopamine': 30},
    {'day': 6, 'coins': 200, 'dopamine': 40},
    {'day': 7, 'coins': 300, 'dopamine': 50},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckin(BuildContext context, ShoppeProvider provider) async {
    if (_isCheckingIn) return;
    HapticFeedback.mediumImpact();

    setState(() => _isCheckingIn = true);

    final result = await provider.dailyCheckin();

    if (!mounted || !context.mounted) return;
    setState(() => _isCheckingIn = false);

    if (result != null) {
      // Trigger celebratory overlay with Confetti and spring bounce
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _DailyCheckinCelebrationModal(result: result),
      );
    } else if (provider.errorMessage != null) {
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
    if (user == null) return const SizedBox.shrink();

    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final isCheckedInToday = user.lastCheckinDate == todayStr;
    final currentStreak = user.checkinStreak;
    final nextDayIndex = isCheckedInToday
        ? ((currentStreak - 1) % 7)
        : (currentStreak % 7);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E24) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCheckedInToday
                ? Colors.green.withValues(alpha: 0.3)
                : AppTheme.primaryOrange.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (isCheckedInToday ? Colors.green : AppTheme.primaryOrange)
                  .withValues(alpha: 0.08),
              blurRadius: 16,
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCheckedInToday
                            ? Colors.green.withValues(alpha: 0.15)
                            : AppTheme.primaryOrange.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCheckedInToday ? Icons.check_circle : Icons.calendar_today_rounded,
                        color: isCheckedInToday ? Colors.green : AppTheme.primaryOrange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Điểm Danh Mỗi Ngày',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          isCheckedInToday
                              ? 'Đã điểm danh hôm nay! (Streak: $currentStreak ngày)'
                              : 'Tích streak nhận tới 300🪙 xu ảo',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (currentStreak > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('🔥 ', style: TextStyle(fontSize: 12)),
                        Text(
                          '$currentStreak ngày',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            // 7 Days Streak Tracker
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(7, (index) {
                  final dayData = _rewards[index];
                  final dayNumber = dayData['day'] as int;
                  final coins = dayData['coins'] as int;
                  final isCompleted = isCheckedInToday
                      ? index <= nextDayIndex
                      : index < nextDayIndex;
                  final isCurrentTarget = !isCheckedInToday && index == nextDayIndex;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      width: 62,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green.withValues(alpha: 0.12)
                            : (isCurrentTarget
                                ? AppTheme.primaryOrange.withValues(alpha: 0.15)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : Colors.grey.shade100)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCompleted
                              ? Colors.green
                              : (isCurrentTarget
                                  ? AppTheme.primaryOrange
                                  : Colors.transparent),
                          width: isCurrentTarget ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ngày $dayNumber',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isCurrentTarget ? FontWeight.w800 : FontWeight.w600,
                              color: isCompleted
                                  ? Colors.green
                                  : (isCurrentTarget ? AppTheme.primaryOrange : (isDark ? Colors.white70 : Colors.black87)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          isCompleted
                              ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20)
                              : Text(
                                  '+$coins🪙',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: isCurrentTarget
                                        ? AppTheme.primaryOrange
                                        : (isDark ? Colors.white60 : Colors.black54),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),
            // Button
            if (!isCheckedInToday)
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isCheckingIn ? null : () => _handleCheckin(context, provider),
                    icon: _isCheckingIn
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.card_giftcard_rounded, size: 20),
                    label: Text(
                      _isCheckingIn ? 'ĐANG ĐIỂM DANH...' : '🎁 ĐIỂM DANH NHẬN +${_rewards[nextDayIndex]['coins']} XU NGAY',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppTheme.primaryOrange.withValues(alpha: 0.4),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Hôm nay bạn đã điểm danh thành công!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DailyCheckinCelebrationModal extends StatefulWidget {
  final DailyCheckinResult result;

  const _DailyCheckinCelebrationModal({required this.result});

  @override
  State<_DailyCheckinCelebrationModal> createState() =>
      _DailyCheckinCelebrationModalState();
}

class _DailyCheckinCelebrationModalState
    extends State<_DailyCheckinCelebrationModal>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );

    _scaleController.forward();
    _confettiController.play();

    // Haptic feedback sequence
    _triggerCelebrationHaptics();
  }

  Future<void> _triggerCelebrationHaptics() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Path _drawStar(Size size) {
    double degToRad(double deg) => deg * (math.pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * math.cos(step),
        halfWidth + externalRadius * math.sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * math.cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * math.sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.center,
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: BorderSide(
                color: AppTheme.primaryOrange.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            backgroundColor: isDark ? const Color(0xFF181820) : Colors.white,
            elevation: 24,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppTheme.primaryOrange,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '🎉 ĐIỂM DANH THÀNH CÔNG!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryOrange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bạn đã đạt chuỗi liên tiếp ${widget.result.streak} ngày!',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
                        Column(
                          children: [
                            const Text('Thưởng Xu', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              '+${widget.result.rewardCoins.toStringAsFixed(0)} 🪙',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryOrange),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300,
                        ),
                        Column(
                          children: [
                            const Text('Dopamine', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              '+${widget.result.rewardDopamine} ⚡',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.amber),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'TUYỆT VỜI!',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            AppTheme.primaryOrange,
            Colors.amber,
            Colors.purpleAccent,
            Colors.blueAccent,
            Colors.greenAccent,
            Colors.pinkAccent,
          ],
          createParticlePath: _drawStar,
        ),
      ],
    );
  }
}
