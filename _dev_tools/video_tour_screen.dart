import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../services/game_state.dart';
import '../models/rune_model.dart';
import 'home_screen.dart';
import 'rune_collection_screen.dart';
import 'rune_detail_screen.dart';
import 'forge_screen.dart' hide AnimatedBuilder;
import 'tower_screen.dart';
import 'profile_screen.dart';
import 'achievements_screen.dart';
import 'trophies_screen.dart';

/// Automated promo video tour (~63 seconds total).
///
/// Sequence:
///   Home (8s) → Rune Collection (10s, auto-scroll) → Rune Detail (7s)
///   → Forge (8s) → Tower (8s, auto-scroll) → Profile (8s, auto-scroll)
///   → Achievements (7s, auto-scroll) → Trophies (7s, auto-scroll)
///
/// Screens crossfade into each other. Scrollable screens gently scroll
/// down to reveal content as if a real user is exploring the app.
class VideoTourScreen extends StatefulWidget {
  final GameState gameState;

  const VideoTourScreen({super.key, required this.gameState});

  @override
  State<VideoTourScreen> createState() => _VideoTourScreenState();
}

class _VideoTourScreenState extends State<VideoTourScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  late final List<_TourSlide> _slides;
  final List<ScrollController> _scrollControllers = [];

  Timer? _slideTimer;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _buildSlides();
    _fadeController.forward();
    _scheduleSlide(0);
  }

  void _buildSlides() {
    final gs = widget.gameState;

    // Pick a legendary rune for the detail slide
    final legendaryRune = gs.runes.firstWhere(
      (r) => r.rarity == RuneRarity.legendary,
      orElse: () => gs.runes.first,
    );

    _slides = [
      // ── Home ─────────────────────────────────────────────
      _TourSlide(
        duration: const Duration(seconds: 8),
        build: (_) => HomeScreen(gameState: gs),
      ),

      // ── Rune Collection ───────────────────────────────────
      _TourSlide(
        duration: const Duration(seconds: 10),
        scrollTo: 750,
        scrollDelay: const Duration(seconds: 2),
        scrollDuration: const Duration(milliseconds: 4500),
        build: (sc) => PrimaryScrollController(
          controller: sc,
          child: RuneCollectionScreen(gameState: gs),
        ),
      ),

      // ── Rune Detail ───────────────────────────────────────
      _TourSlide(
        duration: const Duration(seconds: 7),
        build: (_) => RuneDetailScreen(rune: legendaryRune, gameState: gs),
      ),

      // ── Forge ─────────────────────────────────────────────
      _TourSlide(
        duration: const Duration(seconds: 8),
        scrollTo: 350,
        scrollDelay: const Duration(seconds: 2),
        scrollDuration: const Duration(milliseconds: 3000),
        build: (sc) => PrimaryScrollController(
          controller: sc,
          child: ForgeScreen(gameState: gs),
        ),
      ),

      // ── Tower ─────────────────────────────────────────────
      _TourSlide(
        duration: const Duration(seconds: 8),
        scrollTo: 650,
        scrollDelay: const Duration(seconds: 2),
        scrollDuration: const Duration(milliseconds: 3500),
        build: (sc) => PrimaryScrollController(
          controller: sc,
          child: TowerScreen(gameState: gs),
        ),
      ),

      // ── Profile ───────────────────────────────────────────
      _TourSlide(
        duration: const Duration(seconds: 8),
        scrollTo: 500,
        scrollDelay: const Duration(seconds: 2),
        scrollDuration: const Duration(milliseconds: 3000),
        build: (sc) => PrimaryScrollController(
          controller: sc,
          child: ProfileScreen(gameState: gs),
        ),
      ),

      // ── Achievements ──────────────────────────────────────
      _TourSlide(
        duration: const Duration(seconds: 7),
        scrollTo: 550,
        scrollDelay: const Duration(seconds: 2),
        scrollDuration: const Duration(milliseconds: 3000),
        build: (sc) => PrimaryScrollController(
          controller: sc,
          child: AchievementsScreen(gameState: gs),
        ),
      ),

      // ── Trophies ──────────────────────────────────────────
      _TourSlide(
        duration: const Duration(seconds: 7),
        scrollTo: 400,
        scrollDelay: const Duration(seconds: 2),
        scrollDuration: const Duration(milliseconds: 2500),
        build: (sc) => PrimaryScrollController(
          controller: sc,
          child: TrophiesScreen(gameState: gs),
        ),
      ),
    ];

    _scrollControllers.addAll(
      List.generate(_slides.length, (_) => ScrollController()),
    );
  }

  void _scheduleSlide(int index) {
    final slide = _slides[index];

    // Start scroll animation after delay
    if (slide.scrollTo > 0 && slide.scrollDelay != null) {
      _scrollTimer = Timer(slide.scrollDelay!, () {
        final sc = _scrollControllers[index];
        if (sc.hasClients) {
          sc.animateTo(
            slide.scrollTo.toDouble(),
            duration: slide.scrollDuration!,
            curve: Curves.easeInOutSine,
          );
        }
      });
    }

    // Advance to the next slide when time is up
    if (index < _slides.length - 1) {
      _slideTimer = Timer(slide.duration, _advance);
    }
  }

  Future<void> _advance() async {
    _scrollTimer?.cancel();
    _slideTimer?.cancel();

    // Fade out current screen
    await _fadeController.reverse();
    if (!mounted) return;

    setState(() => _currentIndex++);

    // Fade in next screen
    await _fadeController.forward();
    if (!mounted) return;

    _scheduleSlide(_currentIndex);
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _scrollTimer?.cancel();
    _fadeController.dispose();
    for (final sc in _scrollControllers) {
      sc.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: _slides[_currentIndex].build(_scrollControllers[_currentIndex]),
    );
  }
}

// ── Data ──────────────────────────────────────────────────

class _TourSlide {
  final Duration duration;
  final Widget Function(ScrollController) build;
  final int scrollTo;
  final Duration? scrollDelay;
  final Duration? scrollDuration;

  const _TourSlide({
    required this.duration,
    required this.build,
    this.scrollTo = 0,
    this.scrollDelay,
    this.scrollDuration,
  });
}
