class ProductImage {
  final int id;
  final String imageUrl;
  final int displayOrder;

  ProductImage({
    required this.id,
    required this.imageUrl,
    required this.displayOrder,
  });

  static int _parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: _parseInt(json['id'], 0),
      imageUrl: json['image_url']?.toString() ?? '',
      displayOrder: _parseInt(json['display_order'], 0),
    );
  }
}
