import 'package:flutter/cupertino.dart';
import 'services/storage_service.dart';
import 'services/game_state.dart';
import 'core/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/screenshot_slideshow.dart';
import 'screens/video_tour_screen.dart';
import 'app.dart';

/// Set to [true] to launch in screenshot / demo mode.
/// Every screen will be shown with rich fake data and will
/// auto-advance every 4 seconds so you can take screenshots.
const bool kScreenshotMode = false;

/// Set to [true] to launch the automated promo video tour (~63 s).
/// Each screen appears with demo data and smoothly transitions
/// to the next — just hit record before launching.
const bool kVideoTourMode = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  final gameState = GameState();

  if (kScreenshotMode || kVideoTourMode) {
    // Load rich fake data — no real storage touched
    gameState.loadDemoState();
  } else {
    await gameState.loadState();
  }

  runApp(RuneForgeBootstrap(
    gameState: gameState,
    screenshotMode: kScreenshotMode,
    videoTourMode: kVideoTourMode,
  ));
}

class RuneForgeBootstrap extends StatefulWidget {
  final GameState gameState;
  final bool screenshotMode;
  final bool videoTourMode;

  const RuneForgeBootstrap({
    super.key,
    required this.gameState,
    this.screenshotMode = false,
    this.videoTourMode = false,
  });

  @override
  State<RuneForgeBootstrap> createState() => _RuneForgeBootstrapState();
}

class _RuneForgeBootstrapState extends State<RuneForgeBootstrap> {
  bool _showWelcome = true;

  @override
  Widget build(BuildContext context) {
    // Screenshot mode: skip welcome, go straight to the slideshow
    if (widget.screenshotMode) {
      return CupertinoApp(
        title: 'Rune Forge',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: ScreenshotSlideshow(gameState: widget.gameState),
      );
    }

    // Video tour mode: automated promo tour
    if (widget.videoTourMode) {
      return CupertinoApp(
        title: 'Rune Forge',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: VideoTourScreen(gameState: widget.gameState),
      );
    }

    if (_showWelcome) {
      return CupertinoApp(
        title: 'Rune Forge',
        debugShowCheckedModeBanner: false,
        home: WelcomeScreen(
          onDismiss: () {
            setState(() => _showWelcome = false);
          },
        ),
      );
    }
    return RuneForgeApp(gameState: widget.gameState);
  }
}
