class Voucher {
  final int id;
  final String code;
  final String discountType;
  final double discountValue;
  final double minOrderValue;
  final double? maxDiscount;
  final bool isActive;
  final bool isClaimed;

  Voucher({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    this.maxDiscount,
    required this.isActive,
    this.isClaimed = false,
  });

  Voucher copyWith({
    int? id,
    String? code,
    String? discountType,
    double? discountValue,
    double? minOrderValue,
    double? maxDiscount,
    bool? isActive,
    bool? isClaimed,
  }) {
    return Voucher(
      id: id ?? this.id,
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minOrderValue: minOrderValue ?? this.minOrderValue,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      isActive: isActive ?? this.isActive,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

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
      isClaimed: json['is_claimed'] ?? false,
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
      'is_claimed': isClaimed,
    };
  }
}

class UserVoucher {
  final int id;
  final int voucherId;
  final bool isUsed;
  final String claimedAt;
  final Voucher voucher;

  UserVoucher({
    required this.id,
    required this.voucherId,
    required this.isUsed,
    required this.claimedAt,
    required this.voucher,
  });

  factory UserVoucher.fromJson(Map<String, dynamic> json) {
    return UserVoucher(
      id: Voucher._parseInt(json['id'], 0),
      voucherId: Voucher._parseInt(json['voucher_id'], 0),
      isUsed: json['is_used'] ?? false,
      claimedAt: json['claimed_at']?.toString() ?? '',
      voucher: Voucher.fromJson(json['voucher'] ?? {}),
    );
  }
}
