import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../state/game_state.dart';

class KathaBottomNavBar extends StatelessWidget {
  const KathaBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final currentIndex = gameState.currentTabIndex;

    return Container(
      height: 72,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: '🏠',
            label: 'Home',
            isSelected: currentIndex == 0,
            onTap: () => gameState.setTabIndex(0),
          ),
          _buildNavItem(
            index: 1,
            icon: '📖',
            label: 'Library',
            isSelected: currentIndex == 1,
            onTap: () => gameState.setTabIndex(1),
          ),
          _buildNavItem(
            index: 2,
            icon: '🧭',
            label: 'Map',
            isSelected: currentIndex == 2,
            onTap: () => gameState.setTabIndex(2),
          ),
          _buildNavItem(
            index: 3,
            icon: '🎁',
            label: 'Shop',
            isSelected: currentIndex == 3,
            onTap: () => gameState.setTabIndex(3),
          ),
          _buildNavItem(
            index: 4,
            icon: '👧',
            label: 'Profile',
            isSelected: currentIndex == 4,
            onTap: () => gameState.setTabIndex(4),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
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
            Text(
              icon,
              style: TextStyle(
                fontSize: isSelected ? 22 : 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? const Color(0xFF5D4037) : const Color(0xFF8D6E63),
                fontFamily: 'serif',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
