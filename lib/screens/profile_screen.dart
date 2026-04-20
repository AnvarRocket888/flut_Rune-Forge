import 'package:flutter/cupertino.dart';
import '../core/app_colors.dart';
import '../core/app_constants.dart';
import '../core/analytics_stub.dart';
import '../services/game_state.dart';
import '../widgets/animated_background.dart';
import '../widgets/xp_progress_bar.dart';
import '../widgets/stat_card.dart';
import 'achievements_screen.dart';
import 'trophies_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final GameState gameState;
  const ProfileScreen({super.key, required this.gameState});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GameState get gs => widget.gameState;

  @override
  void initState() {
    super.initState();
    AnalyticsStub.screenView('profile');
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.shortestSide > 600;

    return AnimatedBackground(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: AppColors.bgDark.withValues(alpha: 0.8),
            border: null,
            largeTitle: Text(
              'Profile ⚔️',
              style: TextStyle(color: AppColors.textGold, fontSize: isTablet ? 28 : 22),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.gear_alt, color: AppColors.textSecondary),
              onPressed: () => Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => SettingsScreen(gameState: gs)),
              ).then((_) => setState(() {})),
            ),
          ),

          // Avatar & name
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 24, vertical: 12),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.bgGradient),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(color: AppColors.accent.withValues(alpha: 0.15), blurRadius: 20),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: isTablet ? 100 : 80,
                    height: isTablet ? 100 : 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.accentDark, AppColors.accent],
                      ),
                      boxShadow: [
                        BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 16),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _avatarEmoji,
                        style: TextStyle(fontSize: isTablet ? 48 : 38),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    gs.profile.name,
                    style: TextStyle(
                      color: AppColors.textGold,
                      fontSize: isTablet ? 28 : 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '⭐ ${AppConstants.levelTitle(gs.profile.level)} — Level ${gs.profile.level}',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: isTablet ? 16 : 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  XpProgressBar(
                    progress: gs.profile.levelProgress,
                    currentXp: gs.profile.xpInCurrentLevel,
                    targetXp: gs.profile.xpForCurrentLevel,
                    label: '${gs.profile.xpToNextLevel} XP to next level',
                  ),
                ],
              ),
            ),
          ),

          // Stats grid
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16),
              child: GridView.count(
                crossAxisCount: isTablet ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.6,
                children: [
                  StatCard(emoji: '📦', value: '${gs.totalRunes}', label: 'Runes', accentColor: AppColors.rarityEpic),
                  StatCard(emoji: '🪄', value: '${gs.spells.length}', label: 'Spells', accentColor: AppColors.elementSpirit),
                  StatCard(emoji: '🔥', value: '${gs.profile.currentStreak}', label: 'Streak', accentColor: AppColors.elementFire),
                  StatCard(emoji: '⚡', value: '${gs.profile.energy}', label: 'Energy', accentColor: AppColors.elementAir),
                  StatCard(emoji: '🏆', value: '${gs.unlockedAchievements}', label: 'Achievements', accentColor: AppColors.accent),
                  StatCard(emoji: '🥇', value: '${gs.earnedTrophies}', label: 'Trophies', accentColor: AppColors.rarityLegendary),
                  StatCard(emoji: '🏰', value: '${gs.completedFloors}', label: 'Floors', accentColor: AppColors.elementEarth),
                  StatCard(emoji: '⭐', value: '${gs.profile.xp}', label: 'Total XP', accentColor: AppColors.accent),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Achievements preview
          SliverToBoxAdapter(
            child: _sectionButton(
              isTablet,
              '🏆 Achievements',
              '${gs.unlockedAchievements} / ${gs.achievements.length} unlocked',
              () => Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => AchievementsScreen(gameState: gs)),
              ),
            ),
          ),

          // Trophies preview
          SliverToBoxAdapter(
            child: _sectionButton(
              isTablet,
              '🥇 Trophies',
              '${gs.earnedTrophies} / ${gs.trophies.length} earned',
              () => Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => TrophiesScreen(gameState: gs)),
              ),
            ),
          ),

          // Detailed stats
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detailed Stats 📊',
                    style: TextStyle(
                      color: AppColors.textGold,
                      fontSize: isTablet ? 18 : 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _detailRow('Total Runes Collected', '${gs.profile.totalRunesCollected}', isTablet),
                  _detailRow('Total Spells Forged', '${gs.profile.totalSpellsCreated}', isTablet),
                  _detailRow('Total Upgrades', '${gs.profile.totalUpgrades}', isTablet),
                  _detailRow('Best Streak', '${gs.profile.bestStreak} days', isTablet),
                  _detailRow('Current Streak', '${gs.profile.currentStreak} days', isTablet),
                  _detailRow('Member Since', _formatDate(gs.profile.lastActiveDate ?? DateTime.now()), isTablet),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: mq.padding.bottom + 100)),
        ],
      ),
    );
  }

  String get _avatarEmoji {
    final level = gs.profile.level;
    if (level >= 9) return '👑';
    if (level >= 7) return '🐉';
    if (level >= 5) return '🧙';
    if (level >= 3) return '⚔️';
    return '🔮';
  }

  Widget _sectionButton(bool isTablet, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, color: AppColors.textHint, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: isTablet ? 15 : 13)),
          Text(value, style: TextStyle(color: AppColors.textPrimary, fontSize: isTablet ? 15 : 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
