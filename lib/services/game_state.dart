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
}
