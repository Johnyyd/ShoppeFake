import 'seller.dart';
import 'product_image.dart';
import 'product_review.dart';

class VirtualProduct {
  final int id;
  final String name;
  final String? description;
  final double priceVirtual;
  final double? originalPrice;
  final int discountPercentage;
  final String? imageUrl;
  final int dopamineRating;
  final String category;
  final int? categoryId;
  final int? sellerId;
  final int stockQuantity;
  final int soldCount;
  final double averageRating;
  final Seller? seller;
  final List<ProductImage> images;
  final List<ProductReview> reviews;

  VirtualProduct({
    required this.id,
    required this.name,
    this.description,
    required this.priceVirtual,
    this.originalPrice,
    this.discountPercentage = 0,
    this.imageUrl,
    required this.dopamineRating,
    required this.category,
    this.categoryId,
    this.sellerId,
    this.stockQuantity = 999,
    this.soldCount = 0,
    this.averageRating = 5.0,
    this.seller,
    this.images = const [],
    this.reviews = const [],
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

  factory VirtualProduct.fromJson(Map<String, dynamic> json) {
    var rawImages = json['images'] as List? ?? [];
    var rawReviews = json['reviews'] as List? ?? [];

    List<ProductImage> parsedImages = rawImages.map((i) => ProductImage.fromJson(i)).toList();
    List<ProductReview> parsedReviews = rawReviews.map((r) => ProductReview.fromJson(r)).toList();

    return VirtualProduct(
      id: _parseInt(json['id'], 0),
      name: json['name']?.toString() ?? 'Virtual Item',
      description: json['description']?.toString(),
      priceVirtual: _parseDouble(json['price_virtual'], 0.0),
      originalPrice: json['original_price'] != null ? _parseDouble(json['original_price']) : null,
      discountPercentage: _parseInt(json['discount_percentage'], 0),
      imageUrl: json['image_url']?.toString(),
      dopamineRating: _parseInt(json['dopamine_rating'], 10),
      category: json['category']?.toString() ?? 'Luxury',
      categoryId: json['category_id'] != null ? _parseInt(json['category_id']) : null,
      sellerId: json['seller_id'] != null ? _parseInt(json['seller_id']) : null,
      stockQuantity: _parseInt(json['stock_quantity'], 999),
      soldCount: _parseInt(json['sold_count'], 0),
      averageRating: _parseDouble(json['average_rating'], 5.0),
      seller: json['seller'] != null ? Seller.fromJson(json['seller']) : null,
      images: parsedImages,
      reviews: parsedReviews,
    );
  }
}

