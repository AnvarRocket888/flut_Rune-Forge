import 'dart:math';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late final List<_Particle> _particles;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(30, (_) => _Particle(rng));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bgDark,
            AppColors.bgMid,
            AppColors.bgDark,
          ],
        ),
      ),
      child: AnimatedBuilder(
        listenable: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ParticlePainter(_particles, _controller.value),
            child: child,
          );
        },
        child: widget.child,
      ),
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

  Animation<double> get animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) => builder(context, child);
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  _Particle(Random rng)
      : x = rng.nextDouble(),
        y = rng.nextDouble(),
        size = rng.nextDouble() * 3 + 1,
        speed = rng.nextDouble() * 0.5 + 0.2,
        opacity = rng.nextDouble() * 0.6 + 0.2;
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = (p.y + progress * p.speed) % 1.0;
      final pulse = (sin((progress + p.x) * pi * 2) + 1) / 2;
      final currentOpacity = p.opacity * (0.5 + pulse * 0.5);

      final paint = Paint()
        ..color = AppColors.particle.withValues(alpha: currentOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 2);

      canvas.drawCircle(
        Offset(p.x * size.width, y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}
