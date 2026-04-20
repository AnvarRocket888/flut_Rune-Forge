import 'dart:convert';

class AchievementModel {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final String category;
  final int target;
  final int current;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
    required this.target,
    this.current = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0;

  AchievementModel copyWith({int? current, bool? isUnlocked, DateTime? unlockedAt}) {
    return AchievementModel(
      id: id,
      name: name,
      description: description,
      emoji: emoji,
      category: category,
      target: target,
      current: current ?? this.current,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'emoji': emoji,
    'category': category,
    'target': target,
    'current': current,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };

  factory AchievementModel.fromJson(Map<String, dynamic> json) => AchievementModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    emoji: json['emoji'] as String,
    category: json['category'] as String,
    target: json['target'] as int,
    current: json['current'] as int? ?? 0,
    isUnlocked: json['isUnlocked'] as bool? ?? false,
    unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt'] as String) : null,
  );

  static String encodeList(List<AchievementModel> list) =>
      jsonEncode(list.map((a) => a.toJson()).toList());

  static List<AchievementModel> decodeList(String data) {
    final l = jsonDecode(data) as List;
    return l.map((e) => AchievementModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static List<AchievementModel> defaults() => [
    // Collection
    const AchievementModel(id: 'first_rune', name: 'First Rune', description: 'Collect your first rune', emoji: '🌟', category: 'Collection', target: 1),
    const AchievementModel(id: 'rune_collector_10', name: 'Rune Collector', description: 'Collect 10 runes', emoji: '📦', category: 'Collection', target: 10),
    const AchievementModel(id: 'rune_hoarder_50', name: 'Rune Hoarder', description: 'Collect 50 runes', emoji: '🏪', category: 'Collection', target: 50),
    const AchievementModel(id: 'rune_master_100', name: 'Century Collection', description: 'Collect 100 runes', emoji: '💯', category: 'Collection', target: 100),
    const AchievementModel(id: 'all_elements', name: 'Elemental Balance', description: 'Collect a rune of each element', emoji: '🌀', category: 'Collection', target: 5),
    // Forging
    const AchievementModel(id: 'first_spell', name: 'Spell Weaver', description: 'Create your first spell', emoji: '🪄', category: 'Forging', target: 1),
    const AchievementModel(id: 'spell_5', name: 'Enchanter', description: 'Create 5 spells', emoji: '📜', category: 'Forging', target: 5),
    const AchievementModel(id: 'spell_master', name: 'Archmage', description: 'Create 20 spells', emoji: '🧙', category: 'Forging', target: 20),
    // Tower
    const AchievementModel(id: 'floor_1', name: 'Foundation Laid', description: 'Complete the first tower floor', emoji: '🏗️', category: 'Tower', target: 1),
    const AchievementModel(id: 'floor_5', name: 'Half Tower', description: 'Reach floor 5 of the tower', emoji: '🏰', category: 'Tower', target: 5),
    const AchievementModel(id: 'floor_10', name: 'Crown Builder', description: 'Complete the entire tower', emoji: '👑', category: 'Tower', target: 10),
    // Streaks
    const AchievementModel(id: 'streak_3', name: 'Getting Started', description: 'Maintain a 3-day streak', emoji: '🔥', category: 'Streaks', target: 3),
    const AchievementModel(id: 'streak_7', name: 'Week Warrior', description: 'Maintain a 7-day streak', emoji: '⚔️', category: 'Streaks', target: 7),
    const AchievementModel(id: 'streak_14', name: 'Fortnight Focus', description: 'Maintain a 14-day streak', emoji: '🛡️', category: 'Streaks', target: 14),
    const AchievementModel(id: 'streak_30', name: 'Monthly Master', description: 'Maintain a 30-day streak', emoji: '🏆', category: 'Streaks', target: 30),
    // Special
    const AchievementModel(id: 'rare_rune', name: 'Rare Find', description: 'Collect a Rare rune', emoji: '💎', category: 'Special', target: 1),
    const AchievementModel(id: 'epic_rune', name: 'Epic Discovery', description: 'Collect an Epic rune', emoji: '🌌', category: 'Special', target: 1),
    const AchievementModel(id: 'legendary_rune', name: 'Legendary Seeker', description: 'Collect a Legendary rune', emoji: '⭐', category: 'Special', target: 1),
    const AchievementModel(id: 'upgrade_5', name: 'Power Up', description: 'Upgrade runes 5 times', emoji: '⬆️', category: 'Special', target: 5),
    const AchievementModel(id: 'upgrade_20', name: 'Master Upgrader', description: 'Upgrade runes 20 times', emoji: '🚀', category: 'Special', target: 20),
    const AchievementModel(id: 'level_5', name: 'Rising Star', description: 'Reach level 5', emoji: '🌠', category: 'Special', target: 5),
    const AchievementModel(id: 'level_10', name: 'Legendary Runesmith', description: 'Reach level 10', emoji: '🏅', category: 'Special', target: 10),
  ];
}
