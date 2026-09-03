import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/game_state.dart';
import '../core/app_theme.dart';

class PauseDialog extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestartStep;
  final VoidCallback onExitToLibrary;

  const PauseDialog({
    super.key,
    required this.onResume,
    required this.onRestartStep,
    required this.onExitToLibrary,
  });

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final isHindi = gameState.isHindi;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.kidCardDecoration(
          color: Colors.white,
          borderColor: AppTheme.primary,
          radius: 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⏸️', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 8),
                Text(
                  isHindi ? 'खेल रुका हुआ है' : 'Story Paused',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Audio & Language controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceMuted,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isHindi ? 'ध्वनि संगीत (BGM)' : 'Music (BGM)',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Switch(
                        value: gameState.profile.isBgmEnabled,
                        activeColor: AppTheme.primary,
                        onChanged: (_) => gameState.toggleBgm(),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isHindi ? 'ध्वनि प्रभाव (SFX)' : 'Sound Effects',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Switch(
                        value: gameState.profile.isSfxEnabled,
                        activeColor: AppTheme.secondary,
                        onChanged: (_) => gameState.toggleSfx(),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isHindi ? 'भाषा (Language)' : 'Language',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.translate_rounded, size: 18),
                        label: Text(isHindi ? 'हिंदी' : 'English'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryDark,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => gameState.toggleLanguage(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow_rounded, size: 28),
                label: Text(isHindi ? 'जारी रखें' : 'Resume Story'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: onResume,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: Text(isHindi ? 'कदम पुनः शुरू करें' : 'Restart Step'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textDark,
                  side: BorderSide(color: Colors.grey.shade300, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: onRestartStep,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.home_rounded, color: Color(0xFFE76F51)),
              label: Text(
                isHindi ? 'कहानी सूची में वापस जाएं' : 'Return to Library',
                style: const TextStyle(
                  color: Color(0xFFE76F51),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: onExitToLibrary,
            ),
          ],
        ),
      ),
    );
  }
}
