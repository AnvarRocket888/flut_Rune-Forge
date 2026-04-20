import 'dart:math';
import 'package:flutter/cupertino.dart';
import '../core/app_colors.dart';
import '../core/app_constants.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onDismiss;
  const WelcomeScreen({super.key, required this.onDismiss});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _particleController;
  late final AnimationController _titleController;
  late final AnimationController _towerController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _titleScale;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _towerRise;
  late final List<_SplashParticle> _particles;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();

    final rng = Random();
    _particles = List.generate(40, (_) => _SplashParticle(rng));

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _titleScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.elasticOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
    );

    _towerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _towerRise = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _towerController, curve: Curves.easeOutCubic),
    );

    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _towerController.forward();
    });

    // Auto dismiss after 5 seconds
    Future.delayed(AppConstants.splashDuration, () {
      if (mounted && !_isDismissing) _dismiss();
    });
  }

  void _dismiss() {
    if (_isDismissing) return;
    _isDismissing = true;
    _fadeController.forward().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _particleController.dispose();
    _titleController.dispose();
    _towerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: _dismiss,
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.3),
              radius: 1.2,
              colors: [
                Color(0xFF1C2048),
                Color(0xFF131633),
                Color(0xFF0B0D1A),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Particles
              _buildParticles(size),

              // Content
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 80 : 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 2),
                        // Tower visualization
                        _buildTower(isTablet),
                        SizedBox(height: isTablet ? 48 : 32),
                        // Title
                        SlideTransition(
                          position: _titleSlide,
                          child: ScaleTransition(
                            scale: _titleScale,
                            child: Text(
                              'RUNE FORGE',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: isTablet ? 48 : 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                                shadows: [
                                  Shadow(
                                    color: AppColors.accent.withValues(alpha: 0.6),
                                    blurRadius: 20,
                                  ),
                                  Shadow(
                                    color: AppColors.accent.withValues(alpha: 0.3),
                                    blurRadius: 40,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SlideTransition(
                          position: _titleSlide,
                          child: Text(
                            'Forge Your Destiny, One Rune at a Time',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: isTablet ? 18 : 14,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Subtitle
                        SlideTransition(
                          position: _titleSlide,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 24 : 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bgCard.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.borderGold.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '⚔️ Collect runes • Forge spells • Build your tower 🏰',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: isTablet ? 16 : 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const Spacer(flex: 3),
                        // Tap to continue
                        AnimatedBuilder(
                          listenable: _particleController,
                          builder: (context, _) {
                            final opacity = (sin(_particleController.value * pi * 2) + 1) / 2;
                            return Opacity(
                              opacity: 0.4 + opacity * 0.6,
                              child: Text(
                                'Tap anywhere to enter',
                                style: TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: isTablet ? 16 : 13,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTower(bool isTablet) {
    return AnimatedBuilder(
      listenable: _towerRise,
      builder: (context, _) {
        return SizedBox(
          height: isTablet ? 200 : 150,
          child: CustomPaint(
            size: Size(isTablet ? 120 : 90, isTablet ? 200 : 150),
            painter: _TowerPainter(_towerRise.value),
          ),
        );
      },
    );
  }

  Widget _buildParticles(Size size) {
    return AnimatedBuilder(
      listenable: _particleController,
      builder: (context, _) {
        return CustomPaint(
          size: size,
          painter: _SplashParticlePainter(_particles, _particleController.value),
        );
      },
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) => builder(context, child);
}

class _TowerPainter extends CustomPainter {
  final double progress;
  _TowerPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw tower floors from bottom up
    final floorCount = 5;
    final floorHeight = h / floorCount;
    final floorsVisible = (progress * floorCount).ceil();

    for (int i = 0; i < floorsVisible; i++) {
      final floorProgress = ((progress * floorCount) - i).clamp(0.0, 1.0);
      final y = h - (i + 1) * floorHeight;
      final shrink = i * 4.0;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(shrink, y + (1 - floorProgress) * floorHeight, w - shrink * 2, floorHeight - 2),
        const Radius.circular(4),
      );

      // Floor body
      final paint = Paint()
        ..color = AppColors.bgCardLight.withValues(alpha: floorProgress)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rect, paint);

      // Floor border
      final borderPaint = Paint()
        ..color = AppColors.borderGold.withValues(alpha: floorProgress * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRRect(rect, borderPaint);

      // Floor glow
      if (i == floorsVisible - 1 && floorProgress > 0.5) {
        final glowPaint = Paint()
          ..color = AppColors.accent.withValues(alpha: (floorProgress - 0.5) * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawRRect(rect, glowPaint);
      }
    }

    // Crown on top
    if (progress > 0.9) {
      final crownOpacity = ((progress - 0.9) * 10).clamp(0.0, 1.0);
      final crownPaint = Paint()
        ..color = AppColors.accent.withValues(alpha: crownOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(w / 2, 8), 6, crownPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TowerPainter old) => old.progress != progress;
}

class _SplashParticle {
  final double x, y, size, speed, phase;

  _SplashParticle(Random rng)
      : x = rng.nextDouble(),
        y = rng.nextDouble(),
        size = rng.nextDouble() * 3 + 1,
        speed = rng.nextDouble() * 0.3 + 0.1,
        phase = rng.nextDouble() * pi * 2;
}

class _SplashParticlePainter extends CustomPainter {
  final List<_SplashParticle> particles;
  final double progress;

  _SplashParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = (p.y - progress * p.speed) % 1.0;
      final pulse = (sin(progress * pi * 2 + p.phase) + 1) / 2;
      final opacity = 0.2 + pulse * 0.4;

      canvas.drawCircle(
        Offset(p.x * size.width, y * size.height),
        p.size,
        Paint()
          ..color = AppColors.particle.withValues(alpha: opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SplashParticlePainter old) => true;
}
