import 'package:flutter/services.dart';
import 'storage_service.dart';

class FeedbackService {
  FeedbackService._();

  static const _kSound = 'sound_enabled';
  static const _kHaptics = 'haptics_enabled';

  static bool soundEnabled = true;
  static bool hapticsEnabled = true;

  static void init() {
    soundEnabled = StorageService.getBool(_kSound) ?? true;
    hapticsEnabled = StorageService.getBool(_kHaptics) ?? true;
  }

  static Future<void> setSoundEnabled(bool val) async {
    soundEnabled = val;
    await StorageService.setBool(_kSound, val);
  }

  static Future<void> setHapticsEnabled(bool val) async {
    hapticsEnabled = val;
    await StorageService.setBool(_kHaptics, val);
  }

  // ── Haptics ──────────────────────────────────────────────

  static void hapticLight() {
    if (hapticsEnabled) HapticFeedback.lightImpact();
  }

  static void hapticMedium() {
    if (hapticsEnabled) HapticFeedback.mediumImpact();
  }

  static void hapticHeavy() {
    if (hapticsEnabled) HapticFeedback.heavyImpact();
  }

  static void hapticSelection() {
    if (hapticsEnabled) HapticFeedback.selectionClick();
  }

  // ── Sounds ───────────────────────────────────────────────

  static void playClick() {
    if (soundEnabled) SystemSound.play(SystemSoundType.click);
  }

  static void playAlert() {
    if (soundEnabled) SystemSound.play(SystemSoundType.alert);
  }

  // ── Compound shortcuts ───────────────────────────────────

  /// Light tap: for toggles and minor actions
  static void tap() {
    hapticSelection();
    playClick();
  }

  /// Strong action: for forge, upgrade, etc.
  static void impact() {
    hapticHeavy();
    playAlert();
  }
}
