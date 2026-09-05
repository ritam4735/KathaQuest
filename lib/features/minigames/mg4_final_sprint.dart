import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../core/models/story_model.dart';
import '../../game/minigames/ribbon_sprint_game.dart';
import '../../game/overlays/game_hud_overlay.dart';
import '../../game/overlays/game_over_overlay.dart';
import '../../game/overlays/game_pause_overlay.dart';
import '../../game/overlays/game_success_overlay.dart';
import '../../game/overlays/ready_overlay.dart';

/// Mini-Game 4: Final Sprint to the Ribbon! ("Ribbon Breaker")
/// Powered by the Flame Game Engine with sprint velocity, lane sprinting,
/// and a physical victory ribbon collision before the chasing hare crosses.
class FinalSprintMiniGame extends StatefulWidget {
  final MiniGameStep step;
  final Function(int score) onComplete;
  final VoidCallback? onPause;

  const FinalSprintMiniGame({
    super.key,
    required this.step,
    required this.onComplete,
    this.onPause,
  });

  @override
  State<FinalSprintMiniGame> createState() => _FinalSprintMiniGameState();
}

class _FinalSprintMiniGameState extends State<FinalSprintMiniGame> {
  late final RibbonSprintGame _game;

  @override
  void initState() {
    super.initState();
    _game = RibbonSprintGame(
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
      child: GameWidget<RibbonSprintGame>.controlled(
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
