class Voucher {
  final int id;
  final String code;
  final String discountType;
  final double discountValue;
  final double minOrderValue;
  final double? maxDiscount;
  final bool isActive;

  Voucher({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    this.maxDiscount,
    required this.isActive,
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

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: _parseInt(json['id'], 0),
      code: json['code']?.toString() ?? '',
      discountType: json['discount_type']?.toString() ?? 'PERCENT',
      discountValue: _parseDouble(json['discount_value'], 0.0),
      minOrderValue: _parseDouble(json['min_order_value'], 0.0),
      maxDiscount: json['max_discount'] != null ? _parseDouble(json['max_discount']) : null,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discount_type': discountType,
      'discount_value': discountValue,
      'min_order_value': minOrderValue,
      'max_discount': maxDiscount,
      'is_active': isActive,
    };
  }
}
