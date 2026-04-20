import 'dart:math';
import 'package:flutter/cupertino.dart';
import '../core/app_colors.dart';

class AnimatedEmoji extends StatefulWidget {
  final String emoji;
  final double size;
  final bool bounce;
  final bool rotate;
  final bool pulse;

  const AnimatedEmoji({
    super.key,
    required this.emoji,
    this.size = 32,
    this.bounce = false,
    this.rotate = false,
    this.pulse = true,
  });

  @override
  State<AnimatedEmoji> createState() => _AnimatedEmojiState();
}

class _AnimatedEmojiState extends State<AnimatedEmoji>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      listenable: _controller,
      builder: (context, _) {
        double scale = 1.0;
        double angle = 0.0;
        double dy = 0.0;

        if (widget.pulse) {
          scale = 1.0 + _controller.value * 0.1;
        }
        if (widget.rotate) {
          angle = _controller.value * pi * 0.1;
        }
        if (widget.bounce) {
          dy = -_controller.value * 4;
        }

        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.rotate(
            angle: angle,
            child: Transform.scale(
              scale: scale,
              child: Text(
                widget.emoji,
                style: TextStyle(fontSize: widget.size),
              ),
            ),
          ),
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

class PulsingGlow extends StatefulWidget {
  final Widget child;
  final Color color;

  const PulsingGlow({
    super.key,
    required this.child,
    this.color = AppColors.accent,
  });

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.2 + _controller.value * 0.3),
                blurRadius: 20 + _controller.value * 15,
                spreadRadius: _controller.value * 5,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
