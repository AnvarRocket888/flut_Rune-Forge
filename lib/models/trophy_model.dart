import 'dart:convert';

class TrophyModel {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final String tier; // bronze, silver, gold, platinum
  final bool isEarned;
  final DateTime? earnedAt;

  const TrophyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.tier,
    this.isEarned = false,
    this.earnedAt,
  });

  TrophyModel copyWith({bool? isEarned, DateTime? earnedAt}) {
    return TrophyModel(
      id: id,
      name: name,
      description: description,
      emoji: emoji,
      tier: tier,
      isEarned: isEarned ?? this.isEarned,
      earnedAt: earnedAt ?? this.earnedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'emoji': emoji,
    'tier': tier,
    'isEarned': isEarned,
    'earnedAt': earnedAt?.toIso8601String(),
  };

  factory TrophyModel.fromJson(Map<String, dynamic> json) => TrophyModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    emoji: json['emoji'] as String,
    tier: json['tier'] as String,
    isEarned: json['isEarned'] as bool? ?? false,
    earnedAt: json['earnedAt'] != null ? DateTime.parse(json['earnedAt'] as String) : null,
  );

  static String encodeList(List<TrophyModel> list) =>
      jsonEncode(list.map((t) => t.toJson()).toList());

  static List<TrophyModel> decodeList(String data) {
    final l = jsonDecode(data) as List;
    return l.map((e) => TrophyModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static List<TrophyModel> defaults() => [
    const TrophyModel(id: 'first_steps', name: 'First Steps', description: 'Begin your journey in the Rune Forge', emoji: '👣', tier: 'bronze'),
    const TrophyModel(id: 'fire_starter', name: 'Fire Starter', description: 'Collect 5 Fire runes', emoji: '🔥', tier: 'bronze'),
    const TrophyModel(id: 'water_bearer', name: 'Water Bearer', description: 'Collect 5 Water runes', emoji: '💧', tier: 'bronze'),
    const TrophyModel(id: 'earth_shaker', name: 'Earth Shaker', description: 'Collect 5 Earth runes', emoji: '🌍', tier: 'bronze'),
    const TrophyModel(id: 'wind_walker', name: 'Wind Walker', description: 'Collect 5 Air runes', emoji: '💨', tier: 'bronze'),
    const TrophyModel(id: 'spirit_seer', name: 'Spirit Seer', description: 'Collect 5 Spirit runes', emoji: '✨', tier: 'silver'),
    const TrophyModel(id: 'tower_initiate', name: 'Tower Initiate', description: 'Complete 3 tower floors', emoji: '🏰', tier: 'silver'),
    const TrophyModel(id: 'spell_scholar', name: 'Spell Scholar', description: 'Discover 10 unique spells', emoji: '📖', tier: 'silver'),
    const TrophyModel(id: 'dedication', name: 'Dedication', description: 'Log in for 30 consecutive days', emoji: '📅', tier: 'gold'),
    const TrophyModel(id: 'rune_sage', name: 'Rune Sage', description: 'Reach level 8', emoji: '🧙‍♂️', tier: 'gold'),
    const TrophyModel(id: 'tower_master', name: 'Tower Master', description: 'Complete the entire tower', emoji: '🗼', tier: 'gold'),
    const TrophyModel(id: 'legendary_collector', name: 'Legendary Collector', description: 'Collect 5 Legendary runes', emoji: '💫', tier: 'platinum'),
    const TrophyModel(id: 'grand_forgemaster', name: 'Grand Forgemaster', description: 'Reach level 10 and complete the tower', emoji: '⚒️', tier: 'platinum'),
    const TrophyModel(id: 'completionist', name: 'Completionist', description: 'Unlock all achievements', emoji: '🏆', tier: 'platinum'),
  ];
}
