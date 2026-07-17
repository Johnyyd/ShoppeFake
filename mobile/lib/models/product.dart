class VirtualProduct {
  final int id;
  final String name;
  final String? description;
  final double priceVirtual;
  final String? imageUrl;
  final int dopamineRating;
  final String category;

  VirtualProduct({
    required this.id,
    required this.name,
    this.description,
    required this.priceVirtual,
    this.imageUrl,
    required this.dopamineRating,
    required this.category,
  });

  factory VirtualProduct.fromJson(Map<String, dynamic> json) {
    return VirtualProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Virtual Item',
      description: json['description'],
      priceVirtual: (json['price_virtual'] ?? 0.0).toDouble(),
      imageUrl: json['image_url'],
      dopamineRating: json['dopamine_rating'] ?? 10,
      category: json['category'] ?? 'Luxury',
    );
  }
}
