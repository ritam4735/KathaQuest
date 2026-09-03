import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../widgets/magical_speech_bubble.dart';

class MiniGameContainer extends StatelessWidget {
  final String title;
  final String instructions;
  final int currentScore;
  final int targetScore;
  final int remainingSeconds;
  final Widget child;

  const MiniGameContainer({
    super.key,
    required this.title,
    required this.instructions,
    required this.currentScore,
    required this.targetScore,
    required this.remainingSeconds,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentScore / targetScore).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FDF9),
      body: SafeArea(
        child: Column(
          children: [
            // Top Minigame HUD
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Minigame Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      // Timer Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: remainingSeconds < 8
                              ? const Color(0xFFFFE5E5)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: remainingSeconds < 8
                                ? const Color(0xFFE63946)
                                : AppTheme.secondary,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer_rounded,
                              size: 16,
                              color: remainingSeconds < 8
                                  ? const Color(0xFFE63946)
                                  : AppTheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${remainingSeconds}s',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: remainingSeconds < 8
                                    ? const Color(0xFFE63946)
                                    : AppTheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Score Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9E6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.primary, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Text('⭐ ', style: TextStyle(fontSize: 14)),
                            Text(
                              '$currentScore / $targetScore',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Progress Bar to target
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Instructions Hint Bar with Magical Glowing Style
            MagicalHintBanner(instructions: instructions),

            // Game Play Area
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
