import 'dart:convert';

class UserProfile {
  final String name;
  final int xp;
  final int level;
  final int energy;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastActiveDate;
  final int totalRunesCollected;
  final int totalSpellsCreated;
  final int totalUpgrades;
  final List<String> dailyChallengesCompleted;

  const UserProfile({
    this.name = 'Runesmith',
    this.xp = 0,
    this.level = 1,
    this.energy = 100,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastActiveDate,
    this.totalRunesCollected = 0,
    this.totalSpellsCreated = 0,
    this.totalUpgrades = 0,
    this.dailyChallengesCompleted = const [],
  });

  int get xpForCurrentLevel => level * 100;
  int get xpInCurrentLevel => xp - _totalXpForLevel(level - 1);
  double get levelProgress => xpForCurrentLevel > 0 ? xpInCurrentLevel / xpForCurrentLevel : 0;
  int get xpToNextLevel => xpForCurrentLevel - xpInCurrentLevel;

  int _totalXpForLevel(int lvl) {
    int total = 0;
    for (int i = 1; i <= lvl; i++) {
      total += i * 100;
    }
    return total;
  }

  UserProfile copyWith({
    String? name,
    int? xp,
    int? level,
    int? energy,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastActiveDate,
    int? totalRunesCollected,
    int? totalSpellsCreated,
    int? totalUpgrades,
    List<String>? dailyChallengesCompleted,
  }) {
    return UserProfile(
      name: name ?? this.name,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      energy: energy ?? this.energy,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      totalRunesCollected: totalRunesCollected ?? this.totalRunesCollected,
      totalSpellsCreated: totalSpellsCreated ?? this.totalSpellsCreated,
      totalUpgrades: totalUpgrades ?? this.totalUpgrades,
      dailyChallengesCompleted: dailyChallengesCompleted ?? this.dailyChallengesCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'xp': xp,
    'level': level,
    'energy': energy,
    'currentStreak': currentStreak,
    'bestStreak': bestStreak,
    'lastActiveDate': lastActiveDate?.toIso8601String(),
    'totalRunesCollected': totalRunesCollected,
    'totalSpellsCreated': totalSpellsCreated,
    'totalUpgrades': totalUpgrades,
    'dailyChallengesCompleted': dailyChallengesCompleted,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String? ?? 'Runesmith',
    xp: json['xp'] as int? ?? 0,
    level: json['level'] as int? ?? 1,
    energy: json['energy'] as int? ?? 100,
    currentStreak: json['currentStreak'] as int? ?? 0,
    bestStreak: json['bestStreak'] as int? ?? 0,
    lastActiveDate: json['lastActiveDate'] != null ? DateTime.parse(json['lastActiveDate'] as String) : null,
    totalRunesCollected: json['totalRunesCollected'] as int? ?? 0,
    totalSpellsCreated: json['totalSpellsCreated'] as int? ?? 0,
    totalUpgrades: json['totalUpgrades'] as int? ?? 0,
    dailyChallengesCompleted: json['dailyChallengesCompleted'] != null
        ? List<String>.from(json['dailyChallengesCompleted'] as List)
        : [],
  );

  String encode() => jsonEncode(toJson());

  factory UserProfile.decode(String data) =>
      UserProfile.fromJson(jsonDecode(data) as Map<String, dynamic>);
}
