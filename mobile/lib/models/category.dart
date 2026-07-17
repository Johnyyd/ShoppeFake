class Category {
  final int id;
  final String name;
  final String? iconName;

  Category({
    required this.id,
    required this.name,
    this.iconName,
  });

  static int _parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: _parseInt(json['id'], 0),
      name: json['name']?.toString() ?? 'Danh mục',
      iconName: json['icon_name']?.toString(),
    );
  }
}
