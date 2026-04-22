import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../services/game_state.dart';
import 'home_screen.dart';
import 'rune_collection_screen.dart';
import 'rune_detail_screen.dart';
import 'forge_screen.dart' hide AnimatedBuilder;
import 'tower_screen.dart';
import 'profile_screen.dart';
import 'achievements_screen.dart';
import 'trophies_screen.dart';

/// Slideshow screen for making App Store screenshots.
///
/// Shows each main screen for [_holdSeconds] seconds, then advances.
/// Wraps real screens with demo [GameState] data so they look fully used.
/// Tap anywhere to advance manually. Long-press to restart.
class ScreenshotSlideshow extends StatefulWidget {
  final GameState gameState;

  const ScreenshotSlideshow({super.key, required this.gameState});

  @override
  State<ScreenshotSlideshow> createState() => _ScreenshotSlideshowState();
}

class _ScreenshotSlideshowState extends State<ScreenshotSlideshow> {
  static const int _holdSeconds = 4;

  int _currentIndex = 0;
  Timer? _timer;

  late final List<_Slide> _slides;

  @override
  void initState() {
    super.initState();
    _slides = _buildSlides();
    _startTimer();
  }

  List<_Slide> _buildSlides() {
    final gs = widget.gameState;
    return [
      _Slide('Home', HomeScreen(gameState: gs)),
      _Slide('Rune Collection', RuneCollectionScreen(gameState: gs)),
      _Slide('Rune Detail', _runeDetailSlide(gs)),
      _Slide('Forge', ForgeScreen(gameState: gs)),
      _Slide('Tower', TowerScreen(gameState: gs)),
      _Slide('Profile', ProfileScreen(gameState: gs)),
      _Slide('Achievements', AchievementsScreen(gameState: gs)),
      _Slide('Trophies', TrophiesScreen(gameState: gs)),
    ];
  }

  Widget _runeDetailSlide(GameState gs) {
    // Pick a legendary rune from demo data for the detail view
    final rune = gs.runes.firstWhere(
      (r) => r.rarity.name == 'legendary',
      orElse: () => gs.runes.first,
    );
    return RuneDetailScreen(rune: rune, gameState: gs);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: _holdSeconds), (_) {
      if (mounted) _advance();
    });
  }

  void _advance() {
    if (_currentIndex < _slides.length - 1) {
      setState(() => _currentIndex++);
    } else {
      // End of slideshow
      _timer?.cancel();
    }
  }

  void _restart() {
    setState(() => _currentIndex = 0);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentIndex];
    final isLast = _currentIndex == _slides.length - 1;

    return GestureDetector(
      onTap: isLast ? null : _advance,
      onLongPress: _restart,
      child: slide.widget,
    );
  }
}

// ── _Slide ────────────────────────────────────────────────

class _Slide {
  final String name;
  final Widget widget;
  const _Slide(this.name, this.widget);
}
