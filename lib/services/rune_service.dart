import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/rune_model.dart';

class RuneService {
  static const _uuid = Uuid();
  static final _random = Random();

  static final List<_RuneTemplate> _templates = [
    // Fire
    _RuneTemplate('Ignis', 'Spark of productivity', 'Born from the first flame of creation, Ignis fuels your inner fire.', RuneElement.fire, '🔥', 'Boost focus for 30 min'),
    _RuneTemplate('Ember', 'Warm glow of motivation', 'A gentle ember that refuses to die, keeping hope alive.', RuneElement.fire, '🌋', 'Increase task completion rate'),
    _RuneTemplate('Blaze', 'Burning determination', 'The fierce blaze that cuts through darkness and doubt.', RuneElement.fire, '☀️', 'Double XP for 1 hour'),
    _RuneTemplate('Inferno', 'Unstoppable energy', 'An inferno of pure willpower, nothing can stand in its way.', RuneElement.fire, '💥', 'Triple streak bonus'),
    _RuneTemplate('Phoenix', 'Rebirth and renewal', 'Rise from the ashes, stronger than before.', RuneElement.fire, '🦅', 'Reset streak without losing XP'),

    // Water
    _RuneTemplate('Aqua', 'Flow of calm', 'Crystal clear waters that wash away stress.', RuneElement.water, '💧', 'Remind to drink water'),
    _RuneTemplate('Tide', 'Rhythm of life', 'The eternal push and pull of the tides guide your rhythm.', RuneElement.water, '🌊', 'Set break reminders'),
    _RuneTemplate('Frost', 'Cool composure', 'Ice-cold clarity in moments of chaos.', RuneElement.water, '❄️', 'Calm breathing exercise'),
    _RuneTemplate('Mist', 'Subtle intuition', 'The mist reveals what clear sight cannot.', RuneElement.water, '🌫️', 'Mood tracking boost'),
    _RuneTemplate('Torrent', 'Overwhelming power', 'An unstoppable force of nature unleashed.', RuneElement.water, '🏊', 'Full energy recovery'),

    // Earth
    _RuneTemplate('Terra', 'Grounded stability', 'The solid earth beneath your feet gives strength.', RuneElement.earth, '🪨', 'Posture reminder'),
    _RuneTemplate('Root', 'Deep connection', 'Ancient roots that connect to the world\'s core.', RuneElement.earth, '🌿', 'Nature walk reminder'),
    _RuneTemplate('Crystal', 'Clarity of mind', 'A perfect crystal that amplifies thought.', RuneElement.earth, '💎', 'Clear mind meditation'),
    _RuneTemplate('Mountain', 'Immovable resolve', 'Like a mountain, you cannot be moved.', RuneElement.earth, '⛰️', 'Willpower boost'),
    _RuneTemplate('Seed', 'Growth potential', 'A tiny seed that holds infinite possibility.', RuneElement.earth, '🌱', 'Start a new habit'),

    // Air
    _RuneTemplate('Zephyr', 'Gentle breeze', 'A soft wind that carries away worries.', RuneElement.air, '🍃', 'Deep breathing prompt'),
    _RuneTemplate('Gale', 'Swift action', 'The howling gale that clears the path ahead.', RuneElement.air, '💨', 'Speed up current task'),
    _RuneTemplate('Storm', 'Raw power', 'Thunder and lightning bend to your will.', RuneElement.air, '⚡', 'Burst of energy'),
    _RuneTemplate('Whisper', 'Quiet wisdom', 'Listen carefully — the wind has secrets.', RuneElement.air, '🎐', 'Reflection prompt'),
    _RuneTemplate('Cyclone', 'Controlled chaos', 'Harness the chaos, direct it with purpose.', RuneElement.air, '🌪️', 'Multi-task boost'),

    // Spirit
    _RuneTemplate('Aether', 'Pure essence', 'The fifth element, connecting all things.', RuneElement.spirit, '✨', 'Universal bonus'),
    _RuneTemplate('Luna', 'Moonlit insight', 'Under the moon, all truths are revealed.', RuneElement.spirit, '🌙', 'Night routine helper'),
    _RuneTemplate('Sol', 'Solar vitality', 'The sun\'s energy infuses every cell.', RuneElement.spirit, '☀️', 'Morning routine helper'),
    _RuneTemplate('Nova', 'Explosive potential', 'A star about to be born, pure potential energy.', RuneElement.spirit, '💫', 'Random bonus event'),
    _RuneTemplate('Void', 'Infinite possibility', 'In the void, all things are possible.', RuneElement.spirit, '🕳️', 'Unlock hidden features'),
  ];

  static RuneModel generateRune() {
    final template = _templates[_random.nextInt(_templates.length)];
    final rarity = _rollRarity();

    return RuneModel(
      id: _uuid.v4(),
      name: template.name,
      description: template.description,
      lore: template.lore,
      element: template.element,
      rarity: rarity,
      emoji: template.emoji,
      passiveBonus: template.bonus,
      collectedAt: DateTime.now(),
    );
  }

  static RuneRarity _rollRarity() {
    final roll = _random.nextInt(100);
    if (roll < 50) return RuneRarity.common;
    if (roll < 80) return RuneRarity.rare;
    if (roll < 95) return RuneRarity.epic;
    return RuneRarity.legendary;
  }

  static RuneModel upgradeRune(RuneModel rune) {
    return rune.copyWith(level: rune.level + 1);
  }
}

class _RuneTemplate {
  final String name;
  final String description;
  final String lore;
  final RuneElement element;
  final String emoji;
  final String bonus;

  const _RuneTemplate(this.name, this.description, this.lore, this.element, this.emoji, this.bonus);
}
