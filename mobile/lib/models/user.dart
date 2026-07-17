class User {
  final int id;
  final String username;
  final double virtualBalance;
  final int dopamineLevel;

  User({
    required this.id,
    required this.username,
    required this.virtualBalance,
    required this.dopamineLevel,
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseInt(json['id'], 0),
      username: json['username']?.toString() ?? '',
      virtualBalance: _parseDouble(json['virtual_balance'], 0.0),
      dopamineLevel: _parseInt(json['dopamine_level'], 0),
    );
  }
}
