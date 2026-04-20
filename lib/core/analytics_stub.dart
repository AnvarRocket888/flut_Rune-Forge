/// ─────────────────────────────────────────────────────────
/// Analytics Stub — Replace with AppsFlyer SDK in future
/// ─────────────────────────────────────────────────────────
/// See additional info/TODO.md for integration details.
/// ─────────────────────────────────────────────────────────
class AnalyticsStub {
  AnalyticsStub._();

  static void logEvent(String name, [Map<String, dynamic>? params]) {
    // TODO: Replace with AppsFlyer SDK call
    // AppsFlyerSdk.logEvent(name, params);
  }

  static void appOpen() => logEvent('app_open');

  static void runeCollected(String runeId, String rarity) =>
      logEvent('rune_collected', {'rune_id': runeId, 'rarity': rarity});

  static void runeUpgraded(String runeId, int newLevel) =>
      logEvent('rune_upgraded', {'rune_id': runeId, 'level': newLevel});

  static void spellCreated(String spellId) =>
      logEvent('spell_created', {'spell_id': spellId});

  static void spellActivated(String spellId) =>
      logEvent('spell_activated', {'spell_id': spellId});

  static void levelUp(int newLevel, String title) =>
      logEvent('level_up', {'level': newLevel, 'title': title});

  static void achievementUnlocked(String achievementId) =>
      logEvent('achievement_unlocked', {'achievement_id': achievementId});

  static void trophyEarned(String trophyId) =>
      logEvent('trophy_earned', {'trophy_id': trophyId});

  static void towerFloorUnlocked(int floor) =>
      logEvent('tower_floor_unlocked', {'floor': floor});

  static void energySpent(int amount, String reason) =>
      logEvent('energy_spent', {'amount': amount, 'reason': reason});

  static void photoConfirmation(String objectType) =>
      logEvent('photo_confirmation', {'object_type': objectType});

  static void settingsChanged(String key, String value) =>
      logEvent('settings_changed', {'key': key, 'value': value});

  static void profileUpdated() => logEvent('profile_updated');

  static void screenView(String screenName) =>
      logEvent('screen_view', {'screen': screenName});
}
