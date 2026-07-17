class ProductReview {
  final int id;
  final int rating;
  final String? comment;
  final String? username;
  final DateTime? createdAt;

  ProductReview({
    required this.id,
    required this.rating,
    this.comment,
    this.username,
    this.createdAt,
  });

  static int _parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['created_at'] != null) {
      parsedDate = DateTime.tryParse(json['created_at'].toString());
    }
    return ProductReview(
      id: _parseInt(json['id'], 0),
      rating: _parseInt(json['rating'], 5),
      comment: json['comment']?.toString(),
      username: json['username']?.toString() ?? 'Người mua ẩn danh',
      createdAt: parsedDate,
    );
  }
}
