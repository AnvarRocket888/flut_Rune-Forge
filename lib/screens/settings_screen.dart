import 'package:flutter/cupertino.dart';
import '../core/app_colors.dart';
import '../core/analytics_stub.dart';
import '../services/game_state.dart';
import '../widgets/animated_background.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  final GameState gameState;
  const SettingsScreen({super.key, required this.gameState});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  bool _notificationsEnabled = false;
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  GameState get gs => widget.gameState;

  @override
  void initState() {
    super.initState();
    AnalyticsStub.screenView('settings');
    _nameController = TextEditingController(text: gs.profile.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveName() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty && name != gs.profile.name) {
      gs.updateName(name);
      AnalyticsStub.profileUpdated();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.shortestSide > 600;

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
                'Settings ⚙️',
                style: TextStyle(color: AppColors.textGold, fontSize: isTablet ? 28 : 22),
              ),
            ),

            // Profile section
            _sectionHeader('Profile', isTablet),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16, vertical: 4),
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Display Name',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _nameController,
                      style: TextStyle(color: AppColors.textPrimary, fontSize: isTablet ? 17 : 15),
                      placeholder: 'Enter your name',
                      placeholderStyle: const TextStyle(color: AppColors.textHint),
                      decoration: BoxDecoration(
                        color: AppColors.bgCardLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(12),
                      onSubmitted: (_) => _saveName(),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(10),
                        onPressed: _saveName,
                        child: const Text(
                          'Save Name',
                          style: TextStyle(color: AppColors.bgDark, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Notifications section
            _sectionHeader('Notifications', isTablet),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16, vertical: 4),
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _toggleRow(
                      '🔔 Push Notifications',
                      'Get reminders for daily rune collection',
                      _notificationsEnabled,
                      (val) {
                        setState(() => _notificationsEnabled = val);
                        AnalyticsStub.settingsChanged('notifications', val.toString());
                        // TODO: Implement push notifications
                      },
                      isTablet,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Container(height: 0.5, color: AppColors.border),
                    ),
                    _toggleRow(
                      '🔊 Sound Effects',
                      'Play sounds for actions',
                      _soundEnabled,
                      (val) {
                        setState(() => _soundEnabled = val);
                        AnalyticsStub.settingsChanged('sound', val.toString());
                      },
                      isTablet,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Container(height: 0.5, color: AppColors.border),
                    ),
                    _toggleRow(
                      '📳 Haptic Feedback',
                      'Vibrate on interactions',
                      _hapticsEnabled,
                      (val) {
                        setState(() => _hapticsEnabled = val);
                        AnalyticsStub.settingsChanged('haptics', val.toString());
                      },
                      isTablet,
                    ),
                  ],
                ),
              ),
            ),

            // Appearance section
            _sectionHeader('Appearance', isTablet),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16, vertical: 4),
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _infoRow('🎨 Theme', 'Dark Tower', isTablet),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Container(height: 0.5, color: AppColors.border),
                    ),
                    _infoRow('🖋️ Font', 'SF Pro Display', isTablet),
                  ],
                ),
              ),
            ),

            // Data section
            _sectionHeader('Data', isTablet),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16, vertical: 4),
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _infoRow('📦 Runes', '${gs.totalRunes}', isTablet),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Container(height: 0.5, color: AppColors.border),
                    ),
                    _infoRow('🪄 Spells', '${gs.spells.length}', isTablet),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Container(height: 0.5, color: AppColors.border),
                    ),
                    _infoRow('⭐ Total XP', '${gs.profile.xp}', isTablet),
                  ],
                ),
              ),
            ),

            // Legal section
            _sectionHeader('Legal', isTablet),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.shield_lefthalf_fill,
                          color: AppColors.accent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        color: AppColors.textHint,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Reset button (dangerous)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16, vertical: 20),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  onPressed: () => _confirmReset(isTablet),
                  child: const Text(
                    '🗑️ Reset All Data',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
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

  Widget _sectionHeader(String title, bool isTablet) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          left: isTablet ? 44 : 20,
          top: 16,
          bottom: 4,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: AppColors.textHint,
            fontSize: isTablet ? 14 : 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    );
  }

  Widget _toggleRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: AppColors.textPrimary, fontSize: isTablet ? 16 : 14, fontWeight: FontWeight.w500)),
                Text(subtitle, style: TextStyle(color: AppColors.textHint, fontSize: isTablet ? 13 : 11)),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: AppColors.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textPrimary, fontSize: isTablet ? 16 : 14)),
          Text(value, style: TextStyle(color: AppColors.textSecondary, fontSize: isTablet ? 16 : 14)),
        ],
      ),
    );
  }

  void _confirmReset(bool isTablet) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text('This will erase all your runes, spells, achievements, and progress. This cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Reset'),
            onPressed: () {
              gs.resetAllData();
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
