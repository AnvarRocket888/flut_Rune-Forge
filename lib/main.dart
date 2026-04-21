import 'package:flutter/cupertino.dart';
import 'services/storage_service.dart';
import 'services/feedback_service.dart';
import 'services/game_state.dart';
import 'screens/welcome_screen.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  FeedbackService.init();

  final gameState = GameState();
  await gameState.loadState();

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
