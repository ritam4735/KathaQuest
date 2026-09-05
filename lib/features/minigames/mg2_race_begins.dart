import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../core/models/story_model.dart';
import '../../game/minigames/steady_runner_game.dart';
import '../../game/overlays/game_hud_overlay.dart';
import '../../game/overlays/game_over_overlay.dart';
import '../../game/overlays/game_pause_overlay.dart';
import '../../game/overlays/game_success_overlay.dart';
import '../../game/overlays/ready_overlay.dart';

/// Mini-Game 2: Steady Pace Challenge ("Steady Runner")
/// Powered by the Flame Game Engine with side-scrolling runner physics,
/// jumping over hurdles/rocks, energy clovers, and maintaining momentum.
class RaceBeginsMiniGame extends StatefulWidget {
  final MiniGameStep step;
  final Function(int score) onComplete;
  final VoidCallback? onPause;

  const RaceBeginsMiniGame({
    super.key,
    required this.step,
    required this.onComplete,
    this.onPause,
  });

  @override
  State<RaceBeginsMiniGame> createState() => _RaceBeginsMiniGameState();
}

class _RaceBeginsMiniGameState extends State<RaceBeginsMiniGame> {
  late final SteadyRunnerGame _game;

  @override
  void initState() {
    super.initState();
    _game = SteadyRunnerGame(
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
      child: GameWidget<SteadyRunnerGame>.controlled(
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
