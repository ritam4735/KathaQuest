import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/game_state.dart';
import '../core/app_theme.dart';
import '../core/models/story_model.dart';

class CustomStoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onPausePressed;
  final String title;

  const CustomStoryAppBar({
    super.key,
    required this.onPausePressed,
    required this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(78.0);

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final story = gameState.currentStory;
    final totalSteps = story?.steps.length ?? 6;
    final currentStepIdx = gameState.currentStepIndex;
    final currentStep = gameState.currentStep;
    final canGoBack = currentStepIdx > 0;

    // Panel info if current step is a comic
    String stepDetail = 'Step ${currentStepIdx + 1}/$totalSteps';
    if (currentStep is ComicStep && currentStep.panels.isNotEmpty) {
      stepDetail = 'Panel ${gameState.currentPanelIndex + 1}/${currentStep.panels.length} • Step ${currentStepIdx + 1}/$totalSteps';
    }

    return SafeArea(
      child: Container(
        height: 78,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF8),
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFEADBBE).withOpacity(0.8),
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Back button (supports previous step / previous comic)
            if (canGoBack) ...[
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFEADBBE), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.primary,
                    size: 16,
                  ),
                ),
                tooltip: 'Previous Step',
                onPressed: () => gameState.previousStep(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
              ),
              const SizedBox(width: 4),
            ],

            // Pause button
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEADBBE), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.pause_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              onPressed: onPausePressed,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
            ),
            const SizedBox(width: 8),

            // Middle Column: Story Title + Segmented 6-Stage Progress Indicator
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textDark,
                            fontFamily: 'serif',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3D6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFD54F), width: 1),
                        ),
                        child: Text(
                          stepDetail,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB78103),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Segmented Story Trail Indicator
                  _buildSegmentedProgressTrack(
                    story: story,
                    currentStepIdx: currentStepIdx,
                    totalSteps: totalSteps,
                    gameState: gameState,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Star Counter Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF5),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFD166), width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x22FFD166),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFB703),
                    size: 18,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${gameState.profile.totalStars}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a delightful segmented 6-stage story progress tracker
  Widget _buildSegmentedProgressTrack({
    required Story? story,
    required int currentStepIdx,
    required int totalSteps,
    required GameState gameState,
  }) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final isCompleted = i < currentStepIdx;
        final isCurrent = i == currentStepIdx;

        // Determine icon based on step type
        String icon = '•';
        if (story != null && i < story.steps.length) {
          final type = story.steps[i].type;
          switch (type) {
            case StoryStepType.comic:
              icon = '📖';
              break;
            case StoryStepType.miniGame:
              icon = '🎮';
              break;
            case StoryStepType.quiz:
              icon = '❓';
              break;
            case StoryStepType.reward:
              icon = '🏆';
              break;
          }
        }

        return Expanded(
          child: Row(
            children: [
              // Step Node Circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCurrent ? 22 : 18,
                height: isCurrent ? 22 : 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? const Color(0xFF00A896) // Emerald green completed
                      : isCurrent
                          ? const Color(0xFFFFB703) // Gold active
                          : const Color(0xFFEDE5D0), // Parchment upcoming
                  border: Border.all(
                    color: isCurrent
                        ? const Color(0xFFD35400)
                        : isCompleted
                            ? const Color(0xFF028090)
                            : const Color(0xFFD5CAA8),
                    width: isCurrent ? 2.0 : 1.2,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFFB703).withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? const Icon(Icons.check, size: 11, color: Colors.white)
                    : Text(
                        icon,
                        style: TextStyle(fontSize: isCurrent ? 11 : 9),
                      ),
              ),

              // Connecting track line (between nodes)
              if (i < totalSteps - 1)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 3.5,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFF00A896)
                          : isCurrent
                              ? const Color(0xFFFFD54F)
                              : const Color(0xFFE2D6BE),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
