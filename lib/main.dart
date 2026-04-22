import 'package:flutter/cupertino.dart';
import 'services/storage_service.dart';
import 'services/feedback_service.dart';
import 'services/game_state.dart';
import 'screens/welcome_screen.dart';
import 'screens/screenshot_slideshow.dart';
import 'screens/video_tour_screen.dart';
import 'core/app_theme.dart';
import 'app.dart';

// ── Dev flags ─────────────────────────────────────────────
// Set ONE to true to enter the corresponding capture mode.
// Both must be false for the normal release build.
const bool kScreenshotMode = false;
const bool kVideoTourMode = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  FeedbackService.init();

  final gameState = GameState();

  if (kScreenshotMode || kVideoTourMode) {
    // Demo mode: skip persistence, load rich fake data
    gameState.loadDemoState();
  } else {
    await gameState.loadState();
  }

  runApp(RuneForgeBootstrap(gameState: gameState));
}

class RuneForgeBootstrap extends StatefulWidget {
  final GameState gameState;

  const RuneForgeBootstrap({super.key, required this.gameState});

  @override
  State<RuneForgeBootstrap> createState() => _RuneForgeBootstrapState();
}

class _RuneForgeBootstrapState extends State<RuneForgeBootstrap> {
  bool _showWelcome = true;

  @override
  Widget build(BuildContext context) {
    // ── Screenshot mode ──────────────────────────────────
    if (kScreenshotMode) {
      return CupertinoApp(
        title: 'OveRune Forging',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: ScreenshotSlideshow(gameState: widget.gameState),
      );
    }

    // ── Video tour mode ──────────────────────────────────
    if (kVideoTourMode) {
      return CupertinoApp(
        title: 'OveRune Forging',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: VideoTourScreen(gameState: widget.gameState),
      );
    }

    // ── Normal mode ──────────────────────────────────────
    if (_showWelcome) {
      return CupertinoApp(
        title: 'OveRune Forging',
        theme: AppTheme.dark,
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
