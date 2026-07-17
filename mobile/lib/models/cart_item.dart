import 'product.dart';

class CartItem {
  final int id;
  final int productId;
  int quantity;
  final VirtualProduct product;
  bool isSelected;

  CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.product,
    this.isSelected = true,
  });

  static int _parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: _parseInt(json['id'], 0),
      productId: _parseInt(json['product_id'], 0),
      quantity: _parseInt(json['quantity'], 1),
      product: VirtualProduct.fromJson(json['product'] ?? {}),
      isSelected: true,
    );
  }
}
