import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../core/katha_flame_game.dart';

/// Top HUD bar displaying health (hearts), score, combo streak, and pause button.
class GameHudOverlay extends StatelessWidget {
  final KathaFlameGame game;

  const GameHudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: AnimatedBuilder(
          animation: Listenable.merge([game.scoreManager, game.stateMachine]),
          builder: (context, _) {
            final score = game.scoreManager.score;
            final target = game.targetScore;
            final lives = game.scoreManager.lives;
            final maxLives = game.scoreManager.maxLives;
            final combo = game.scoreManager.combo;
            final progress = (target > 0) ? (score / target).clamp(0.0, 1.0) : 0.0;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lives (Hearts) Container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(maxLives, (i) {
                      final hasLife = i < lives;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          hasLife ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: hasLife ? const Color(0xFFE53935) : Colors.grey.shade400,
                          size: 22,
                        ),
                      );
                    }),
                  ),
                ),

                // Center Score & Target Progress
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⭐ ', style: TextStyle(fontSize: 14)),
                          Text(
                            '$score / $target',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textDark,
                            ),
                          ),
                          if (combo >= 2) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9F1C),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${combo}x 🔥',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 100,
                        height: 6,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2EC4B6)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pause Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.pause_rounded, size: 22, color: AppTheme.textDark),
                    onPressed: () => game.pauseSession(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
