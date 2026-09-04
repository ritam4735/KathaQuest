import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/game_state.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_dashboard_screen.dart';
import 'library_screen.dart';
import 'adventure_map_screen.dart';
import 'achievements_screen.dart';
import 'parent_corner_screen.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final currentIndex = gameState.currentTabIndex;

    final List<Widget> screens = [
      const HomeDashboardScreen(),     // Tab 0: Home
      const LibraryScreen(),           // Tab 1: Library
      const AdventureMapScreen(),      // Tab 2: Map
      const ParentCornerScreen(),      // Tab 3: Shop / Settings
      const AchievementsScreen(),      // Tab 4: Profile / Achievements
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(currentIndex),
          child: screens[currentIndex],
        ),
      ),
      bottomNavigationBar: const KathaBottomNavBar(),
    );
  }
}
