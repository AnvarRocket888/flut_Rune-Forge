import 'package:flutter/cupertino.dart';
import '../core/app_colors.dart';
import '../models/rune_model.dart';
import '../services/game_state.dart';
import '../widgets/animated_background.dart';

class RuneDetailScreen extends StatefulWidget {
  final RuneModel rune;
  final GameState gameState;

  const RuneDetailScreen({super.key, required this.rune, required this.gameState});

  @override
  State<RuneDetailScreen> createState() => _RuneDetailScreenState();
}

class _RuneDetailScreenState extends State<RuneDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  late RuneModel _rune;

  @override
  void initState() {
    super.initState();
    _rune = widget.rune;
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  Color get _rarityColor {
    switch (_rune.rarity) {
      case RuneRarity.common: return AppColors.rarityCommon;
      case RuneRarity.rare: return AppColors.rarityRare;
      case RuneRarity.epic: return AppColors.rarityEpic;
      case RuneRarity.legendary: return AppColors.rarityLegendary;
    }
  }

  void _upgradeRune() {
    if (widget.gameState.upgradeRune(_rune.id)) {
      final idx = widget.gameState.runes.indexWhere((r) => r.id == _rune.id);
      if (idx != -1) {
        setState(() => _rune = widget.gameState.runes[idx]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.shortestSide > 600;
    final canUpgrade = widget.gameState.profile.energy >= _rune.upgradeCost;

    return CupertinoPageScaffold(
      child: AnimatedBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Nav bar
            CupertinoSliverNavigationBar(
              backgroundColor: AppColors.bgDark.withValues(alpha: 0.8),
              border: null,
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.back, color: AppColors.accent),
                onPressed: () => Navigator.pop(context),
              ),
              largeTitle: Text(
                'Rune Details ✨',
                style: TextStyle(color: AppColors.textGold, fontSize: isTablet ? 28 : 22),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Rune header
            SliverToBoxAdapter(
              child: ScaleTransition(
                scale: CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _rarityColor.withValues(alpha: 0.15),
                        AppColors.bgCard,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _rarityColor.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(color: _rarityColor.withValues(alpha: 0.2), blurRadius: 20),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(_rune.emoji, style: const TextStyle(fontSize: 72)),
                      const SizedBox(height: 12),
                      Text(
                        _rune.name,
                        style: TextStyle(
                          color: _rarityColor,
                          fontSize: isTablet ? 28 : 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _badge(_rune.rarityLabel, _rarityColor),
                          const SizedBox(width: 8),
                          _badge('${_rune.elementEmoji} ${_rune.elementLabel}', AppColors.textSecondary),
                          const SizedBox(width: 8),
                          _badge('Lv ${_rune.level}', AppColors.accent),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Description
            SliverToBoxAdapter(
              child: _infoCard(
                isTablet,
                'Description 📖',
                _rune.description,
              ),
            ),

            // Lore
            SliverToBoxAdapter(
              child: _infoCard(
                isTablet,
                'Lore 📜',
                _rune.lore,
              ),
            ),

            // Passive bonus
            SliverToBoxAdapter(
              child: _infoCard(
                isTablet,
                'Passive Bonus ✨',
                _rune.passiveBonus,
              ),
            ),

            // Stats
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 24, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stats 📊', style: TextStyle(color: AppColors.textGold, fontSize: isTablet ? 18 : 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _statRow('Level', '${_rune.level}', isTablet),
                    _statRow('Element', _rune.elementLabel, isTablet),
                    _statRow('Rarity', _rune.rarityLabel, isTablet),
                    _statRow('Collected', _formatDate(_rune.collectedAt), isTablet),
                    _statRow('Upgrade Cost', '${_rune.upgradeCost} ⚡', isTablet),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Upgrade button
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 24),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  color: canUpgrade ? AppColors.accent : AppColors.bgCardLight,
                  borderRadius: BorderRadius.circular(14),
                  onPressed: canUpgrade ? _upgradeRune : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        canUpgrade ? '⬆️ Upgrade (${_rune.upgradeCost} ⚡)' : 'Not enough energy',
                        style: TextStyle(
                          color: canUpgrade ? AppColors.bgDark : AppColors.textHint,
                          fontSize: isTablet ? 17 : 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Toggle active
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 24, vertical: 12),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  onPressed: () {
                    widget.gameState.toggleRuneActive(_rune.id);
                    final idx = widget.gameState.runes.indexWhere((r) => r.id == _rune.id);
                    if (idx != -1) setState(() => _rune = widget.gameState.runes[idx]);
                  },
                  child: Text(
                    _rune.isActive ? '🔴 Deactivate Rune' : '🟢 Activate Rune',
                    style: TextStyle(
                      color: _rune.isActive ? AppColors.error : AppColors.success,
                      fontSize: isTablet ? 17 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: mq.padding.bottom + 40)),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _infoCard(bool isTablet, String title, String content) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: AppColors.textGold, fontSize: isTablet ? 18 : 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(content, style: TextStyle(color: AppColors.textPrimary, fontSize: isTablet ? 16 : 14)),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, bool isTablet) {
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
