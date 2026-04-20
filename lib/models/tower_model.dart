import 'dart:convert';

class TowerFloor {
  final int floor;
  final String name;
  final String emoji;
  final String description;
  final bool isUnlocked;
  final int runesRequired;
  final int runesPlaced;

  const TowerFloor({
    required this.floor,
    required this.name,
    required this.emoji,
    required this.description,
    this.isUnlocked = false,
    required this.runesRequired,
    this.runesPlaced = 0,
  });

  double get progress => runesRequired > 0 ? runesPlaced / runesRequired : 0;
  bool get isComplete => runesPlaced >= runesRequired;

  TowerFloor copyWith({bool? isUnlocked, int? runesPlaced}) {
    return TowerFloor(
      floor: floor,
      name: name,
      emoji: emoji,
      description: description,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      runesRequired: runesRequired,
      runesPlaced: runesPlaced ?? this.runesPlaced,
    );
  }

  Map<String, dynamic> toJson() => {
    'floor': floor,
    'name': name,
    'emoji': emoji,
    'description': description,
    'isUnlocked': isUnlocked,
    'runesRequired': runesRequired,
    'runesPlaced': runesPlaced,
  };

  factory TowerFloor.fromJson(Map<String, dynamic> json) => TowerFloor(
    floor: json['floor'] as int,
    name: json['name'] as String,
    emoji: json['emoji'] as String,
    description: json['description'] as String,
    isUnlocked: json['isUnlocked'] as bool? ?? false,
    runesRequired: json['runesRequired'] as int,
    runesPlaced: json['runesPlaced'] as int? ?? 0,
  );

  static String encodeList(List<TowerFloor> floors) =>
      jsonEncode(floors.map((f) => f.toJson()).toList());

  static List<TowerFloor> decodeList(String data) {
    final list = jsonDecode(data) as List;
    return list.map((e) => TowerFloor.fromJson(e as Map<String, dynamic>)).toList();
  }

  static List<TowerFloor> defaultFloors() => [
    const TowerFloor(floor: 1, name: 'Foundation', emoji: '🏗️', description: 'The base of your tower. Begin your journey.', isUnlocked: true, runesRequired: 3),
    const TowerFloor(floor: 2, name: 'Fire Chamber', emoji: '🔥', description: 'Channel the flames. Forge runes of power.', runesRequired: 5),
    const TowerFloor(floor: 3, name: 'Water Shrine', emoji: '💧', description: 'Calm waters hold deep secrets.', runesRequired: 7),
    const TowerFloor(floor: 4, name: 'Earth Hall', emoji: '🌍', description: 'Solid ground beneath ancient runes.', runesRequired: 10),
    const TowerFloor(floor: 5, name: 'Wind Terrace', emoji: '💨', description: 'High winds carry whispers of power.', runesRequired: 12),
    const TowerFloor(floor: 6, name: 'Spirit Sanctum', emoji: '✨', description: 'The veil between worlds grows thin.', runesRequired: 15),
    const TowerFloor(floor: 7, name: 'Arcane Library', emoji: '📚', description: 'Knowledge of forgotten spells awaits.', runesRequired: 18),
    const TowerFloor(floor: 8, name: 'Crystal Observatory', emoji: '🔮', description: 'See beyond the ordinary.', runesRequired: 22),
    const TowerFloor(floor: 9, name: 'Dragon Roost', emoji: '🐉', description: 'Only the worthy reach this height.', runesRequired: 27),
    const TowerFloor(floor: 10, name: 'Crown of Stars', emoji: '👑', description: 'The pinnacle. Master of all runes.', runesRequired: 35),
  ];
}
