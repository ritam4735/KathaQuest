import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/models/story_model.dart';
import '../state/game_state.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/star_rating_bar.dart';

class RewardScreen extends StatelessWidget {
  final RewardStep step;
  final VoidCallback onReplay;
  final VoidCallback onReturnToLibrary;

  const RewardScreen({
    super.key,
    required this.step,
    required this.onReplay,
    required this.onReturnToLibrary,
  });

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final isHindi = gameState.isHindi;
    final stars = gameState.sessionStarsEarned;

    return Scaffold(
      body: ConfettiOverlay(
        isPlaying: true,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF3B0), Color(0xFFFFD166), Color(0xFFFF9F1C)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Title banner
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      isHindi ? '🎉 शाबाश! आपने कर दिखाया!' : '🎉 QUEST COMPLETED!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryDark,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),

                  // Big Badge Trophy
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFB703), width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x44FFB703),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: step.badgeName.contains('Emerald')
                          ? ClipOval(
                              child: Image.asset(
                                'assets/spritesheets/badges/emrald_badge_hero.png',
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Text(
                              step.badgeIcon,
                              style: const TextStyle(fontSize: 72),
                            ),
                    ),
                  ),

                  // Stars Earned
                  Column(
                    children: [
                      StarRatingBar(
                        rating: stars,
                        starSize: 52,
                        animate: true,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isHindi
                            ? '$stars / 3 सितारे अर्जित किए!'
                            : '$stars of 3 Stars Earned!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),

                  // Badge Unlock Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: AppTheme.kidCardDecoration(
                      color: Colors.white,
                      borderColor: AppTheme.secondary,
                      radius: 24,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🏅 ', style: TextStyle(fontSize: 20)),
                            Text(
                              isHindi
                                  ? 'नया पदक: ${step.badgeName}'
                                  : 'Badge Unlocked: ${step.badgeName}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isHindi
                              ? step.badgeDescriptionRegional
                              : step.badgeDescriptionEn,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textDark,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(isHindi ? 'फिर से खेलें' : 'Read Again'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textDark,
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: onReplay,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.home_rounded),
                          label: Text(isHindi ? 'कहानी सूची' : 'Library'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryDark,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: onReturnToLibrary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
