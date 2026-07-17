class Seller {
  final int id;
  final String shopName;
  final String? description;
  final String? logoUrl;
  final double rating;
  final bool isVerified;

  Seller({
    required this.id,
    required this.shopName,
    this.description,
    this.logoUrl,
    required this.rating,
    required this.isVerified,
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

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: _parseInt(json['id'], 0),
      shopName: json['shop_name']?.toString() ?? 'Prestige Store',
      description: json['description']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      rating: _parseDouble(json['rating'], 5.0),
      isVerified: json['is_verified'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_name': shopName,
      'description': description,
      'logo_url': logoUrl,
      'rating': rating,
      'is_verified': isVerified,
    };
  }
}
