import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../core/katha_flame_game.dart';

/// Victory celebration dialog showing animated stars, score, coins, and continue button.
class GameSuccessOverlay extends StatelessWidget {
  final KathaFlameGame game;

  const GameSuccessOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final score = game.scoreManager.score;
    final stars = game.scoreManager.calculateStars();
    final coins = game.scoreManager.calculateCoinsReward();
    final items = game.scoreManager.itemsCollected;

    return Container(
      color: Colors.black.withOpacity(0.65),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.98),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFFFD54F), width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withOpacity(0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Star Rating Display (1 to 3 stars)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final earned = i < stars;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        earned ? Icons.star_rounded : Icons.star_border_rounded,
                        color: earned ? const Color(0xFFFFB300) : Colors.grey.shade300,
                        size: (i == 1) ? 46 : 38,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),

                const Text(
                  'Quest Completed! 🏆',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 6),

                const Text(
                  'Slow and steady achieves greatness! 🐢✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMedium,
                  ),
                ),
                const SizedBox(height: 16),

                // Rewards & Stats Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FBE7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFDCE775)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Score', style: TextStyle(fontSize: 11, color: AppTheme.textLight)),
                          const SizedBox(height: 2),
                          Text('$score ⭐', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        ],
                      ),
                      Container(width: 1, height: 28, color: Colors.grey.shade300),
                      Column(
                        children: [
                          const Text('Items', style: TextStyle(fontSize: 11, color: AppTheme.textLight)),
                          const SizedBox(height: 2),
                          Text('$items 🍀', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        ],
                      ),
                      Container(width: 1, height: 28, color: Colors.grey.shade300),
                      Column(
                        children: [
                          const Text('Coins', style: TextStyle(fontSize: 11, color: AppTheme.textLight)),
                          const SizedBox(height: 2),
                          Text('+$coins 🪙', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward_rounded, size: 22),
                    label: const Text(
                      'Continue Story',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () => game.continueToStory(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
