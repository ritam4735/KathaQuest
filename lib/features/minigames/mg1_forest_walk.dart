import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../core/models/story_model.dart';
import '../../game/minigames/sliding_turtle_game.dart';
import '../../game/overlays/game_hud_overlay.dart';
import '../../game/overlays/game_over_overlay.dart';
import '../../game/overlays/game_pause_overlay.dart';
import '../../game/overlays/game_success_overlay.dart';
import '../../game/overlays/ready_overlay.dart';

/// Mini-Game 1: Forest Walk ("Sliding Turtle")
/// Powered by the Flame Game Engine with actual movement physics,
/// obstacle dodging, clover collection, health hearts, and proper game states.
class ForestWalkMiniGame extends StatefulWidget {
  final MiniGameStep step;
  final Function(int score) onComplete;
  final VoidCallback? onPause;

  const ForestWalkMiniGame({
    super.key,
    required this.step,
    required this.onComplete,
    this.onPause,
  });

  @override
  State<ForestWalkMiniGame> createState() => _ForestWalkMiniGameState();
}

class _ForestWalkMiniGameState extends State<ForestWalkMiniGame> {
  late final SlidingTurtleGame _game;

  @override
  void initState() {
    super.initState();
    _game = SlidingTurtleGame(
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
      color: const Color(0xFFE8F5E9),
      child: GameWidget<SlidingTurtleGame>.controlled(
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
