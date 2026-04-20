import 'package:flutter/cupertino.dart';
import '../core/app_colors.dart';
import '../core/analytics_stub.dart';
import '../models/rune_model.dart';
import '../services/game_state.dart';
import '../widgets/animated_background.dart';
import '../widgets/rune_card.dart';
import 'rune_detail_screen.dart';

class RuneCollectionScreen extends StatefulWidget {
  final GameState gameState;
  const RuneCollectionScreen({super.key, required this.gameState});

  @override
  State<RuneCollectionScreen> createState() => _RuneCollectionScreenState();
}

class _RuneCollectionScreenState extends State<RuneCollectionScreen> {
  RuneElement? _filterElement;
  RuneRarity? _filterRarity;
  String _searchQuery = '';

  GameState get gs => widget.gameState;

  @override
  void initState() {
    super.initState();
    AnalyticsStub.screenView('rune_collection');
  }

  List<RuneModel> get _filteredRunes {
    var runes = gs.runes.toList();
    if (_filterElement != null) {
      runes = runes.where((r) => r.element == _filterElement).toList();
    }
    if (_filterRarity != null) {
      runes = runes.where((r) => r.rarity == _filterRarity).toList();
    }
    if (_searchQuery.isNotEmpty) {
      runes = runes.where((r) =>
          r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    runes.sort((a, b) => b.collectedAt.compareTo(a.collectedAt));
    return runes;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.shortestSide > 600;
    final filtered = _filteredRunes;

    return AnimatedBackground(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Nav
          CupertinoSliverNavigationBar(
            backgroundColor: AppColors.bgDark.withValues(alpha: 0.8),
            border: null,
            largeTitle: Text(
              'Rune Collection 📦',
              style: TextStyle(color: AppColors.textGold, fontSize: isTablet ? 28 : 22),
            ),
          ),

          // Stats bar
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _miniStat('📦', '${gs.runes.length}', 'Total'),
                  _miniStat('💎', '${gs.runes.where((r) => r.rarity == RuneRarity.rare).length}', 'Rare'),
                  _miniStat('🌌', '${gs.runes.where((r) => r.rarity == RuneRarity.epic).length}', 'Epic'),
                  _miniStat('⭐', '${gs.runes.where((r) => r.rarity == RuneRarity.legendary).length}', 'Legendary'),
                ],
              ),
            ),
          ),

          // Search
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16, vertical: 4),
              child: CupertinoSearchTextField(
                style: const TextStyle(color: AppColors.textPrimary),
                placeholder: 'Search runes...',
                placeholderStyle: const TextStyle(color: AppColors.textHint),
                backgroundColor: AppColors.bgCard,
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
          ),

          // Element filter
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 36 : 12, vertical: 8),
                children: [
                  _filterChip('All', null, _filterElement == null),
                  _filterChip('🔥 Fire', RuneElement.fire, _filterElement == RuneElement.fire),
                  _filterChip('💧 Water', RuneElement.water, _filterElement == RuneElement.water),
                  _filterChip('🌍 Earth', RuneElement.earth, _filterElement == RuneElement.earth),
                  _filterChip('💨 Air', RuneElement.air, _filterElement == RuneElement.air),
                  _filterChip('✨ Spirit', RuneElement.spirit, _filterElement == RuneElement.spirit),
                ],
              ),
            ),
          ),

          // Rarity filter
          SliverToBoxAdapter(
            child: SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 36 : 12, vertical: 4),
                children: [
                  _rarityChip('All', null, _filterRarity == null),
                  _rarityChip('Common', RuneRarity.common, _filterRarity == RuneRarity.common, AppColors.rarityCommon),
                  _rarityChip('Rare', RuneRarity.rare, _filterRarity == RuneRarity.rare, AppColors.rarityRare),
                  _rarityChip('Epic', RuneRarity.epic, _filterRarity == RuneRarity.epic, AppColors.rarityEpic),
                  _rarityChip('Legendary', RuneRarity.legendary, _filterRarity == RuneRarity.legendary, AppColors.rarityLegendary),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Grid
          if (filtered.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const Text('🔍', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      gs.runes.isEmpty ? 'No runes yet!\nCollect your first rune on the Home screen.' : 'No runes match your filter.',
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
                    final rune = filtered[index];
                    return RuneCard(
                      rune: rune,
                      onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => RuneDetailScreen(rune: rune, gameState: gs),
                        ),
                      ).then((_) => setState(() {})),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),

          SliverToBoxAdapter(child: SizedBox(height: mq.padding.bottom + 100)),
        ],
      ),
    );
  }

  Widget _miniStat(String emoji, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 10)),
      ],
    );
  }

  Widget _filterChip(String label, RuneElement? element, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _filterElement = element),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withValues(alpha: 0.2) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
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

  Widget _rarityChip(String label, RuneRarity? rarity, bool selected, [Color? color]) {
    final c = color ?? AppColors.textSecondary;
    return GestureDetector(
      onTap: () => setState(() => _filterRarity = rarity),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.15) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? c : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? c : AppColors.textHint,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
