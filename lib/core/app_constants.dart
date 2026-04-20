class AppConstants {
  AppConstants._();

  static const String appName = 'Rune Forge';
  static const String appTagline = 'Forge Your Destiny, One Rune at a Time';

  // Timing
  static const Duration runeDropInterval = Duration(hours: 1);
  static const Duration splashDuration = Duration(seconds: 5);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 400);
  static const Duration animationSlow = Duration(milliseconds: 800);
  static const Duration animationVerySlow = Duration(milliseconds: 1200);

  // Gamification
  static const int baseXpPerRune = 10;
  static const int xpPerSpell = 25;
  static const int xpPerUpgrade = 15;
  static const int xpPerDailyLogin = 5;
  static const int maxEnergy = 100;
  static const int energyPerUpgrade = 20;
  static const int energyRecoveryPerHour = 10;
  static const int maxTowerFloors = 10;

  // Levels
  static const List<String> levelTitles = [
    'Apprentice',
    'Rune Seeker',
    'Rune Scholar',
    'Tower Builder',
    'Spell Weaver',
    'Rune Master',
    'Arcane Sage',
    'Tower Keeper',
    'Grand Forgemaster',
    'Legendary Runesmith',
  ];

  static int xpForLevel(int level) => level * 100;

  static String levelTitle(int level) {
    if (level < 1) return levelTitles.first;
    if (level > levelTitles.length) return levelTitles.last;
    return levelTitles[level - 1];
  }
}
