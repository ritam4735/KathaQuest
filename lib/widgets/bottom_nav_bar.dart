import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/game_state.dart';

class KathaBottomNavBar extends StatefulWidget {
  const KathaBottomNavBar({super.key});

  @override
  State<KathaBottomNavBar> createState() => _KathaBottomNavBarState();
}

class _KathaBottomNavBarState extends State<KathaBottomNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _bounceControllers;
  late List<Animation<double>> _bounceAnimations;

  static const _tabs = [
    _NavTab(icon: '🏠', label: 'Home'),
    _NavTab(icon: '📖', label: 'Library'),
    _NavTab(icon: '🧭', label: 'Map'),
    _NavTab(icon: '🎁', label: 'Shop'),
    _NavTab(icon: '👧', label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _bounceControllers = List.generate(
      _tabs.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _bounceAnimations = _bounceControllers.map((c) {
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)),
          weight: 40,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 1.2, end: 0.95).chain(CurveTween(curve: Curves.easeIn)),
          weight: 30,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 0.95, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
          weight: 30,
        ),
      ]).animate(c);
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _bounceControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTabTap(int index, GameState gameState) {
    if (gameState.currentTabIndex == index) return;
    gameState.setTabIndex(index);
    _bounceControllers[index].forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final currentIndex = gameState.currentTabIndex;

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7),
        border: const Border(
          top: BorderSide(color: Color(0xFFEADBBE), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Golden slide indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            bottom: 4,
            left: _indicatorLeft(currentIndex, context),
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withOpacity(0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),

          // Tab items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (i) {
              final isSelected = currentIndex == i;
              return _buildNavItem(
                index: i,
                tab: _tabs[i],
                isSelected: isSelected,
                onTap: () => _onTabTap(i, gameState),
                bounceAnimation: _bounceAnimations[i],
              );
            }),
          ),
        ],
      ),
    );
  }

  double _indicatorLeft(int index, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = screenWidth / _tabs.length;
    return tabWidth * index + (tabWidth - 32) / 2;
  }

  Widget _buildNavItem({
    required int index,
    required _NavTab tab,
    required bool isSelected,
    required VoidCallback onTap,
    required Animation<double> bounceAnimation,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: bounceAnimation,
        builder: (context, child) {
          final scale = isSelected
              ? bounceAnimation.value
              : 1.0;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: isSelected
                ? BoxDecoration(
                    color: const Color(0xFFFFECCC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFFFD54F), width: 1.2),
                  )
                : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: scale,
                  child: Text(
                    tab.icon,
                    style: TextStyle(
                      fontSize: isSelected ? 22 : 20,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tab.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? const Color(0xFF5D4037) : const Color(0xFF8D6E63),
                    fontFamily: 'serif',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NavTab {
  final String icon;
  final String label;
  const _NavTab({required this.icon, required this.label});
}
