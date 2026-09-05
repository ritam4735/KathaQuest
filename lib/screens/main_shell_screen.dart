import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/game_state.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_dashboard_screen.dart';
import 'library_screen.dart';
import 'adventure_map_screen.dart';
import 'achievements_screen.dart';
import 'parent_corner_screen.dart';
import 'bazaar_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _previousIndex = 0;

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final currentIndex = gameState.currentTabIndex;
    final isForward = currentIndex >= _previousIndex;
    _previousIndex = currentIndex;

    final List<Widget> screens = [
      const HomeDashboardScreen(),     // Tab 0: Home
      const LibraryScreen(),           // Tab 1: Library
      const AdventureMapScreen(),      // Tab 2: Map
      const BazaarScreen(),            // Tab 3: Bazaar Coin Shop
      const AchievementsScreen(),      // Tab 4: Profile / Awards
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final offsetTween = Tween<Offset>(
            begin: Offset(isForward ? 0.20 : -0.20, 0),
            end: Offset.zero,
          );
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: offsetTween.animate(animation),
              child: child,
            ),
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

