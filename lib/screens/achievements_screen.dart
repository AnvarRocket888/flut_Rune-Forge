import 'package:flutter/cupertino.dart';
import '../core/app_colors.dart';
import '../core/analytics_stub.dart';
import '../models/achievement_model.dart';
import '../services/game_state.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_emoji.dart';

class AchievementsScreen extends StatefulWidget {
  final GameState gameState;
  const AchievementsScreen({super.key, required this.gameState});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  String? _filterCategory;

  GameState get gs => widget.gameState;

  @override
  void initState() {
    super.initState();
    AnalyticsStub.screenView('achievements');
  }

  List<String> get _categories {
    final cats = gs.achievements.map((a) => a.category).toSet().toList();
    cats.sort();
    return cats;
  }

  List<AchievementModel> get _filteredAchievements {
    if (_filterCategory == null) return gs.achievements;
    return gs.achievements.where((a) => a.category == _filterCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.shortestSide > 600;
    final filtered = _filteredAchievements;

    return CupertinoPageScaffold(
      child: AnimatedBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            CupertinoSliverNavigationBar(
              backgroundColor: AppColors.bgDark.withValues(alpha: 0.8),
              border: null,
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.back, color: AppColors.accent),
                onPressed: () => Navigator.pop(context),
              ),
              largeTitle: Text(
                'Achievements 🏆',
                style: TextStyle(color: AppColors.textGold, fontSize: isTablet ? 28 : 22),
              ),
            ),

            // Summary
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _miniStat('🏆', '${gs.unlockedAchievements}', 'Unlocked'),
                    _miniStat('🔒', '${gs.achievements.length - gs.unlockedAchievements}', 'Locked'),
                    _miniStat('📊', '${(gs.unlockedAchievements / gs.achievements.length * 100).round()}%', 'Complete'),
                  ],
                ),
              ),
            ),

            // Category filter
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 36 : 12, vertical: 6),
                  children: [
                    _filterChip('All', null, _filterCategory == null),
                    ..._categories.map((c) => _filterChip(c, c, _filterCategory == c)),
                  ],
                ),
              ),
            ),

            // Achievements list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final achievement = filtered[index];
                  return _AchievementCard(
                    achievement: achievement,
                    isTablet: isTablet,
                  );
                },
                childCount: filtered.length,
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: mq.padding.bottom + 40)),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String emoji, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
      ],
    );
  }

  Widget _filterChip(String label, String? category, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _filterCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withValues(alpha: 0.2) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.accent : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.accent : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementModel achievement;
  final bool isTablet;

  const _AchievementCard({required this.achievement, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;
    final progress = achievement.target > 0
        ? (achievement.current / achievement.target).clamp(0.0, 1.0)
        : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnlocked ? AppColors.accent.withValues(alpha: 0.08) : AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked ? AppColors.accent.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Emoji with glow if unlocked
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked ? AppColors.accent.withValues(alpha: 0.15) : AppColors.bgCardLight,
              boxShadow: isUnlocked
                  ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 12)]
                  : null,
            ),
            child: Center(
              child: isUnlocked
                  ? AnimatedEmoji(emoji: achievement.emoji, size: 24, pulse: true)
                  : Text(
                      isUnlocked ? achievement.emoji : '🔒',
                      style: const TextStyle(fontSize: 22),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.name,
                        style: TextStyle(
                          color: isUnlocked ? AppColors.textGold : AppColors.textPrimary,
                          fontSize: isTablet ? 17 : 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('✅', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
                const SizedBox(height: 6),
                // Progress bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.bgCardLight,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: LinearGradient(
                                colors: isUnlocked
                                    ? [AppColors.success, AppColors.success]
                                    : [AppColors.accentDark, AppColors.accent],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${achievement.current}/${achievement.target}',
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: isTablet ? 12 : 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.bgCardLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    achievement.category,
                    style: const TextStyle(color: AppColors.textHint, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
