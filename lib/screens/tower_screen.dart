import 'dart:math';
import 'package:flutter/cupertino.dart';
import '../core/app_colors.dart';
import '../core/analytics_stub.dart';
import '../models/tower_model.dart';
import '../services/game_state.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_emoji.dart';
import '../widgets/glowing_card.dart';

class TowerScreen extends StatefulWidget {
  final GameState gameState;
  const TowerScreen({super.key, required this.gameState});

  @override
  State<TowerScreen> createState() => _TowerScreenState();
}

class _TowerScreenState extends State<TowerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  GameState get gs => widget.gameState;

  @override
  void initState() {
    super.initState();
    AnalyticsStub.screenView('tower');
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.shortestSide > 600;
    final floors = gs.towerFloors;

    return AnimatedBackground(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: AppColors.bgDark.withValues(alpha: 0.8),
            border: null,
            largeTitle: Text(
              'Tower 🏰',
              style: TextStyle(color: AppColors.textGold, fontSize: isTablet ? 28 : 22),
            ),
          ),

          // Tower progress summary
          SliverToBoxAdapter(
            child: GlowingCard(
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const AnimatedEmoji(emoji: '🏰', size: 28, bounce: true),
                          const SizedBox(width: 8),
                          Text(
                            'Tower Progress',
                            style: TextStyle(
                              color: AppColors.textGold,
                              fontSize: isTablet ? 20 : 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${gs.completedFloors} / ${floors.length}',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: isTablet ? 18 : 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildOverallProgress(floors),
                  const SizedBox(height: 8),
                  Text(
                    _getMotivation(),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Tower visual
          SliverToBoxAdapter(
            child: _buildTowerVisual(floors, isTablet),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Floor list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Show floors from top to bottom
                final floor = floors[floors.length - 1 - index];
                return _FloorCard(
                  floor: floor,
                  isTablet: isTablet,
                  shimmerAnimation: _shimmerController,
                  onTap: () => _showFloorDetail(floor, isTablet),
                );
              },
              childCount: floors.length,
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: mq.padding.bottom + 100)),
        ],
      ),
    );
  }

  Widget _buildOverallProgress(List<TowerFloor> floors) {
    final progress = floors.isEmpty ? 0.0 : gs.completedFloors / floors.length;
    return Container(
      height: 10,
      decoration: BoxDecoration(
        color: AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(5),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0, 1).toDouble(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            gradient: const LinearGradient(
              colors: [AppColors.accentDark, AppColors.accent, AppColors.accentBright],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTowerVisual(List<TowerFloor> floors, bool isTablet) {
    final towerWidth = isTablet ? 200.0 : 140.0;
    final floorH = isTablet ? 30.0 : 22.0;

    return Center(
      child: SizedBox(
        width: towerWidth + 60,
        height: floors.length * floorH + 60,
        child: CustomPaint(
          painter: _TowerPainter(
            floors: floors,
            progress: _shimmerController,
          ),
          size: Size(towerWidth + 60, floors.length * floorH + 60),
        ),
      ),
    );
  }

  void _showFloorDetail(TowerFloor floor, bool isTablet) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.all(isTablet ? 28 : 20),
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.textHint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(floor.emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                floor.name,
                style: TextStyle(
                  color: AppColors.textGold,
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                floor.description,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: isTablet ? 16 : 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Progress bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progress', style: TextStyle(color: AppColors.textSecondary, fontSize: isTablet ? 15 : 13)),
                  Text(
                    '${floor.runesPlaced} / ${floor.runesRequired}',
                    style: TextStyle(
                      color: floor.isComplete ? AppColors.success : AppColors.accent,
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.bgCardLight,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: floor.progress.clamp(0, 1),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                        colors: floor.isComplete
                            ? [AppColors.success, AppColors.success]
                            : [AppColors.accentDark, AppColors.accent],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (floor.isComplete ? AppColors.success : AppColors.accent).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  floor.isComplete ? '✅ Completed' : '🔒 In Progress',
                  style: TextStyle(
                    color: floor.isComplete ? AppColors.success : AppColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getMotivation() {
    if (gs.completedFloors == 0) return 'Build your tower by collecting runes and forging spells! 🧱';
    if (gs.completedFloors < 3) return 'Your tower is starting to rise! Keep going! 🌅';
    if (gs.completedFloors < 7) return 'Impressive progress! The peak is in sight! ⛰️';
    if (gs.completedFloors < 10) return 'Almost there! The Crown awaits! 👑';
    return 'The tower stands complete! You are a Legendary Runesmith! 🏆';
  }
}

class _FloorCard extends StatelessWidget {
  final TowerFloor floor;
  final bool isTablet;
  final Animation<double> shimmerAnimation;
  final VoidCallback onTap;

  const _FloorCard({
    required this.floor,
    required this.isTablet,
    required this.shimmerAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: floor.isComplete
              ? AppColors.accent.withValues(alpha: 0.08)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: floor.isComplete
                ? AppColors.success.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Text(floor.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    floor.name,
                    style: TextStyle(
                      color: floor.isComplete ? AppColors.success : AppColors.textPrimary,
                      fontSize: isTablet ? 17 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Mini progress bar
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.bgCardLight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: floor.progress.clamp(0, 1),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: LinearGradient(
                            colors: floor.isComplete
                                ? [AppColors.success, AppColors.success]
                                : [AppColors.accentDark, AppColors.accent],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              floor.isComplete ? '✅' : '🔒',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _TowerPainter extends CustomPainter {
  final List<TowerFloor> floors;
  final Animation<double> progress;

  _TowerPainter({required this.floors, required this.progress}) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final baseY = size.height - 20;
    final floorH = (size.height - 40) / floors.length;
    final baseW = size.width * 0.6;

    for (int i = 0; i < floors.length; i++) {
      final floor = floors[i];
      final y = baseY - (i + 1) * floorH;
      final w = baseW - (i * baseW * 0.04);

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(centerX, y + floorH / 2), width: w, height: floorH - 4),
        const Radius.circular(4),
      );

      final paint = Paint()
        ..color = floor.isComplete
            ? AppColors.accent.withValues(alpha: 0.5 + 0.3 * sin(progress.value * 2 * pi + i))
            : AppColors.bgCardLight.withValues(alpha: 0.4);

      canvas.drawRRect(rect, paint);

      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = floor.isComplete
            ? AppColors.accent.withValues(alpha: 0.6)
            : AppColors.border.withValues(alpha: 0.3);

      canvas.drawRRect(rect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TowerPainter oldDelegate) => true;
}
