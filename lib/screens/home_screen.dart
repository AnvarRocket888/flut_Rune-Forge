import 'package:flutter/cupertino.dart';
import '../core/app_colors.dart';
import '../core/app_constants.dart';
import '../core/analytics_stub.dart';
import '../services/game_state.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_emoji.dart';
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
              SliverToBoxAdapter(child: SizedBox(height: mq.padding.top + 8)),

              // ── Forge Banner ─────────────────────────────────
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _greetingSlide,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 28 : 20,
                        vertical: isTablet ? 20 : 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.bgMid,
                            const Color(0xFF1A1040),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.borderGold.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Left: title block
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '⚒️  THE FORGE',
                                  style: TextStyle(
                                    color: AppColors.textGold,
                                    fontSize: isTablet ? 24 : 19,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  gs.profile.name,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: isTablet ? 15 : 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Right: level orb
                          _buildLevelOrb(isTablet),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── HERO: Collect Rune Orb ────────────────────────
              SliverToBoxAdapter(
                child: Center(child: _buildCollectOrb(isTablet)),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Energy strip below orb
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 80 : 48),
                  child: _buildCompactEnergyStrip(isTablet),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── Stats 2×2 grid ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16),
                  child: _buildStatGrid(isTablet),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── XP level strip ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16),
                  child: _buildXpStrip(isTablet),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── Rune divider ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 24),
                  child: Row(
                    children: [
                      Expanded(child: Container(height: 1, color: AppColors.borderGold.withValues(alpha: 0.2))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('✦ ᚱ ✦', style: TextStyle(color: AppColors.textGold.withValues(alpha: 0.5), fontSize: 14, letterSpacing: 4)),
                      ),
                      Expanded(child: Container(height: 1, color: AppColors.borderGold.withValues(alpha: 0.2))),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── Daily Omen scroll ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16),
                  child: _buildOmenCard(isTablet),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── Recent Runes ──────────────────────────────────
              if (gs.runes.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
                    child: Row(
                      children: [
                        Text(
                          'Recent Runes',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: isTablet ? 18 : 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${gs.runes.length}',
                            style: TextStyle(color: AppColors.accent, fontSize: isTablet ? 13 : 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
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
                            child: _RuneMiniCard(rune: rune, onTap: () => _showRuneDetail(rune)),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

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

  // ── Redesigned widgets ────────────────────────────────────────

  Widget _buildLevelOrb(bool isTablet) {
    final level = gs.profile.level;
    final title = AppConstants.levelTitle(level);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Transform.scale(scale: v, child: child),
      child: Container(
        width: isTablet ? 80 : 66,
        height: isTablet ? 80 : 66,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.accentDark, AppColors.accent],
          ),
          border: Border.all(color: AppColors.borderGold, width: 1.5),
          boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 14)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lv.$level',
              style: TextStyle(color: AppColors.bgDark, fontSize: isTablet ? 16 : 13, fontWeight: FontWeight.w900),
            ),
            Text(
              title.split(' ').first,
              style: TextStyle(color: AppColors.bgDark.withValues(alpha: 0.75), fontSize: isTablet ? 10 : 8),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectOrb(bool isTablet) {
    final canCollect = gs.canDropRune;
    final orbSize = isTablet ? 160.0 : 130.0;

    return GestureDetector(
      onTap: canCollect ? _collectRune : null,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOut,
        builder: (_, v, child) {
          return Transform.scale(scale: v, child: child);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            if (canCollect)
              Container(
                width: orbSize + 24,
                height: orbSize + 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            // Main orb
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: orbSize,
              height: orbSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: canCollect
                    ? const RadialGradient(colors: [AppColors.accentBright, AppColors.accent, AppColors.accentDark])
                    : RadialGradient(colors: [AppColors.bgCardLight, AppColors.bgCard]),
                boxShadow: canCollect
                    ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.5), blurRadius: 28, spreadRadius: 4)]
                    : [],
                border: Border.all(
                  color: canCollect ? AppColors.borderGold : AppColors.border,
                  width: canCollect ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedEmoji(
                    emoji: canCollect ? '⚡' : '⏳',
                    size: isTablet ? 40 : 32,
                    pulse: canCollect,
                    bounce: canCollect,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    canCollect ? 'COLLECT' : _formatTimeRemaining(),
                    style: TextStyle(
                      color: canCollect ? AppColors.bgDark : AppColors.textHint,
                      fontSize: isTablet ? 14 : 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: canCollect ? 2 : 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (canCollect)
                    Text(
                      'RUNE',
                      style: TextStyle(
                        color: AppColors.bgDark.withValues(alpha: 0.7),
                        fontSize: isTablet ? 12 : 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactEnergyStrip(bool isTablet) {
    final pct = gs.profile.energy / AppConstants.maxEnergy;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('⚡ Energy', style: TextStyle(color: AppColors.textHint, fontSize: isTablet ? 13 : 11)),
            Text('${gs.profile.energy}/${AppConstants.maxEnergy}', style: TextStyle(color: AppColors.elementSpirit, fontSize: isTablet ? 13 : 11, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 5,
          decoration: BoxDecoration(color: AppColors.bgCardLight, borderRadius: BorderRadius.circular(3)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: pct.clamp(0, 1),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: const LinearGradient(colors: [AppColors.elementSpirit, AppColors.accentBright]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatGrid(bool isTablet) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _statTile('🔥', '${gs.profile.currentStreak}', 'Day Streak', AppColors.elementFire, isTablet)),
            const SizedBox(width: 10),
            Expanded(child: _statTile('🏰', '${gs.completedFloors}', 'Floors Built', AppColors.accent, isTablet)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _statTile('📜', '${gs.totalRunes}', 'Runes Found', AppColors.rarityEpic, isTablet)),
            const SizedBox(width: 10),
            Expanded(child: _statTile('🪄', '${gs.activeSpells}', 'Active Spells', AppColors.elementWater, isTablet)),
          ],
        ),
      ],
    );
  }

  Widget _statTile(String emoji, String value, String label, Color accent, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 14, vertical: isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: isTablet ? 24 : 20)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: accent,
                  fontSize: isTablet ? 22 : 19,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              Text(
                label,
                style: TextStyle(color: AppColors.textHint, fontSize: isTablet ? 12 : 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildXpStrip(bool isTablet) {
    final progress = gs.profile.levelProgress;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 18 : 14, vertical: isTablet ? 12 : 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text('⭐', style: TextStyle(fontSize: isTablet ? 18 : 15)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppConstants.levelTitle(gs.profile.level),
                      style: TextStyle(color: AppColors.textGold, fontSize: isTablet ? 14 : 12, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${gs.profile.xpInCurrentLevel} / ${gs.profile.xpForCurrentLevel} XP',
                      style: TextStyle(color: AppColors.textHint, fontSize: isTablet ? 12 : 10),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Container(
                    height: 5,
                    color: AppColors.bgCardLight,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.accentDark, AppColors.accent, AppColors.accentBright]),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOmenCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ᚠ  Daily Omen',
            style: TextStyle(
              color: AppColors.textGold.withValues(alpha: 0.7),
              fontSize: isTablet ? 12 : 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"${gs.randomQuote}"',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: isTablet ? 15 : 13,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
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

  String _formatTimeRemaining() {
    final remaining = gs.timeUntilNextDrop;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return 'Next rune in ${minutes}m ${seconds}s';
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
