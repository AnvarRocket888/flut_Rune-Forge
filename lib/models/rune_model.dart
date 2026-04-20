import 'dart:convert';

enum RuneElement { fire, water, earth, air, spirit }

enum RuneRarity { common, rare, epic, legendary }

class RuneModel {
  final String id;
  final String name;
  final String description;
  final String lore;
  final RuneElement element;
  final RuneRarity rarity;
  final String emoji;
  final int level;
  final String passiveBonus;
  final DateTime collectedAt;
  final bool isActive;

  const RuneModel({
    required this.id,
    required this.name,
    required this.description,
    required this.lore,
    required this.element,
    required this.rarity,
    required this.emoji,
    this.level = 1,
    required this.passiveBonus,
    required this.collectedAt,
    this.isActive = false,
  });

  int get upgradeCost => level * 20;

  String get rarityLabel {
    switch (rarity) {
      case RuneRarity.common:
        return 'Common';
      case RuneRarity.rare:
        return 'Rare';
      case RuneRarity.epic:
        return 'Epic';
      case RuneRarity.legendary:
        return 'Legendary';
    }
  }

  String get elementLabel {
    switch (element) {
      case RuneElement.fire:
        return 'Fire';
      case RuneElement.water:
        return 'Water';
      case RuneElement.earth:
        return 'Earth';
      case RuneElement.air:
        return 'Air';
      case RuneElement.spirit:
        return 'Spirit';
    }
  }

  String get elementEmoji {
    switch (element) {
      case RuneElement.fire:
        return '🔥';
      case RuneElement.water:
        return '💧';
      case RuneElement.earth:
        return '🌍';
      case RuneElement.air:
        return '💨';
      case RuneElement.spirit:
        return '✨';
    }
  }

  RuneModel copyWith({
    int? level,
    bool? isActive,
  }) {
    return RuneModel(
      id: id,
      name: name,
      description: description,
      lore: lore,
      element: element,
      rarity: rarity,
      emoji: emoji,
      level: level ?? this.level,
      passiveBonus: passiveBonus,
      collectedAt: collectedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'lore': lore,
    'element': element.index,
    'rarity': rarity.index,
    'emoji': emoji,
    'level': level,
    'passiveBonus': passiveBonus,
    'collectedAt': collectedAt.toIso8601String(),
    'isActive': isActive,
  };

  factory RuneModel.fromJson(Map<String, dynamic> json) => RuneModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    lore: json['lore'] as String,
    element: RuneElement.values[json['element'] as int],
    rarity: RuneRarity.values[json['rarity'] as int],
    emoji: json['emoji'] as String,
    level: json['level'] as int? ?? 1,
    passiveBonus: json['passiveBonus'] as String,
    collectedAt: DateTime.parse(json['collectedAt'] as String),
    isActive: json['isActive'] as bool? ?? false,
  );

  static String encodeList(List<RuneModel> runes) =>
      jsonEncode(runes.map((r) => r.toJson()).toList());

  static List<RuneModel> decodeList(String data) {
    final list = jsonDecode(data) as List;
    return list.map((e) => RuneModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
