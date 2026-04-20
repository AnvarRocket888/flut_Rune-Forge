import 'package:flutter/cupertino.dart';
import 'core/app_colors.dart';
import 'core/app_theme.dart';
import 'services/game_state.dart';
import 'screens/home_screen.dart';
import 'screens/rune_collection_screen.dart';
import 'screens/tower_screen.dart';
import 'screens/profile_screen.dart';

class RuneForgeApp extends StatelessWidget {
  final GameState gameState;

  const RuneForgeApp({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Rune Forge',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: MainTabScaffold(gameState: gameState),
    );
  }
}

class MainTabScaffold extends StatefulWidget {
  final GameState gameState;

  const MainTabScaffold({super.key, required this.gameState});

  @override
  State<MainTabScaffold> createState() => _MainTabScaffoldState();
}

class _MainTabScaffoldState extends State<MainTabScaffold> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.gameState,
      builder: (context, _) {
        return CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            backgroundColor: AppColors.navBg,
            activeColor: AppColors.accent,
            inactiveColor: AppColors.textSecondary,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.flame),
                label: 'Runes',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.building_2_fill),
                label: 'Tower',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person_fill),
                label: 'Profile',
              ),
            ],
          ),
          tabBuilder: (context, index) {
            return CupertinoTabView(
              builder: (context) {
                switch (index) {
                  case 0:
                    return HomeScreen(gameState: widget.gameState);
                  case 1:
                    return RuneCollectionScreen(gameState: widget.gameState);
                  case 2:
                    return TowerScreen(gameState: widget.gameState);
                  case 3:
                    return ProfileScreen(gameState: widget.gameState);
                  default:
                    return HomeScreen(gameState: widget.gameState);
                }
              },
            );
          },
        );
      },
    );
  }
}
