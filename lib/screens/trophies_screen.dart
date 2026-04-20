import 'package:flutter/cupertino.dart';
import '../core/app_colors.dart';
import '../core/analytics_stub.dart';
import '../models/trophy_model.dart';
import '../services/game_state.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_emoji.dart';

class TrophiesScreen extends StatefulWidget {
  final GameState gameState;
  const TrophiesScreen({super.key, required this.gameState});

  @override
  State<TrophiesScreen> createState() => _TrophiesScreenState();
}

class _TrophiesScreenState extends State<TrophiesScreen> {
  GameState get gs => widget.gameState;

  @override
  void initState() {
    super.initState();
    AnalyticsStub.screenView('trophies');
  }

  Color _tierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze': return const Color(0xFFCD7F32);
      case 'silver': return const Color(0xFFC0C0C0);
      case 'gold': return AppColors.accent;
      case 'platinum': return const Color(0xFFE5E4E2);
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.shortestSide > 600;

    // Group by tier
    final tiers = ['platinum', 'gold', 'silver', 'bronze'];

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
                'Trophies 🥇',
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
                    _miniStat('🥇', '${gs.earnedTrophies}', 'Earned'),
                    _miniStat('🔒', '${gs.trophies.length - gs.earnedTrophies}', 'Locked'),
                    _miniStat('📊', '${(gs.earnedTrophies / gs.trophies.length * 100).round()}%', 'Complete'),
                  ],
                ),
              ),
            ),

            // Trophies by tier
            for (final tier in tiers) ...[
              _buildTierSection(tier, isTablet),
            ],

            SliverToBoxAdapter(child: SizedBox(height: mq.padding.bottom + 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildTierSection(String tier, bool isTablet) {
    final trophiesInTier = gs.trophies.where((t) => t.tier.toLowerCase() == tier).toList();
    if (trophiesInTier.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final tierColor = _tierColor(tier);
    final tierEmoji = switch (tier) {
      'platinum' => '💎',
      'gold' => '🥇',
      'silver' => '🥈',
      'bronze' => '🥉',
      _ => '🏆',
    };

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20, vertical: 12),
            child: Row(
              children: [
                Text(tierEmoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  '${tier[0].toUpperCase()}${tier.substring(1)} Tier',
                  style: TextStyle(
                    color: tierColor,
                    fontSize: isTablet ? 20 : 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${trophiesInTier.where((t) => t.isEarned).length}/${trophiesInTier.length}',
                  style: TextStyle(color: AppColors.textHint, fontSize: isTablet ? 14 : 12),
                ),
              ],
            ),
          ),
          ...trophiesInTier.map((trophy) => _TrophyCard(
                trophy: trophy,
                isTablet: isTablet,
                tierColor: tierColor,
              )),
        ],
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
}

class _TrophyCard extends StatelessWidget {
  final TrophyModel trophy;
  final bool isTablet;
  final Color tierColor;

  const _TrophyCard({
    required this.trophy,
    required this.isTablet,
    required this.tierColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEarned = trophy.isEarned;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isEarned ? tierColor.withValues(alpha: 0.06) : AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isEarned ? tierColor.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEarned ? tierColor.withValues(alpha: 0.15) : AppColors.bgCardLight,
              boxShadow: isEarned
                  ? [BoxShadow(color: tierColor.withValues(alpha: 0.3), blurRadius: 16)]
                  : null,
            ),
            child: Center(
              child: isEarned
                  ? AnimatedEmoji(emoji: trophy.emoji, size: 28, pulse: true)
                  : Text(
                      '🔒',
                      style: TextStyle(fontSize: 24, color: AppColors.textHint.withValues(alpha: 0.5)),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trophy.name,
                  style: TextStyle(
                    color: isEarned ? tierColor : AppColors.textPrimary,
                    fontSize: isTablet ? 17 : 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trophy.description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: tierColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${trophy.tier[0].toUpperCase()}${trophy.tier.substring(1)}',
                        style: TextStyle(color: tierColor, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (isEarned && trophy.earnedAt != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Earned ${_formatDate(trophy.earnedAt!)}',
                        style: TextStyle(color: AppColors.textHint, fontSize: isTablet ? 12 : 10),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isEarned)
            const Text('✅', style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}
