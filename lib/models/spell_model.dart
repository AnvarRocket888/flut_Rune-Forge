import 'dart:convert';

class SpellModel {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final List<String> runeIds;
  final String effect;
  final DateTime createdAt;
  final bool isActive;

  const SpellModel({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.runeIds,
    required this.effect,
    required this.createdAt,
    this.isActive = true,
  });

  SpellModel copyWith({bool? isActive}) {
    return SpellModel(
      id: id,
      name: name,
      description: description,
      emoji: emoji,
      runeIds: runeIds,
      effect: effect,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'emoji': emoji,
    'runeIds': runeIds,
    'effect': effect,
    'createdAt': createdAt.toIso8601String(),
    'isActive': isActive,
  };

  factory SpellModel.fromJson(Map<String, dynamic> json) => SpellModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    emoji: json['emoji'] as String,
    runeIds: List<String>.from(json['runeIds'] as List),
    effect: json['effect'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    isActive: json['isActive'] as bool? ?? true,
  );

  static String encodeList(List<SpellModel> spells) =>
      jsonEncode(spells.map((s) => s.toJson()).toList());

  static List<SpellModel> decodeList(String data) {
    final list = jsonDecode(data) as List;
    return list.map((e) => SpellModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
