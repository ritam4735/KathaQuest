import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/story_model.dart';
import '../state/game_state.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/pause_dialog.dart';
import '../features/comic/comic_reader_view.dart';
import '../features/minigames/mg1_forest_walk.dart';
import '../features/minigames/mg2_race_begins.dart';
import '../features/minigames/mg3_rhythm_steps.dart';
import '../features/minigames/mg4_final_sprint.dart';
import '../features/quiz/quiz_view.dart';
import 'reward_screen.dart';

class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key});

  void _showPauseDialog(BuildContext context, GameState gameState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PauseDialog(
        onResume: () => Navigator.of(ctx).pop(),
        onRestartStep: () {
          Navigator.of(ctx).pop();
          // Trigger a re-render of current step
        },
        onExitToLibrary: () {
          Navigator.of(ctx).pop();
          gameState.exitStoryToLibrary();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final currentStory = gameState.currentStory;
    final currentStep = gameState.currentStep;

    if (currentStory == null || currentStep == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No active story found.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Return to Library'),
              ),
            ],
          ),
        ),
      );
    }

    final isHindi = gameState.isHindi;
    final storyTitle = isHindi ? currentStory.titleRegional : currentStory.titleEn;

    // Build the specific view according to step type
    Widget stepWidget;

    switch (currentStep.type) {
      case StoryStepType.comic:
        stepWidget = ComicReaderView(
          step: currentStep as ComicStep,
          onContinue: () => gameState.nextStep(),
        );
        break;

      case StoryStepType.miniGame:
        final miniGameStep = currentStep as MiniGameStep;
        switch (miniGameStep.gameType) {
          case MiniGameType.forestWalk:
            stepWidget = ForestWalkMiniGame(
              step: miniGameStep,
              onComplete: (score) => gameState.completeMiniGame(score),
            );
            break;
          case MiniGameType.raceBegins:
            stepWidget = RaceBeginsMiniGame(
              step: miniGameStep,
              onComplete: (score) => gameState.completeMiniGame(score),
            );
            break;
          case MiniGameType.rhythmSteps:
            stepWidget = RhythmStepsMiniGame(
              step: miniGameStep,
              onComplete: (score) => gameState.completeMiniGame(score),
            );
            break;
          case MiniGameType.finalSprint:
            stepWidget = FinalSprintMiniGame(
              step: miniGameStep,
              onComplete: (score) => gameState.completeMiniGame(score),
            );
            break;
        }
        break;

      case StoryStepType.quiz:
        stepWidget = QuizView(
          step: currentStep as QuizStep,
          onComplete: (correct, total) {
            gameState.recordQuizResult(
              correctAnswers: correct,
              totalQuestions: total,
            );
          },
        );
        break;

      case StoryStepType.reward:
        final rewardStep = currentStep as RewardStep;
        gameState.finishStory(badge: rewardStep.badgeName);

        stepWidget = RewardScreen(
          step: rewardStep,
          onReplay: () => gameState.startStory(currentStory),
          onReturnToLibrary: () {
            gameState.exitStoryToLibrary();
            Navigator.of(context).pop();
          },
        );
        break;
    }

    // Wrap with custom story app bar unless on reward screen (which is full-screen celebration)
    final isReward = currentStep.type == StoryStepType.reward;

    return Scaffold(
      appBar: isReward
          ? null
          : CustomStoryAppBar(
              title: storyTitle,
              onPausePressed: () => _showPauseDialog(context, gameState),
            ),
      body: stepWidget,
    );
  }
}
