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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      virtualBalance: (json['virtual_balance'] ?? 0.0).toDouble(),
      dopamineLevel: json['dopamine_level'] ?? 0,
    );
  }
}
