import 'package:uuid/uuid.dart';
import '../models/rune_model.dart';
import '../models/spell_model.dart';

class SpellService {
  static const _uuid = Uuid();

  static final List<_SpellRecipe> _recipes = [
    // Fire + Water
    _SpellRecipe([RuneElement.fire, RuneElement.water], 'Steam Shield', 'A protective barrier of steam', '🛡️', 'Damage reflection aura'),
    // Fire + Earth
    _SpellRecipe([RuneElement.fire, RuneElement.earth], 'Magma Forge', 'Melt and reshape reality', '🌋', 'Craft bonus multiplier'),
    // Fire + Air
    _SpellRecipe([RuneElement.fire, RuneElement.air], 'Firestorm', 'A devastating whirlwind of flame', '🔥', 'XP storm — bonus XP burst'),
    // Fire + Spirit
    _SpellRecipe([RuneElement.fire, RuneElement.spirit], 'Phoenix Rise', 'Rebirth from flame and spirit', '🦅', 'Second chance on failed tasks'),
    // Water + Earth
    _SpellRecipe([RuneElement.water, RuneElement.earth], 'Growth Surge', 'Water feeds the earth, life blooms', '🌺', 'Accelerate habit growth'),
    // Water + Air
    _SpellRecipe([RuneElement.water, RuneElement.air], 'Rain Dance', 'Summon cleansing rain', '🌧️', 'Stress relief meditation'),
    // Water + Spirit
    _SpellRecipe([RuneElement.water, RuneElement.spirit], 'Dream Tide', 'Navigate the currents of dreams', '🌌', 'Enhanced sleep tracking'),
    // Earth + Air
    _SpellRecipe([RuneElement.earth, RuneElement.air], 'Dust Devil', 'Earth rises on the wind', '🌪️', 'Clear old tasks quickly'),
    // Earth + Spirit
    _SpellRecipe([RuneElement.earth, RuneElement.spirit], 'Ancient Roots', 'Deep spiritual grounding', '🌳', 'Deep focus meditation'),
    // Air + Spirit
    _SpellRecipe([RuneElement.air, RuneElement.spirit], 'Astral Wind', 'Travel beyond the physical', '💫', 'Unlock hidden achievements'),
    // Triple combos
    _SpellRecipe([RuneElement.fire, RuneElement.water, RuneElement.earth], 'Primordial Soup', 'The building blocks of creation', '🧬', 'Generate a random rare rune'),
    _SpellRecipe([RuneElement.water, RuneElement.air, RuneElement.spirit], 'Ethereal Wave', 'A wave from another dimension', '🌊', 'Full energy refill'),
    _SpellRecipe([RuneElement.fire, RuneElement.earth, RuneElement.spirit], 'Core Flame', 'The fire at the world\'s heart', '❤️‍🔥', 'Permanent XP bonus'),
    _SpellRecipe([RuneElement.fire, RuneElement.air, RuneElement.spirit], 'Solar Flare', 'Harness the power of a star', '☀️', 'Mega XP boost'),
    _SpellRecipe([RuneElement.earth, RuneElement.air, RuneElement.water], 'Nature\'s Balance', 'Perfect harmony of elements', '☯️', 'All stats balanced'),
  ];

  static SpellModel? tryForge(List<RuneModel> selectedRunes) {
    if (selectedRunes.length < 2) return null;

    final elements = selectedRunes.map((r) => r.element).toSet();

    for (final recipe in _recipes) {
      final recipeElements = recipe.elements.toSet();
      if (elements.length == recipeElements.length &&
          elements.containsAll(recipeElements)) {
        return SpellModel(
          id: _uuid.v4(),
          name: recipe.name,
          description: recipe.description,
          emoji: recipe.emoji,
          runeIds: selectedRunes.map((r) => r.id).toList(),
          effect: recipe.effect,
          createdAt: DateTime.now(),
        );
      }
    }

    // If no recipe matches, create a custom spell
    return SpellModel(
      id: _uuid.v4(),
      name: 'Custom Spell',
      description: 'A unique combination of runes',
      emoji: '🔮',
      runeIds: selectedRunes.map((r) => r.id).toList(),
      effect: 'Mystery effect',
      createdAt: DateTime.now(),
    );
  }

  static List<_SpellRecipe> get allRecipes => _recipes;
}

class _SpellRecipe {
  final List<RuneElement> elements;
  final String name;
  final String description;
  final String emoji;
  final String effect;

  const _SpellRecipe(this.elements, this.name, this.description, this.emoji, this.effect);
}
