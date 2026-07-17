import 'product.dart';

class CheckoutResult {
  final int orderId;
  final String productName;
  final double virtualPricePaid;
  final double discountAmount;
  final double newVirtualBalance;
  final int dopamineHitsAwarded;
  final int newDopamineLevel;
  final String animationTrigger;
  final String message;

  CheckoutResult({
    required this.orderId,
    required this.productName,
    required this.virtualPricePaid,
    this.discountAmount = 0.0,
    required this.newVirtualBalance,
    required this.dopamineHitsAwarded,
    required this.newDopamineLevel,
    required this.animationTrigger,
    required this.message,
  });

  static int _parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory CheckoutResult.fromJson(Map<String, dynamic> json) {
    return CheckoutResult(
      orderId: _parseInt(json['order_id'], 0),
      productName: json['product_name']?.toString() ?? '',
      virtualPricePaid: _parseDouble(json['virtual_price_paid'], 0.0),
      discountAmount: _parseDouble(json['discount_amount'], 0.0),
      newVirtualBalance: _parseDouble(json['new_virtual_balance'], 0.0),
      dopamineHitsAwarded: _parseInt(json['dopamine_hits_awarded'], 0),
      newDopamineLevel: _parseInt(json['new_dopamine_level'], 0),
      animationTrigger: json['animation_trigger']?.toString() ?? 'EXTREME_CONFETTI_BURST',
      message: json['message']?.toString() ?? 'Acquisition successful!',
    );
  }
}

class VirtualOrderModel {
  final int id;
  final int productId;
  final int quantity;
  final double virtualPricePaid;
  final int dopamineHitsAwarded;
  final String? voucherCode;
  final double discountAmount;
  final String status;
  final DateTime createdAt;
  final VirtualProduct product;

  VirtualOrderModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.virtualPricePaid,
    required this.dopamineHitsAwarded,
    this.voucherCode,
    required this.discountAmount,
    required this.status,
    required this.createdAt,
    required this.product,
  });

  factory VirtualOrderModel.fromJson(Map<String, dynamic> json) {
    return VirtualOrderModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      productId: json['product_id'] is int ? json['product_id'] : int.tryParse(json['product_id'].toString()) ?? 0,
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity'].toString()) ?? 1,
      virtualPricePaid: (json['virtual_price_paid'] as num?)?.toDouble() ?? 0.0,
      dopamineHitsAwarded: json['dopamine_hits_awarded'] is int ? json['dopamine_hits_awarded'] : int.tryParse(json['dopamine_hits_awarded'].toString()) ?? 0,
      voucherCode: json['voucher_code']?.toString(),
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'Chờ xác nhận',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      product: VirtualProduct.fromJson(json['product'] ?? {}),
    );
  }
}

