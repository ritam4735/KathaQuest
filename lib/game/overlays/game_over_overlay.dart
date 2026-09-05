import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../core/katha_flame_game.dart';

/// Game Over failure overlay displaying score, reason, and restart option.
class GameOverOverlay extends StatelessWidget {
  final KathaFlameGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final reason = game.stateMachine.failureReason ?? 'Timo needs another attempt!';
    final score = game.scoreManager.score;
    final target = game.targetScore;

    return Container(
      color: Colors.black.withOpacity(0.65),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.97),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFEF5350), width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF5350).withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🐢💭', style: TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(height: 14),

                const Text(
                  'Keep Going! 🌟',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  reason,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFC62828),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Score card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Score Earned', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
                          const SizedBox(height: 2),
                          Text('$score ⭐', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        ],
                      ),
                      Container(width: 1, height: 30, color: Colors.grey.shade300),
                      Column(
                        children: [
                          const Text('Target', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
                          const SizedBox(height: 2),
                          Text('$target ⭐', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Retry Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.refresh_rounded, size: 24),
                    label: const Text(
                      'Try Again',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () => game.restartSession(),
                  ),
                ),
                if (game.onExitRequested != null) ...[
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: game.onExitRequested,
                    child: const Text(
                      'Return to Story',
                      style: TextStyle(color: AppTheme.textMedium, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
