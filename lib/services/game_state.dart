import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/rune_model.dart';
import '../models/spell_model.dart';
import '../models/tower_model.dart';
import '../models/achievement_model.dart';
import '../models/trophy_model.dart';
import '../models/user_profile.dart';
import '../core/app_constants.dart';
import '../core/analytics_stub.dart';
import 'storage_service.dart';
import 'rune_service.dart';
import 'spell_service.dart';

class GameState extends ChangeNotifier {
  UserProfile _profile = const UserProfile();
  List<RuneModel> _runes = [];
  List<SpellModel> _spells = [];
  List<TowerFloor> _towerFloors = TowerFloor.defaultFloors();
  List<AchievementModel> _achievements = AchievementModel.defaults();
  List<TrophyModel> _trophies = TrophyModel.defaults();
  DateTime? _lastRuneDrop;
  String? _newlyUnlockedAchievement;
  String? _newlyEarnedTrophy;
  bool _leveledUp = false;
  int _previousLevel = 1;

  UserProfile get profile => _profile;
  List<RuneModel> get runes => _runes;
  List<SpellModel> get spells => _spells;
  List<TowerFloor> get towerFloors => _towerFloors;
  List<AchievementModel> get achievements => _achievements;
  List<TrophyModel> get trophies => _trophies;
  DateTime? get lastRuneDrop => _lastRuneDrop;

  String? consumeNewAchievement() {
    final a = _newlyUnlockedAchievement;
    _newlyUnlockedAchievement = null;
    return a;
  }

  String? consumeNewTrophy() {
    final t = _newlyEarnedTrophy;
    _newlyEarnedTrophy = null;
    return t;
  }

  bool consumeLevelUp() {
    final l = _leveledUp;
    _leveledUp = false;
    return l;
  }

  int get previousLevel => _previousLevel;

  // Derived
  int get unlockedFloors => _towerFloors.where((f) => f.isUnlocked).length;
  int get completedFloors => _towerFloors.where((f) => f.isComplete).length;
  int get totalRunes => _runes.length;
  int get activeSpells => _spells.where((s) => s.isActive).length;
  int get unlockedAchievements => _achievements.where((a) => a.isUnlocked).length;
  int get earnedTrophies => _trophies.where((t) => t.isEarned).length;
  bool get canDropRune {
    if (_lastRuneDrop == null) return true;
    return DateTime.now().difference(_lastRuneDrop!) >= AppConstants.runeDropInterval;
  }

  Duration get timeUntilNextDrop {
    if (_lastRuneDrop == null) return Duration.zero;
    final next = _lastRuneDrop!.add(AppConstants.runeDropInterval);
    final diff = next.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  List<String> get dailyMotivation {
    final quotes = [
      '"The runes speak to those who listen." — Ancient Proverb',
      '"Every tower begins with a single stone." — Tower Proverb',
      '"Forge your destiny, one rune at a time."',
      '"In the forge, weakness becomes strength."',
      '"The tallest tower was once just a dream."',
      '"Runes are whispers of power waiting to be heard."',
      '"Patience builds towers; haste crumbles them."',
      '"A runesmith\'s greatest tool is persistence."',
      '"The fire that tempers steel also lights the way."',
      '"Power not yet mastered is still power." — Elder Scroll',
      '"To carve a rune is to carve your will into the world."',
      '"The forge does not judge — it only reveals."',
      '"A single rune, placed with intent, can move mountains."',
      '"Wisdom is the rarest rune of all."',
      '"Do not rush the forge. Rushed steel shatters."',
      '"Every failure in the forge is a lesson etched in iron."',
      '"The strongest spells are born from silence and patience."',
      '"Your tower is a monument to every attempt you refused to abandon."',
      '"Ancient runes carry the voices of those who dared first."',
      '"Let the omen guide your hand, not your fear."',
      '"The sky is not the ceiling — it is the floor of heaven."',
      '"Even frost has fire in its heart, if you look close enough."',
      '"There is no unworthy rune. Only unready hands."',
      '"The night sky is filled with runes no one has yet learned to read."',
      '"Iron bends before it breaks — so must the spirit."',
      '"A master runesmith forged their first rune in darkness."',
      '"The tower does not sway with the wind — it learns from it."',
      '"Time is the most powerful rune. Spend it wisely."',
      '"Light seeks the crack in the armor — and so does growth."',
      '"What you name with a rune, you begin to summon."',
      '"The loudest thunder leaves the clearest sky."',
      '"Seek the rune you fear most — there lies your greatest power."',
      '"Every layer of the tower is a promise kept to yourself."',
      '"The forge remembers every hand that has shaped it."',
      '"To know one rune deeply is worth more than a dozen known lightly."',
      '"Stars are ancient runes — written before the first runesmith drew breath."',
      '"Walk slowly through the forge. The best work cannot be hurried."',
      '"The coldest stone holds the hottest fire inside it."',
      '"What you build today becomes the foundation of who you are tomorrow."',
      '"Silence between the runes is where their meaning lives."',
    ];
    return quotes;
  }

  String get randomQuote {
    final quotes = dailyMotivation;
    return quotes[Random().nextInt(quotes.length)];
  }

  // ── Initialization ────────────────────────────────────────

  Future<void> loadState() async {
    // Profile
    final profileData = StorageService.getString(StorageService.kProfile);
    if (profileData != null) {
      _profile = UserProfile.decode(profileData);
    }

    // Runes
    final runesData = StorageService.getString(StorageService.kRunes);
    if (runesData != null) {
      _runes = RuneModel.decodeList(runesData);
    }

    // Spells
    final spellsData = StorageService.getString(StorageService.kSpells);
    if (spellsData != null) {
      _spells = SpellModel.decodeList(spellsData);
    }

    // Tower
    final towerData = StorageService.getString(StorageService.kTower);
    if (towerData != null) {
      _towerFloors = TowerFloor.decodeList(towerData);
    }

    // Achievements
    final achData = StorageService.getString(StorageService.kAchievements);
    if (achData != null) {
      _achievements = AchievementModel.decodeList(achData);
    }

    // Trophies
    final tropData = StorageService.getString(StorageService.kTrophies);
    if (tropData != null) {
      _trophies = TrophyModel.decodeList(tropData);
    }

    // Last rune drop
    final lastDrop = StorageService.getString(StorageService.kLastRuneDrop);
    if (lastDrop != null) {
      _lastRuneDrop = DateTime.parse(lastDrop);
    }

    // Update streak
    _updateStreak();

    // Recover energy
    _recoverEnergy();

    notifyListeners();
  }

  // ── Save ──────────────────────────────────────────────────

  Future<void> _save() async {
    await StorageService.setString(StorageService.kProfile, _profile.encode());
    await StorageService.setString(StorageService.kRunes, RuneModel.encodeList(_runes));
    await StorageService.setString(StorageService.kSpells, SpellModel.encodeList(_spells));
    await StorageService.setString(StorageService.kTower, TowerFloor.encodeList(_towerFloors));
    await StorageService.setString(StorageService.kAchievements, AchievementModel.encodeList(_achievements));
    await StorageService.setString(StorageService.kTrophies, TrophyModel.encodeList(_trophies));
    if (_lastRuneDrop != null) {
      await StorageService.setString(StorageService.kLastRuneDrop, _lastRuneDrop!.toIso8601String());
    }
  }

  // ── Rune Actions ──────────────────────────────────────────

  RuneModel? collectRune() {
    if (!canDropRune) return null;

    final rune = RuneService.generateRune();
    _runes.add(rune);
    _lastRuneDrop = DateTime.now();
    _addXp(AppConstants.baseXpPerRune);
    _profile = _profile.copyWith(totalRunesCollected: _profile.totalRunesCollected + 1);

    AnalyticsStub.runeCollected(rune.id, rune.rarityLabel);

    _checkRuneAchievements(rune);
    _checkRuneTrophies();
    _updateTowerProgress();
    _save();
    notifyListeners();
    return rune;
  }

  void addSpecificRune(RuneModel rune) {
    _runes.add(rune);
    _addXp(AppConstants.baseXpPerRune);
    _profile = _profile.copyWith(totalRunesCollected: _profile.totalRunesCollected + 1);
    _checkRuneAchievements(rune);
    _checkRuneTrophies();
    _updateTowerProgress();
    _save();
    notifyListeners();
  }

  bool upgradeRune(String runeId) {
    final idx = _runes.indexWhere((r) => r.id == runeId);
    if (idx == -1) return false;

    final rune = _runes[idx];
    if (_profile.energy < rune.upgradeCost) return false;

    _profile = _profile.copyWith(
      energy: _profile.energy - rune.upgradeCost,
      totalUpgrades: _profile.totalUpgrades + 1,
    );
    _runes[idx] = RuneService.upgradeRune(rune);
    _addXp(AppConstants.xpPerUpgrade);

    AnalyticsStub.runeUpgraded(runeId, _runes[idx].level);
    AnalyticsStub.energySpent(rune.upgradeCost, 'upgrade');

    _checkUpgradeAchievements();
    _save();
    notifyListeners();
    return true;
  }

  void toggleRuneActive(String runeId) {
    final idx = _runes.indexWhere((r) => r.id == runeId);
    if (idx == -1) return;
    _runes[idx] = _runes[idx].copyWith(isActive: !_runes[idx].isActive);
    _save();
    notifyListeners();
  }

  // ── Spell Actions ─────────────────────────────────────────

  SpellModel? forgeSpell(List<RuneModel> selectedRunes) {
    final spell = SpellService.tryForge(selectedRunes);
    if (spell == null) return null;

    _spells.add(spell);
    _addXp(AppConstants.xpPerSpell);
    _profile = _profile.copyWith(totalSpellsCreated: _profile.totalSpellsCreated + 1);

    AnalyticsStub.spellCreated(spell.id);

    _checkSpellAchievements();
    _checkSpellTrophies();
    _save();
    notifyListeners();
    return spell;
  }

  void toggleSpell(String spellId) {
    final idx = _spells.indexWhere((s) => s.id == spellId);
    if (idx == -1) return;
    _spells[idx] = _spells[idx].copyWith(isActive: !_spells[idx].isActive);
    if (_spells[idx].isActive) {
      AnalyticsStub.spellActivated(spellId);
    }
    _save();
    notifyListeners();
  }

  void deleteSpell(String spellId) {
    _spells.removeWhere((s) => s.id == spellId);
    _save();
    notifyListeners();
  }

  // ── Profile ───────────────────────────────────────────────

  void updateName(String name) {
    _profile = _profile.copyWith(name: name);
    AnalyticsStub.profileUpdated();
    _save();
    notifyListeners();
  }

  void updateAvatar(String? path) {
    _profile = path == null
        ? _profile.copyWith(clearAvatarPath: true)
        : _profile.copyWith(avatarPath: path);
    _save();
    notifyListeners();
  }

  void updateWisdomRecording(String? path) {
    _profile = path == null
        ? _profile.copyWith(clearWisdomRecordingPath: true)
        : _profile.copyWith(wisdomRecordingPath: path);
    _save();
    notifyListeners();
  }

  // ── XP & Levels ───────────────────────────────────────────

  void _addXp(int amount) {
    _previousLevel = _profile.level;
    int newXp = _profile.xp + amount;
    int newLevel = _profile.level;

    while (newXp >= _totalXpForLevel(newLevel)) {
      newLevel++;
    }

    if (newLevel > _profile.level) {
      _leveledUp = true;
      AnalyticsStub.levelUp(newLevel, AppConstants.levelTitle(newLevel));
      _checkLevelAchievements(newLevel);
      _checkLevelTrophies(newLevel);
    }

    _profile = _profile.copyWith(xp: newXp, level: newLevel);
  }

  int _totalXpForLevel(int lvl) {
    int total = 0;
    for (int i = 1; i <= lvl; i++) {
      total += i * 100;
    }
    return total;
  }

  // ── Streak ────────────────────────────────────────────────

  void _updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_profile.lastActiveDate != null) {
      final lastActive = DateTime(
        _profile.lastActiveDate!.year,
        _profile.lastActiveDate!.month,
        _profile.lastActiveDate!.day,
      );
      final diff = today.difference(lastActive).inDays;

      if (diff == 1) {
        // Consecutive day
        final newStreak = _profile.currentStreak + 1;
        _profile = _profile.copyWith(
          currentStreak: newStreak,
          bestStreak: newStreak > _profile.bestStreak ? newStreak : _profile.bestStreak,
          lastActiveDate: now,
        );
        _addXp(AppConstants.xpPerDailyLogin);
        _checkStreakAchievements(newStreak);
      } else if (diff > 1) {
        // Streak broken
        _profile = _profile.copyWith(
          currentStreak: 1,
          lastActiveDate: now,
        );
        _addXp(AppConstants.xpPerDailyLogin);
      }
      // diff == 0: same day, do nothing
    } else {
      // First time
      _profile = _profile.copyWith(
        currentStreak: 1,
        bestStreak: 1,
        lastActiveDate: now,
      );
      _addXp(AppConstants.xpPerDailyLogin);
    }
  }

  // ── Energy ────────────────────────────────────────────────

  void _recoverEnergy() {
    final lastRecovery = StorageService.getString(StorageService.kLastEnergyRecovery);
    final now = DateTime.now();

    if (lastRecovery != null) {
      final last = DateTime.parse(lastRecovery);
      final hoursPassed = now.difference(last).inHours;
      if (hoursPassed > 0) {
        final recovered = hoursPassed * AppConstants.energyRecoveryPerHour;
        final newEnergy = (_profile.energy + recovered).clamp(0, AppConstants.maxEnergy);
        _profile = _profile.copyWith(energy: newEnergy);
      }
    }

    StorageService.setString(StorageService.kLastEnergyRecovery, now.toIso8601String());
  }

  // ── Tower ─────────────────────────────────────────────────

  void _updateTowerProgress() {
    final totalRunes = _runes.length;
    int runesAllocated = 0;

    for (int i = 0; i < _towerFloors.length; i++) {
      final floor = _towerFloors[i];
      final available = totalRunes - runesAllocated;
      final placed = available.clamp(0, floor.runesRequired);
      final unlocked = i == 0 || _towerFloors[i - 1].isComplete;

      _towerFloors[i] = floor.copyWith(
        runesPlaced: placed,
        isUnlocked: unlocked,
      );

      if (_towerFloors[i].isComplete && !floor.isComplete) {
        AnalyticsStub.towerFloorUnlocked(floor.floor);
        _checkTowerAchievements();
        _checkTowerTrophies();
      }

      runesAllocated += placed;
    }
  }

  // ── Achievement Checks ────────────────────────────────────

  void _checkRuneAchievements(RuneModel rune) {
    _updateAchievement('first_rune', _runes.length);
    _updateAchievement('rune_collector_10', _runes.length);
    _updateAchievement('rune_hoarder_50', _runes.length);
    _updateAchievement('rune_master_100', _runes.length);

    final elements = _runes.map((r) => r.element).toSet();
    _updateAchievement('all_elements', elements.length);

    if (rune.rarity == RuneRarity.rare) _updateAchievement('rare_rune', 1);
    if (rune.rarity == RuneRarity.epic) _updateAchievement('epic_rune', 1);
    if (rune.rarity == RuneRarity.legendary) _updateAchievement('legendary_rune', 1);
  }

  void _checkSpellAchievements() {
    _updateAchievement('first_spell', _spells.length);
    _updateAchievement('spell_5', _spells.length);
    _updateAchievement('spell_master', _spells.length);
  }

  void _checkTowerAchievements() {
    _updateAchievement('floor_1', completedFloors);
    _updateAchievement('floor_5', completedFloors);
    _updateAchievement('floor_10', completedFloors);
  }

  void _checkStreakAchievements(int streak) {
    _updateAchievement('streak_3', streak);
    _updateAchievement('streak_7', streak);
    _updateAchievement('streak_14', streak);
    _updateAchievement('streak_30', streak);
  }

  void _checkUpgradeAchievements() {
    _updateAchievement('upgrade_5', _profile.totalUpgrades);
    _updateAchievement('upgrade_20', _profile.totalUpgrades);
  }

  void _checkLevelAchievements(int level) {
    _updateAchievement('level_5', level);
    _updateAchievement('level_10', level);
  }

  void _updateAchievement(String id, int current) {
    final idx = _achievements.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    final ach = _achievements[idx];
    if (ach.isUnlocked) return;

    final updated = ach.copyWith(current: current);
    if (current >= ach.target) {
      _achievements[idx] = updated.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      _newlyUnlockedAchievement = ach.name;
      AnalyticsStub.achievementUnlocked(id);
    } else {
      _achievements[idx] = updated;
    }
  }

  // ── Trophy Checks ─────────────────────────────────────────

  void _checkRuneTrophies() {
    _earnTrophyIf('first_steps', _runes.isNotEmpty);

    final fireCount = _runes.where((r) => r.element == RuneElement.fire).length;
    _earnTrophyIf('fire_starter', fireCount >= 5);

    final waterCount = _runes.where((r) => r.element == RuneElement.water).length;
    _earnTrophyIf('water_bearer', waterCount >= 5);

    final earthCount = _runes.where((r) => r.element == RuneElement.earth).length;
    _earnTrophyIf('earth_shaker', earthCount >= 5);

    final airCount = _runes.where((r) => r.element == RuneElement.air).length;
    _earnTrophyIf('wind_walker', airCount >= 5);

    final spiritCount = _runes.where((r) => r.element == RuneElement.spirit).length;
    _earnTrophyIf('spirit_seer', spiritCount >= 5);

    final legendaryCount = _runes.where((r) => r.rarity == RuneRarity.legendary).length;
    _earnTrophyIf('legendary_collector', legendaryCount >= 5);
  }

  void _checkSpellTrophies() {
    _earnTrophyIf('spell_scholar', _spells.length >= 10);
  }

  void _checkTowerTrophies() {
    _earnTrophyIf('tower_initiate', completedFloors >= 3);
    _earnTrophyIf('tower_master', completedFloors >= 10);
    if (completedFloors >= 10 && _profile.level >= 10) {
      _earnTrophyIf('grand_forgemaster', true);
    }
  }

  void _checkLevelTrophies(int level) {
    _earnTrophyIf('rune_sage', level >= 8);
    if (completedFloors >= 10 && level >= 10) {
      _earnTrophyIf('grand_forgemaster', true);
    }
  }

  void _earnTrophyIf(String id, bool condition) {
    if (!condition) return;
    final idx = _trophies.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    if (_trophies[idx].isEarned) return;

    _trophies[idx] = _trophies[idx].copyWith(
      isEarned: true,
      earnedAt: DateTime.now(),
    );
    _newlyEarnedTrophy = _trophies[idx].name;
    AnalyticsStub.trophyEarned(id);
  }

  void checkCompletionistTrophy() {
    final allUnlocked = _achievements.every((a) => a.isUnlocked);
    _earnTrophyIf('completionist', allUnlocked);
    _save();
    notifyListeners();
  }

  void checkDedicationTrophy() {
    _earnTrophyIf('dedication', _profile.bestStreak >= 30);
    _save();
    notifyListeners();
  }

  void resetAllData() {
    _profile = const UserProfile();
    _runes = [];
    _spells = [];
    _towerFloors = TowerFloor.defaultFloors();
    _achievements = AchievementModel.defaults();
    _trophies = TrophyModel.defaults();
    _lastRuneDrop = null;
    _save();
    notifyListeners();
  }

  // ── Screenshot / Demo mode ────────────────────────────────

  /// Loads rich fake data so every screen looks like the app
  /// has been used for weeks. Does NOT persist to storage.
  void loadDemoState() {
    final rng = Random();
    final now = DateTime.now();

    _profile = UserProfile(
      name: 'Runesmith',
      xp: 4750,
      level: 8,
      energy: 80,
      currentStreak: 23,
      bestStreak: 30,
      lastActiveDate: now,
      totalRunesCollected: 87,
      totalSpellsCreated: 14,
      totalUpgrades: 22,
      dailyChallengesCompleted: [],
    );

    // 87 runes spread across days
    final runeTemplates = [
      ('Ignis', 'Spark of productivity', RuneElement.fire, RuneRarity.epic, '🔥', 'Double XP for 1 hour'),
      ('Phoenix', 'Rebirth and renewal', RuneElement.fire, RuneRarity.legendary, '🦅', 'Reset streak without losing XP'),
      ('Ember', 'Warm glow of motivation', RuneElement.fire, RuneRarity.common, '🌋', 'Increase task completion rate'),
      ('Blaze', 'Burning determination', RuneElement.fire, RuneRarity.rare, '☀️', 'Double XP for 1 hour'),
      ('Inferno', 'Unstoppable energy', RuneElement.fire, RuneRarity.epic, '💥', 'Triple streak bonus'),
      ('Aqua', 'Flow of calm', RuneElement.water, RuneRarity.common, '💧', 'Remind to drink water'),
      ('Tide', 'Rhythm of life', RuneElement.water, RuneRarity.rare, '🌊', 'Set break reminders'),
      ('Frost', 'Cool composure', RuneElement.water, RuneRarity.epic, '❄️', 'Calm breathing exercise'),
      ('Torrent', 'Overwhelming power', RuneElement.water, RuneRarity.legendary, '🏊', 'Full energy recovery'),
      ('Mist', 'Subtle intuition', RuneElement.water, RuneRarity.common, '🌫️', 'Mood tracking boost'),
      ('Terra', 'Grounded stability', RuneElement.earth, RuneRarity.common, '🪨', 'Posture reminder'),
      ('Root', 'Deep connection', RuneElement.earth, RuneRarity.rare, '🌿', 'Nature walk reminder'),
      ('Crystal', 'Clarity of mind', RuneElement.earth, RuneRarity.epic, '💎', 'Clear mind meditation'),
      ('Mountain', 'Immovable resolve', RuneElement.earth, RuneRarity.legendary, '⛰️', 'Willpower boost'),
      ('Seed', 'Growth potential', RuneElement.earth, RuneRarity.common, '🌱', 'Start a new habit'),
      ('Zephyr', 'Gentle breeze', RuneElement.air, RuneRarity.common, '🍃', 'Deep breathing prompt'),
      ('Gale', 'Swift action', RuneElement.air, RuneRarity.rare, '💨', 'Speed up current task'),
      ('Storm', 'Raw power', RuneElement.air, RuneRarity.epic, '⚡', 'Burst of energy'),
      ('Whisper', 'Quiet wisdom', RuneElement.air, RuneRarity.rare, '🎐', 'Reflection prompt'),
      ('Cyclone', 'Controlled chaos', RuneElement.air, RuneRarity.legendary, '🌪️', 'Multi-task boost'),
      ('Aether', 'Pure essence', RuneElement.spirit, RuneRarity.epic, '✨', 'Universal bonus'),
      ('Luna', 'Moonlit insight', RuneElement.spirit, RuneRarity.rare, '🌙', 'Night routine helper'),
      ('Sol', 'Solar vitality', RuneElement.spirit, RuneRarity.epic, '☀️', 'Morning routine helper'),
      ('Nova', 'Explosive potential', RuneElement.spirit, RuneRarity.legendary, '💫', 'Random bonus event'),
      ('Void', 'Infinite possibility', RuneElement.spirit, RuneRarity.legendary, '🕳️', 'Unlock hidden features'),
    ];

    _runes = List.generate(87, (i) {
      final t = runeTemplates[i % runeTemplates.length];
      return RuneModel(
        id: 'demo_$i',
        name: t.$1,
        description: t.$2,
        lore: 'Ancient lore of ${t.$1} passed down through generations of runesmiths.',
        element: t.$3,
        rarity: t.$4,
        emoji: t.$5,
        passiveBonus: t.$6,
        level: 1 + (i % 5),
        collectedAt: now.subtract(Duration(days: 60 - i, hours: rng.nextInt(12))),
        isActive: i % 7 == 0,
      );
    });

    _spells = [
      SpellModel(id: 'demo_s0', name: 'Flame Tide', description: 'Fire meets water in perfect harmony', emoji: '🌊🔥', runeIds: ['demo_0', 'demo_6'], effect: 'Boost focus AND calm simultaneously', createdAt: now.subtract(const Duration(days: 45)), isActive: true),
      SpellModel(id: 'demo_s1', name: 'Terra Storm', description: 'Earth and air collide', emoji: '⛰️⚡', runeIds: ['demo_10', 'demo_17'], effect: 'Grounded burst of energy', createdAt: now.subtract(const Duration(days: 40)), isActive: true),
      SpellModel(id: 'demo_s2', name: 'Spirit Blaze', description: 'Spirit energy ignites', emoji: '✨🔥', runeIds: ['demo_20', 'demo_1'], effect: 'XP multiplier for 2 hours', createdAt: now.subtract(const Duration(days: 35)), isActive: false),
      SpellModel(id: 'demo_s3', name: 'Frost Nova', description: 'Ice and cosmic energy merge', emoji: '❄️💫', runeIds: ['demo_7', 'demo_23'], effect: 'Calm focus mode', createdAt: now.subtract(const Duration(days: 30)), isActive: true),
      SpellModel(id: 'demo_s4', name: 'Void Tide', description: 'Darkness flows like water', emoji: '🕳️🌊', runeIds: ['demo_24', 'demo_8'], effect: 'Mystery bonus unlocked', createdAt: now.subtract(const Duration(days: 25)), isActive: false),
      SpellModel(id: 'demo_s5', name: 'Mountain Gale', description: 'Solid as rock, swift as wind', emoji: '⛰️💨', runeIds: ['demo_13', 'demo_16'], effect: 'Productivity double-strike', createdAt: now.subtract(const Duration(days: 20)), isActive: true),
      SpellModel(id: 'demo_s6', name: 'Solar Root', description: 'Sun energy grounds into earth', emoji: '☀️🌿', runeIds: ['demo_22', 'demo_11'], effect: 'Morning habit boost', createdAt: now.subtract(const Duration(days: 15)), isActive: true),
      SpellModel(id: 'demo_s7', name: 'Phoenix Storm', description: 'Rebirth through lightning', emoji: '🦅⚡', runeIds: ['demo_1', 'demo_17'], effect: 'Reset and surge', createdAt: now.subtract(const Duration(days: 12)), isActive: false),
      SpellModel(id: 'demo_s8', name: 'Whisper Flame', description: 'Quiet wisdom burns bright', emoji: '🎐🔥', runeIds: ['demo_18', 'demo_0'], effect: 'Insight mode', createdAt: now.subtract(const Duration(days: 8)), isActive: true),
      SpellModel(id: 'demo_s9', name: 'Cyclone Crystal', description: 'Spinning clarity of mind', emoji: '🌪️💎', runeIds: ['demo_19', 'demo_12'], effect: 'Hyper-focus mode', createdAt: now.subtract(const Duration(days: 5)), isActive: true),
      SpellModel(id: 'demo_s10', name: 'Lunar Frost', description: 'Moonlit ice pathway', emoji: '🌙❄️', runeIds: ['demo_21', 'demo_7'], effect: 'Night routine perfected', createdAt: now.subtract(const Duration(days: 4)), isActive: false),
      SpellModel(id: 'demo_s11', name: 'Inferno Void', description: 'Endless fire in the abyss', emoji: '💥🕳️', runeIds: ['demo_4', 'demo_24'], effect: 'Legendary XP boost', createdAt: now.subtract(const Duration(days: 3)), isActive: true),
      SpellModel(id: 'demo_s12', name: 'Torrent Seed', description: 'Water nurtures new growth', emoji: '🏊🌱', runeIds: ['demo_8', 'demo_14'], effect: 'Habit-building accelerator', createdAt: now.subtract(const Duration(days: 2)), isActive: true),
      SpellModel(id: 'demo_s13', name: 'Aether Blaze', description: 'Pure essence on fire', emoji: '✨🌋', runeIds: ['demo_20', 'demo_2'], effect: 'Universal daily boost', createdAt: now.subtract(const Duration(days: 1)), isActive: true),
    ];

    // Tower — first 7 floors complete, floor 8 in progress
    final defaultFloors = TowerFloor.defaultFloors();
    _towerFloors = defaultFloors.map((f) {
      if (f.floor <= 7) {
        return f.copyWith(isUnlocked: true, runesPlaced: f.runesRequired);
      } else if (f.floor == 8) {
        return f.copyWith(isUnlocked: true, runesPlaced: 16);
      }
      return f;
    }).toList();

    // Achievements — most unlocked
    final allAch = AchievementModel.defaults();
    _achievements = allAch.map((a) {
      final unlocked = [
        'first_rune', 'rune_collector_10', 'rune_hoarder_50',
        'all_elements', 'first_spell', 'spell_5',
        'floor_1', 'floor_5',
        'streak_3', 'streak_7', 'streak_14',
        'rare_rune', 'epic_rune', 'legendary_rune',
        'upgrade_5', 'upgrade_20',
        'level_5',
      ].contains(a.id);
      if (unlocked) {
        return a.copyWith(
          current: a.target,
          isUnlocked: true,
          unlockedAt: now.subtract(Duration(days: rng.nextInt(50) + 1)),
        );
      }
      // In-progress
      return a.copyWith(current: (a.target * 0.6).round());
    }).toList();

    // Trophies — most earned
    final allTrophies = TrophyModel.defaults();
    _trophies = allTrophies.map((t) {
      final earned = [
        'first_steps', 'fire_starter', 'water_bearer', 'earth_shaker',
        'wind_walker', 'spirit_seer', 'tower_initiate', 'spell_scholar',
        'rune_sage',
      ].contains(t.id);
      if (earned) {
        return t.copyWith(
          isEarned: true,
          earnedAt: now.subtract(Duration(days: rng.nextInt(50) + 1)),
        );
      }
      return t;
    }).toList();

    _lastRuneDrop = now.subtract(const Duration(minutes: 15));
    notifyListeners();
  }
}
