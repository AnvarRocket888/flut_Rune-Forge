import 'package:flutter/cupertino.dart';
import '../core/app_colors.dart';
import '../core/analytics_stub.dart';
import '../models/rune_model.dart';
import '../models/spell_model.dart';
import '../services/game_state.dart';
import '../widgets/animated_background.dart';
import '../widgets/glowing_card.dart';
import '../widgets/animated_emoji.dart';

class ForgeScreen extends StatefulWidget {
  final GameState gameState;
  const ForgeScreen({super.key, required this.gameState});

  @override
  State<ForgeScreen> createState() => _ForgeScreenState();
}

class _ForgeScreenState extends State<ForgeScreen>
    with TickerProviderStateMixin {
  final Set<String> _selectedRuneIds = {};
  bool _isForging = false;
  SpellModel? _forgedSpell;
  late AnimationController _forgeAnimController;
  late Animation<double> _forgeAnimation;

  GameState get gs => widget.gameState;

  @override
  void initState() {
    super.initState();
    AnalyticsStub.screenView('forge');
    _forgeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _forgeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _forgeAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _forgeAnimController.dispose();
    super.dispose();
  }

  void _toggleRune(String id) {
    setState(() {
      if (_selectedRuneIds.contains(id)) {
        _selectedRuneIds.remove(id);
      } else {
        if (_selectedRuneIds.length < 5) {
          _selectedRuneIds.add(id);
        }
      }
    });
  }

  void _forge() {
    final selectedRunes = gs.runes.where((r) => _selectedRuneIds.contains(r.id)).toList();
    if (selectedRunes.length < 2) return;

    setState(() => _isForging = true);
    _forgeAnimController.forward().then((_) {
      final spell = gs.forgeSpell(selectedRunes);
      setState(() {
        _isForging = false;
        _forgedSpell = spell;
        _selectedRuneIds.clear();
      });
      _forgeAnimController.reset();
    });
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
              CupertinoSliverNavigationBar(
                backgroundColor: AppColors.bgDark.withValues(alpha: 0.8),
                border: null,
                largeTitle: Text(
                  'Forge ⚒️',
                  style: TextStyle(color: AppColors.textGold, fontSize: isTablet ? 28 : 22),
                ),
              ),

              // Instructions
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
                    children: [
                      const AnimatedEmoji(emoji: '🔮', size: 32, rotate: true),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Select 2-5 runes of different elements to forge a spell. Each element combination creates a unique spell!',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: isTablet ? 15 : 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Selected runes display
              if (_selectedRuneIds.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected (${_selectedRuneIds.length}/5)',
                          style: TextStyle(
                            color: AppColors.textGold,
                            fontSize: isTablet ? 17 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _selectedRuneIds.map((id) {
                            final rune = gs.runes.firstWhere((r) => r.id == id);
                            return GestureDetector(
                              onTap: () => _toggleRune(id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.bgCardLight,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${rune.emoji} ${rune.name}',
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(CupertinoIcons.xmark_circle_fill, size: 16, color: AppColors.textHint),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            color: _selectedRuneIds.length >= 2 ? AppColors.accent : AppColors.bgCardLight,
                            borderRadius: BorderRadius.circular(12),
                            onPressed: _selectedRuneIds.length >= 2 ? _forge : null,
                            child: Text(
                              _selectedRuneIds.length >= 2 ? '⚒️ Forge Spell' : 'Select at least 2 runes',
                              style: TextStyle(
                                color: _selectedRuneIds.length >= 2 ? AppColors.bgDark : AppColors.textHint,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Available runes header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20, vertical: 8),
                  child: Text(
                    'Available Runes',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isTablet ? 20 : 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // Rune grid for selection
              if (gs.runes.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Text('📦', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          'No runes to forge with.\nCollect some runes first!',
                          style: TextStyle(color: AppColors.textHint, fontSize: isTablet ? 17 : 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 36 : 12),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 5 : 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.78,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final rune = gs.runes[index];
                        final isSelected = _selectedRuneIds.contains(rune.id);
                        return _SelectableRuneCard(
                          rune: rune,
                          isSelected: isSelected,
                          onTap: () => _toggleRune(rune.id),
                        );
                      },
                      childCount: gs.runes.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Active spells
              if (gs.spells.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20, vertical: 8),
                    child: Text(
                      'Forged Spells 🪄',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: isTablet ? 20 : 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final spell = gs.spells[gs.spells.length - 1 - index];
                      return _SpellCard(
                        spell: spell,
                        isTablet: isTablet,
                        onToggle: () {
                          gs.toggleSpell(spell.id);
                          setState(() {});
                        },
                        onDelete: () {
                          gs.deleteSpell(spell.id);
                          setState(() {});
                        },
                      );
                    },
                    childCount: gs.spells.length,
                  ),
                ),
              ],

              SliverToBoxAdapter(child: SizedBox(height: mq.padding.bottom + 100)),
            ],
          ),

          // Forging animation overlay
          if (_isForging) _buildForgingOverlay(isTablet),

          // Spell result overlay
          if (_forgedSpell != null) _buildSpellResult(isTablet),
        ],
      ),
    );
  }

  Widget _buildForgingOverlay(bool isTablet) {
    return AnimatedBuilder(
      listenable: _forgeAnimation,
      builder: (context, _) {
        return Container(
          color: AppColors.bgDark.withValues(alpha: 0.8 * _forgeAnimation.value),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.rotate(
                  angle: _forgeAnimation.value * 6.28,
                  child: Transform.scale(
                    scale: 1 + _forgeAnimation.value * 0.5,
                    child: const Text('⚒️', style: TextStyle(fontSize: 72)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Forging...',
                  style: TextStyle(
                    color: AppColors.textGold,
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpellResult(bool isTablet) {
    return GestureDetector(
      onTap: () => setState(() => _forgedSpell = null),
      child: Container(
        color: AppColors.bgDark.withValues(alpha: 0.85),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              width: isTablet ? 360 : 300,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent),
                boxShadow: [
                  BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 30),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Spell Forged!', style: TextStyle(color: AppColors.textGold, fontSize: isTablet ? 24 : 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  Text(_forgedSpell!.emoji, style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  Text(_forgedSpell!.name, style: TextStyle(color: AppColors.accent, fontSize: isTablet ? 22 : 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(_forgedSpell!.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Effect: ${_forgedSpell!.effect}', style: const TextStyle(color: AppColors.accent, fontSize: 13)),
                  ),
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

class _SelectableRuneCard extends StatelessWidget {
  final RuneModel rune;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableRuneCard({
    required this.rune,
    required this.isSelected,
    required this.onTap,
  });

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? _rarityColor.withValues(alpha: 0.15) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.accent : _rarityColor.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              const Align(
                alignment: Alignment.topRight,
                child: Icon(CupertinoIcons.checkmark_circle_fill, color: AppColors.accent, size: 18),
              ),
            Text(rune.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Text(
              rune.name,
              style: TextStyle(color: _rarityColor, fontSize: 12, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(rune.elementEmoji, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SpellCard extends StatelessWidget {
  final SpellModel spell;
  final bool isTablet;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _SpellCard({
    required this.spell,
    required this.isTablet,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GlowingCard(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16, vertical: 4),
      glowColor: spell.isActive ? AppColors.success : AppColors.border,
      child: Row(
        children: [
          Text(spell.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spell.name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: isTablet ? 17 : 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  spell.effect,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (spell.isActive ? AppColors.success : AppColors.textHint).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    spell.isActive ? '🟢 Active' : '⚫ Inactive',
                    style: TextStyle(
                      color: spell.isActive ? AppColors.success : AppColors.textHint,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 32,
                onPressed: onToggle,
                child: Icon(
                  spell.isActive ? CupertinoIcons.pause_circle : CupertinoIcons.play_circle,
                  color: spell.isActive ? AppColors.warning : AppColors.success,
                  size: 28,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 32,
                onPressed: onDelete,
                child: const Icon(CupertinoIcons.trash, color: AppColors.error, size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
