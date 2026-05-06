import 'package:flutter/cupertino.dart';
import 'services/storage_service.dart';
import 'services/feedback_service.dart';
import 'services/game_state.dart';
import 'screens/welcome_screen.dart';
import 'core/app_theme.dart';
import 'app.dart';

class ClearApp extends StatefulWidget {
  const ClearApp({super.key});

  @override
  State<ClearApp> createState() => _ClearAppState();
}

class _ClearAppState extends State<ClearApp> {
  late GameState _gameState;
  bool _initialized = false;
  bool _showWelcome = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await StorageService.init();
    FeedbackService.init();
    final gameState = GameState();
    await gameState.loadState();
    setState(() {
      _gameState = gameState;
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const CupertinoApp(
        debugShowCheckedModeBanner: false,
        home: CupertinoPageScaffold(
          child: Center(child: CupertinoActivityIndicator()),
        ),
      );
    }

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

    return RuneForgeApp(gameState: _gameState);
  }
}
