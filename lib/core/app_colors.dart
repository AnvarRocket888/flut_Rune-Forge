import 'dart:ui';

/// ─────────────────────────────────────────────────────────
/// Rune Forge — Central Color Palette
/// ─────────────────────────────────────────────────────────
/// To re-skin the entire app, change ONLY the values below.
/// Every widget reads from [AppColors] so a single edit here
/// propagates everywhere.
/// ─────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // ── Background gradient ──────────────────────────────────
  static const Color bgDark       = Color(0xFF0B0D1A);
  static const Color bgMid        = Color(0xFF131633);
  static const Color bgLight      = Color(0xFF1C2048);
  static const Color bgCard       = Color(0xFF1A1E3C);
  static const Color bgCardLight  = Color(0xFF232850);

  // ── Primary accent (golden) ──────────────────────────────
  static const Color accent       = Color(0xFFFFD54F);
  static const Color accentBright = Color(0xFFFFE082);
  static const Color accentDark   = Color(0xFFC9A622);

  // ── Text ─────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B3C5);
  static const Color textHint      = Color(0xFF6B6F85);
  static const Color textGold      = Color(0xFFFFD54F);

  // ── Borders / Dividers ───────────────────────────────────
  static const Color border       = Color(0xFF2A2F55);
  static const Color borderLight  = Color(0xFF3A3F65);
  static const Color borderGold   = Color(0x66FFD54F);

  // ── Status ───────────────────────────────────────────────
  static const Color success      = Color(0xFF4CAF50);
  static const Color error        = Color(0xFFEF5350);
  static const Color warning      = Color(0xFFFFA726);
  static const Color info         = Color(0xFF42A5F5);

  // ── Rarity ───────────────────────────────────────────────
  static const Color rarityCommon    = Color(0xFF9E9E9E);
  static const Color rarityRare     = Color(0xFF42A5F5);
  static const Color rarityEpic     = Color(0xFFAB47BC);
  static const Color rarityLegendary = Color(0xFFFFD54F);

  // ── Elements ─────────────────────────────────────────────
  static const Color elementFire   = Color(0xFFFF6D00);
  static const Color elementWater  = Color(0xFF2196F3);
  static const Color elementEarth  = Color(0xFF8D6E63);
  static const Color elementAir    = Color(0xFF80DEEA);
  static const Color elementSpirit = Color(0xFFCE93D8);

  // ── Navigation ───────────────────────────────────────────
  static const Color navBg         = Color(0xFF0F1229);
  static const Color navActive     = Color(0xFFFFD54F);
  static const Color navInactive   = Color(0xFF6B6F85);

  // ── Particle / Glow ──────────────────────────────────────
  static const Color particle      = Color(0xCCFFD54F);
  static const Color glow          = Color(0x44FFD54F);

  // ── Shimmer / skeleton ───────────────────────────────────
  static const Color shimmerBase   = Color(0xFF1A1E3C);
  static const Color shimmerLight  = Color(0xFF2A2F55);

  // ── Helpers ──────────────────────────────────────────────
  static List<Color> get bgGradient => [bgDark, bgMid, bgLight];

  static List<Color> get cardGradient => [
    bgCard,
    bgCardLight,
  ];
}
