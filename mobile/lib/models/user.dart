class User {
  final int id;
  final String username;
  final double virtualBalance;
  final int dopamineLevel;
  final String? lastCheckinDate;
  final int checkinStreak;

  User({
    required this.id,
    required this.username,
    required this.virtualBalance,
    required this.dopamineLevel,
    this.lastCheckinDate,
    this.checkinStreak = 0,
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
      lastCheckinDate: json['last_checkin_date']?.toString(),
      checkinStreak: _parseInt(json['checkin_streak'], 0),
    );
  }
}

class DailyCheckinResult {
  final String message;
  final double rewardCoins;
  final int rewardDopamine;
  final int streak;
  final double virtualBalance;
  final int dopamineLevel;

  DailyCheckinResult({
    required this.message,
    required this.rewardCoins,
    required this.rewardDopamine,
    required this.streak,
    required this.virtualBalance,
    required this.dopamineLevel,
  });

  factory DailyCheckinResult.fromJson(Map<String, dynamic> json) {
    return DailyCheckinResult(
      message: json['message']?.toString() ?? 'Điểm danh thành công!',
      rewardCoins: User._parseDouble(json['reward_coins'], 50.0),
      rewardDopamine: User._parseInt(json['reward_dopamine'], 10),
      streak: User._parseInt(json['streak'], 1),
      virtualBalance: User._parseDouble(json['virtual_balance'], 0.0),
      dopamineLevel: User._parseInt(json['dopamine_level'], 0),
    );
  }
}
