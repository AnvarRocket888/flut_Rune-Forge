import 'package:flutter/cupertino.dart';
import '../core/app_colors.dart';
import '../core/app_constants.dart';
import '../core/analytics_stub.dart';
import '../services/game_state.dart';
import '../widgets/animated_background.dart';
import '../widgets/glowing_card.dart';
import '../widgets/animated_emoji.dart';
import '../widgets/xp_progress_bar.dart';
import '../widgets/stat_card.dart';
import '../models/rune_model.dart';
import 'rune_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final GameState gameState;
  const HomeScreen({super.key, required this.gameState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _greetingController;
  late final Animation<Offset> _greetingSlide;
  RuneModel? _newRune;
  bool _showNewRune = false;

  GameState get gs => widget.gameState;

  @override
  void initState() {
    super.initState();
    AnalyticsStub.screenView('home');

    _greetingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _greetingSlide = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _greetingController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _greetingController.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Good night';
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String get _greetingEmoji {
    final hour = DateTime.now().hour;
    if (hour < 6) return '🌙';
    if (hour < 12) return '☀️';
    if (hour < 18) return '🌤️';
    return '🌅';
  }

  void _collectRune() {
    if (!gs.canDropRune) return;
    final rune = gs.collectRune();
    if (rune != null) {
      setState(() {
        _newRune = rune;
        _showNewRune = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.shortestSide > 600;

    return AnimatedBackground(
      child: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: mq.padding.top + 16)),

              // Greeting
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _greetingSlide,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_greeting $_greetingEmoji',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: isTablet ? 18 : 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              gs.profile.name,
                              style: TextStyle(
                                color: AppColors.textGold,
                                fontSize: isTablet ? 34 : 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        // Date badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const AnimatedEmoji(emoji: '🌙', size: 18, pulse: true),
                              const SizedBox(width: 6),
                              Text(
                                _formattedDate(),
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: isTablet ? 14 : 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Dream Guide card
              SliverToBoxAdapter(
                child: GlowingCard(
                  margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16),
                  child: Row(
                    children: [
                      const AnimatedEmoji(emoji: '🌟', size: 44, bounce: true, pulse: true),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rune Guide ⭐',
                              style: TextStyle(
                                color: AppColors.textGold,
                                fontSize: isTablet ? 20 : 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getGuideMessage(),
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: isTablet ? 15 : 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Stats row
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          emoji: '🔥',
                          value: '${gs.profile.currentStreak}',
                          label: 'Day Streak',
                          accentColor: AppColors.elementFire,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          emoji: '📦',
                          value: '${gs.totalRunes}',
                          label: 'Runes',
                          accentColor: AppColors.rarityEpic,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          emoji: '⭐',
                          value: '${gs.profile.xp}',
                          label: 'XP',
                          accentColor: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Level progress
              SliverToBoxAdapter(
                child: GlowingCard(
                  margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text('⭐ ', style: TextStyle(fontSize: 16)),
                              Text(
                                AppConstants.levelTitle(gs.profile.level),
                                style: TextStyle(
                                  color: AppColors.textGold,
                                  fontSize: isTablet ? 17 : 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${gs.profile.xp} XP',
                            style: TextStyle(
                              color: AppColors.textGold,
                              fontSize: isTablet ? 17 : 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
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

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Collect Rune button
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16),
                  child: _buildCollectButton(isTablet),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Energy bar
              SliverToBoxAdapter(
                child: GlowingCard(
                  margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16),
                  glowColor: AppColors.elementSpirit,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Energy ⚡',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: isTablet ? 17 : 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${gs.profile.energy} / ${AppConstants.maxEnergy}',
                            style: TextStyle(
                              color: AppColors.elementSpirit,
                              fontSize: isTablet ? 15 : 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildEnergyBar(),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Recent runes
              if (gs.runes.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
                    child: Text(
                      'Recent Runes ✨',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: isTablet ? 20 : 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: isTablet ? 150 : 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 36 : 12),
                      itemCount: gs.runes.length > 10 ? 10 : gs.runes.length,
                      itemBuilder: (context, index) {
                        final rune = gs.runes[gs.runes.length - 1 - index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: SizedBox(
                            width: isTablet ? 110 : 90,
                            child: _RuneMiniCard(
                              rune: rune,
                              onTap: () => _showRuneDetail(rune),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Quote
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 32),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      gs.randomQuote,
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: isTablet ? 15 : 13,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: mq.padding.bottom + 100)),
            ],
          ),

          // New rune popup
          if (_showNewRune && _newRune != null)
            _buildNewRuneOverlay(isTablet),
        ],
      ),
    );
  }

  Widget _buildCollectButton(bool isTablet) {
    final canCollect = gs.canDropRune;

    return GestureDetector(
      onTap: canCollect ? _collectRune : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 14),
        decoration: BoxDecoration(
          gradient: canCollect
              ? const LinearGradient(colors: [AppColors.accentDark, AppColors.accent, AppColors.accentBright])
              : null,
          color: canCollect ? null : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(14),
          boxShadow: canCollect
              ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 16)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedEmoji(
              emoji: canCollect ? '✨' : '⏳',
              size: isTablet ? 24 : 20,
              pulse: canCollect,
            ),
            const SizedBox(width: 10),
            Text(
              canCollect ? 'Collect Rune' : _formatTimeRemaining(),
              style: TextStyle(
                color: canCollect ? AppColors.bgDark : AppColors.textHint,
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyBar() {
    final progress = gs.profile.energy / AppConstants.maxEnergy;
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0, 1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              colors: [AppColors.elementSpirit, AppColors.accentBright],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewRuneOverlay(bool isTablet) {
    return GestureDetector(
      onTap: () => setState(() => _showNewRune = false),
      child: Container(
        color: AppColors.bgDark.withValues(alpha: 0.8),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              width: isTablet ? 320 : 280,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _rarityColor(_newRune!.rarity)),
                boxShadow: [
                  BoxShadow(
                    color: _rarityColor(_newRune!.rarity).withValues(alpha: 0.4),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('New Rune Found!', style: TextStyle(color: AppColors.textGold, fontSize: isTablet ? 22 : 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  Text(_newRune!.emoji, style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  Text(_newRune!.name, style: TextStyle(color: _rarityColor(_newRune!.rarity), fontSize: isTablet ? 22 : 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: _rarityColor(_newRune!.rarity).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_newRune!.rarityLabel, style: TextStyle(color: _rarityColor(_newRune!.rarity), fontSize: 13)),
                  ),
                  const SizedBox(height: 8),
                  Text(_newRune!.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Text('Tap to continue', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _rarityColor(RuneRarity rarity) {
    switch (rarity) {
      case RuneRarity.common: return AppColors.rarityCommon;
      case RuneRarity.rare: return AppColors.rarityRare;
      case RuneRarity.epic: return AppColors.rarityEpic;
      case RuneRarity.legendary: return AppColors.rarityLegendary;
    }
  }

  void _showRuneDetail(RuneModel rune) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => RuneDetailScreen(rune: rune, gameState: gs),
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[now.month - 1]} ${now.day}';
  }

  String _formatTimeRemaining() {
    final remaining = gs.timeUntilNextDrop;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return 'Next rune in ${minutes}m ${seconds}s';
  }

  String _getGuideMessage() {
    if (gs.totalRunes == 0) return 'Welcome! Collect your first rune to begin! ✨';
    if (gs.totalRunes < 5) return 'Great start! Keep collecting runes! 🌟';
    if (gs.profile.currentStreak >= 3) return 'Amazing streak! You\'re on fire! 🔥';
    if (gs.completedFloors > 0) return 'Your tower grows stronger! Keep building! 🏰';
    return 'Your collection grows! Forge some spells! 🪄';
  }
}

class _RuneMiniCard extends StatelessWidget {
  final RuneModel rune;
  final VoidCallback? onTap;

  const _RuneMiniCard({required this.rune, this.onTap});

  Color get _rarityColor {
    switch (rune.rarity) {
      case RuneRarity.common: return AppColors.rarityCommon;
      case RuneRarity.rare: return AppColors.rarityRare;
      case RuneRarity.epic: return AppColors.rarityEpic;
      case RuneRarity.legendary: return AppColors.rarityLegendary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _rarityColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(rune.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              rune.name,
              style: TextStyle(color: _rarityColor, fontSize: 11, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              rune.elementEmoji,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
