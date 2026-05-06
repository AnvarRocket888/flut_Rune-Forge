import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
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

  // Name editing
  bool _editingName = false;
  late TextEditingController _nameController;

  // Audio
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    AnalyticsStub.screenView('profile');
    _nameController = TextEditingController(text: gs.profile.name);
    _recordingPath = gs.profile.wisdomRecordingPath;

    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  // ── Avatar ────────────────────────────────────────────────

  void _showAvatarOptions() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetCtx) => CupertinoActionSheet(
        title: const Text('Change Avatar'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheetCtx);
              if (mounted) _pickImage(ImageSource.camera);
            },
            child: const Text('Take Photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheetCtx);
              if (mounted) _pickImage(ImageSource.gallery);
            },
            child: const Text('Choose from Gallery'),
          ),
          if (gs.profile.avatarPath != null)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(sheetCtx);
                if (mounted) gs.updateAvatar(null);
              },
              child: const Text('Remove Photo'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetCtx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 400);
    if (file != null) {
      gs.updateAvatar(file.path);
    }
  }

  // ── Name editing ──────────────────────────────────────────

  void _saveName() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty && name != gs.profile.name) {
      gs.updateName(name);
    }
    setState(() => _editingName = false);
  }

  // ── Voice recording ───────────────────────────────────────

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      if (path != null) {
        gs.updateWisdomRecording(path);
        setState(() {
          _recordingPath = path;
          _isRecording = false;
        });
      }
    } else {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) return;

      if (_isPlaying) {
        await _player.stop();
        setState(() => _isPlaying = false);
      }

      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/wisdom_recording.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
        path: path,
      );
      setState(() => _isRecording = true);
    }
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _player.stop();
      setState(() => _isPlaying = false);
    } else {
      final path = _recordingPath ?? gs.profile.wisdomRecordingPath;
      if (path == null || !File(path).existsSync()) return;
      await _player.play(DeviceFileSource(path));
      setState(() => _isPlaying = true);
    }
  }

  void _deleteRecording() {
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Delete Recording?'),
        content: const Text('Your Personal Wisdom recording will be permanently deleted.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              final path = _recordingPath ?? gs.profile.wisdomRecordingPath;
              if (path != null) {
                try { File(path).deleteSync(); } catch (_) {}
              }
              gs.updateWisdomRecording(null);
              setState(() => _recordingPath = null);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.shortestSide > 600;
    final hasRecording = (_recordingPath ?? gs.profile.wisdomRecordingPath) != null &&
        File(_recordingPath ?? gs.profile.wisdomRecordingPath!).existsSync();

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
                  // Tappable avatar
                  GestureDetector(
                    onTap: _showAvatarOptions,
                    child: Stack(
                      clipBehavior: Clip.none,
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
                          child: gs.profile.avatarPath != null && File(gs.profile.avatarPath!).existsSync()
                              ? ClipOval(
                                  child: Image.file(
                                    File(gs.profile.avatarPath!),
                                    width: isTablet ? 100 : 80,
                                    height: isTablet ? 100 : 80,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    _avatarEmoji,
                                    style: TextStyle(fontSize: isTablet ? 48 : 38),
                                  ),
                                ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.bgDark, width: 2),
                            ),
                            child: const Icon(CupertinoIcons.camera_fill, color: CupertinoColors.white, size: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Editable name
                  if (_editingName)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 180,
                          child: CupertinoTextField(
                            controller: _nameController,
                            autofocus: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textGold,
                              fontSize: isTablet ? 22 : 18,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bgCardLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            onSubmitted: (_) => _saveName(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _saveName,
                          child: const Icon(CupertinoIcons.checkmark_circle_fill, color: AppColors.accent, size: 28),
                        ),
                      ],
                    )
                  else
                    GestureDetector(
                      onTap: () => setState(() {
                        _nameController.text = gs.profile.name;
                        _editingName = true;
                      }),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            gs.profile.name,
                            style: TextStyle(
                              color: AppColors.textGold,
                              fontSize: isTablet ? 28 : 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(CupertinoIcons.pencil, color: AppColors.textHint, size: 16),
                        ],
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

          // Personal Wisdom
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16, vertical: 6),
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
                    '🎙️ Personal Wisdom',
                    style: TextStyle(
                      color: AppColors.textGold,
                      fontSize: isTablet ? 18 : 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Record a personal message or mantra to listen to whenever you need it.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: isTablet ? 14 : 12),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      // Record button
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _toggleRecording,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isRecording
                                ? CupertinoColors.destructiveRed.withValues(alpha: 0.15)
                                : AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _isRecording ? CupertinoColors.destructiveRed : AppColors.accent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isRecording ? CupertinoIcons.stop_circle : CupertinoIcons.mic_circle,
                                color: _isRecording ? CupertinoColors.destructiveRed : AppColors.accent,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isRecording ? 'Stop' : (hasRecording ? 'Re-record' : 'Record'),
                                style: TextStyle(
                                  color: _isRecording ? CupertinoColors.destructiveRed : AppColors.accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Play button (only if recording exists)
                      if (hasRecording && !_isRecording)
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _togglePlayback,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.elementSpirit.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.elementSpirit, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isPlaying ? CupertinoIcons.pause_circle : CupertinoIcons.play_circle,
                                  color: AppColors.elementSpirit,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isPlaying ? 'Pause' : 'Play',
                                  style: const TextStyle(
                                    color: AppColors.elementSpirit,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Delete button
                      if (hasRecording && !_isRecording && !_isPlaying) ...[
                        const SizedBox(width: 8),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _deleteRecording,
                          child: const Icon(CupertinoIcons.trash, color: CupertinoColors.destructiveRed, size: 20),
                        ),
                      ],
                    ],
                  ),
                  if (_isRecording) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: CupertinoColors.destructiveRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Recording…',
                          style: TextStyle(color: CupertinoColors.destructiveRed, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

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
