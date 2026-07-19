import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/voucher.dart';
import '../providers/shoppe_provider.dart';
import '../theme/app_theme.dart';
import '../utils/currency_format.dart';

class CheckoutConfirmModal extends StatefulWidget {
  final VirtualProduct product;
  final Function(String? voucherCode) onConfirm;

  const CheckoutConfirmModal({
    super.key,
    required this.product,
    required this.onConfirm,
  });

  static void show(BuildContext context, {required VirtualProduct product, required Function(String? voucherCode) onConfirm}) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CheckoutConfirmModal(product: product, onConfirm: onConfirm),
    );
  }

  @override
  State<CheckoutConfirmModal> createState() => _CheckoutConfirmModalState();
}

class _CheckoutConfirmModalState extends State<CheckoutConfirmModal> {
  Voucher? _selectedVoucher;
  double _discountAmount = 0.0;

  void _selectVoucher(Voucher? voucher) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedVoucher = voucher;
      if (voucher == null) {
        _discountAmount = 0.0;
      } else {
        if (widget.product.priceVirtual < voucher.minOrderValue) {
          _discountAmount = 0.0;
        } else if (voucher.discountType == "PERCENT") {
          double disc = widget.product.priceVirtual * (voucher.discountValue / 100.0);
          if (voucher.maxDiscount != null && disc > voucher.maxDiscount!) {
            disc = voucher.maxDiscount!;
          }
          _discountAmount = disc;
        } else {
          _discountAmount = voucher.discountValue;
        }
        if (_discountAmount > widget.product.priceVirtual) {
          _discountAmount = widget.product.priceVirtual;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<ShoppeProvider>(context);
    final activeVouchers = provider.activeVouchers;
    final finalPrice = widget.product.priceVirtual - _discountAmount;
    final balance = provider.currentUser?.virtualBalance ?? 0.0;
    final hasEnoughBalance = balance >= finalPrice;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 16,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF181820) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: AppTheme.primaryOrange.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryOrange.withValues(alpha: 0.15),
              blurRadius: 25,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.shopping_cart_checkout, color: AppTheme.primaryOrange, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "XÁC NHẬN THANH TOÁN ẢO",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryOrange,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.product.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Voucher Picker Section
            Text(
              "CHỌN MÃ GIẢM GIÁ (VOUCHER)",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white60 : Colors.black54,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),

            if (activeVouchers.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_offer_outlined, color: Colors.grey, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Không có voucher nào khả dụng",
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: activeVouchers.length + 1,
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isSelected = _selectedVoucher == null;
                      return GestureDetector(
                        onTap: () => _selectVoucher(null),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryOrange.withValues(alpha: 0.15) : (isDark ? const Color(0xFF23232A) : const Color(0xFFF3F4F6)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryOrange : (isDark ? Colors.white12 : Colors.black12),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Không dùng\nvoucher",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? AppTheme.primaryOrange : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    final voucher = activeVouchers[index - 1];
                    final isSelected = _selectedVoucher?.code == voucher.code;
                    final isEligible = widget.product.priceVirtual >= voucher.minOrderValue;

                    return Opacity(
                      opacity: isEligible ? 1.0 : 0.45,
                      child: GestureDetector(
                        onTap: isEligible ? () => _selectVoucher(voucher) : () {
                          HapticFeedback.vibrate();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Cần đơn tối thiểu ${voucher.minOrderValue.toVND()} để dùng ${voucher.code}"),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryOrange.withValues(alpha: 0.18) : (isDark ? const Color(0xFF23232A) : const Color(0xFFF3F4F6)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryOrange : (isDark ? Colors.white12 : Colors.black12),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.confirmation_num, color: AppTheme.primaryOrange, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    voucher.code,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? AppTheme.primaryOrange : (isDark ? Colors.white : Colors.black87),
                                    ),
                                  ),
                                  if (voucher.isClaimed || provider.myVouchers.any((uv) => uv.voucher.code == voucher.code)) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text('Ví', style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                voucher.discountType == "PERCENT"
                                    ? "Giảm ${voucher.discountValue.toStringAsFixed(0)}%"
                                    : "Giảm ${voucher.discountValue.toVND()}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),

            // Summary Table
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF23232A) : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Giá gốc sản phẩm:", style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87)),
                      Text(widget.product.priceVirtual.toVND(), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  if (_discountAmount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Mã giảm giá (${_selectedVoucher?.code}):", style: const TextStyle(fontSize: 13, color: Colors.green)),
                        Text("-${_discountAmount.toVND()}", style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.green)),
                      ],
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("THÀNH TIỀN:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black)),
                      Text(
                        finalPrice.toVND(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Số dư hiện tại:", style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)),
                      Text(
                        balance.toVND(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: hasEnoughBalance ? (isDark ? Colors.white70 : Colors.black87) : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasEnoughBalance && !provider.isLoading
                    ? () {
                        HapticFeedback.heavyImpact();
                        Navigator.pop(context);
                        widget.onConfirm(_selectedVoucher?.code);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  disabledBackgroundColor: Colors.grey.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bolt, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            hasEnoughBalance ? "XÁC NHẬN MUA NGAY" : "SỐ DƯ KHÔNG ĐỦ",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
