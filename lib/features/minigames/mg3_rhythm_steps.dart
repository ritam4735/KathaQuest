import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../core/models/story_model.dart';
import '../../game/minigames/cadence_rhythm_game.dart';
import '../../game/overlays/game_hud_overlay.dart';
import '../../game/overlays/game_over_overlay.dart';
import '../../game/overlays/game_pause_overlay.dart';
import '../../game/overlays/game_success_overlay.dart';
import '../../game/overlays/ready_overlay.dart';

/// Mini-Game 3: Steady March Rhythm ("Cadence Stepper")
/// Powered by the Flame Game Engine with accurate beat timing,
/// combo multipliers, and a sleeping hare resting naturally under the tree.
class RhythmStepsMiniGame extends StatefulWidget {
  final MiniGameStep step;
  final Function(int score) onComplete;
  final VoidCallback? onPause;

  const RhythmStepsMiniGame({
    super.key,
    required this.step,
    required this.onComplete,
    this.onPause,
  });

  @override
  State<RhythmStepsMiniGame> createState() => _RhythmStepsMiniGameState();
}

class _RhythmStepsMiniGameState extends State<RhythmStepsMiniGame> {
  late final CadenceRhythmGame _game;

  @override
  void initState() {
    super.initState();
    _game = CadenceRhythmGame(
      targetScore: widget.step.targetScore,
      durationSeconds: widget.step.durationSeconds,
      onGameCompleted: (score, stars) {
        widget.onComplete(score);
      },
      onExitRequested: widget.onPause,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: GameWidget<CadenceRhythmGame>.controlled(
        gameFactory: () => _game,
        overlayBuilderMap: {
          'hud': (context, game) => GameHudOverlay(game: game),
          'ready': (context, game) => ReadyOverlay(game: game),
          'pause': (context, game) => GamePauseOverlay(game: game),
          'gameOver': (context, game) => GameOverOverlay(game: game),
          'success': (context, game) => GameSuccessOverlay(game: game),
        },
      ),
    );
  }
}
