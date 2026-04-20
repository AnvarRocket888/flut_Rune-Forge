import 'package:flutter/cupertino.dart';
import '../core/app_colors.dart';
import '../models/rune_model.dart';

class RuneCard extends StatefulWidget {
  final RuneModel rune;
  final VoidCallback? onTap;
  final bool showDetails;
  final bool isSelected;

  const RuneCard({
    super.key,
    required this.rune,
    this.onTap,
    this.showDetails = true,
    this.isSelected = false,
  });

  @override
  State<RuneCard> createState() => _RuneCardState();
}

class _RuneCardState extends State<RuneCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Color get _rarityColor {
    switch (widget.rune.rarity) {
      case RuneRarity.common:
        return AppColors.rarityCommon;
      case RuneRarity.rare:
        return AppColors.rarityRare;
      case RuneRarity.epic:
        return AppColors.rarityEpic;
      case RuneRarity.legendary:
        return AppColors.rarityLegendary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedBuilder(
          listenable: _shimmerController,
          builder: (context, _) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? _rarityColor.withValues(alpha: 0.15)
                    : AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.isSelected
                      ? _rarityColor
                      : _rarityColor.withValues(alpha: 0.2 + _shimmerController.value * 0.3),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _rarityColor.withValues(alpha: 0.1 + _shimmerController.value * 0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Emoji & level badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Text(widget.rune.emoji, style: const TextStyle(fontSize: 36)),
                      if (widget.rune.level > 1)
                        Positioned(
                          right: -8,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Lv${widget.rune.level}',
                              style: const TextStyle(
                                color: AppColors.bgDark,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.rune.name,
                    style: TextStyle(
                      color: _rarityColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.showDetails) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.rune.elementLabel,
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _rarityColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.rune.rarityLabel,
                        style: TextStyle(
                          color: _rarityColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
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

  @override
  Widget build(BuildContext context) => builder(context, child);
}
