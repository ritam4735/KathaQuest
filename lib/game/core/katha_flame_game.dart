import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../../core/audio_manager.dart';
import '../../core/haptic_feedback_helper.dart';
import '../managers/game_score_manager.dart';
import 'game_state_machine.dart';
import 'sprite_sheet_manager.dart';

/// Base Flame game for all KathaQuest mini-games.
abstract class KathaFlameGame extends FlameGame with HasCollisionDetection {
  final String gameId;
  final String title;
  final String instructions;
  final int targetScore;
  final int durationSeconds;
  final Function(int score, int stars) onGameCompleted;
  final VoidCallback? onExitRequested;

  late final GameStateMachine stateMachine;
  late final GameScoreManager scoreManager;
  final AudioManager audio = AudioManager();
  final SpriteSheetManager spriteSheets = SpriteSheetManager();

  double remainingTime = 0.0;
  bool isTimedGame = true;

  KathaFlameGame({
    required this.gameId,
    required this.title,
    required this.instructions,
    required this.targetScore,
    required this.durationSeconds,
    required this.onGameCompleted,
    this.onExitRequested,
  }) {
    stateMachine = GameStateMachine();
    scoreManager = GameScoreManager(targetScore: targetScore);
    remainingTime = durationSeconds.toDouble();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await spriteSheets.loadAll();

    // Listen to state changes
    stateMachine.addListener(_onStateChanged);
    scoreManager.addListener(_onScoreChanged);

    // Initial overlay setup
    overlays.add('hud');
    overlays.add('ready');
  }

  void _onStateChanged() {
    switch (stateMachine.state) {
      case MiniGameState.ready:
        overlays.remove('pause');
        overlays.remove('gameOver');
        overlays.remove('success');
        if (!overlays.isActive('ready')) overlays.add('ready');
        break;
      case MiniGameState.playing:
        overlays.remove('ready');
        overlays.remove('pause');
        overlays.remove('gameOver');
        overlays.remove('success');
        break;
      case MiniGameState.paused:
        if (!overlays.isActive('pause')) overlays.add('pause');
        break;
      case MiniGameState.gameOver:
        audio.playWrong();
        HapticHelper.warning();
        if (!overlays.isActive('gameOver')) overlays.add('gameOver');
        break;
      case MiniGameState.completed:
        audio.playFanfare();
        audio.playCheer();
        HapticHelper.success();
        if (!overlays.isActive('success')) overlays.add('success');
        break;
    }
  }

  void _onScoreChanged() {
    if (scoreManager.isDead && stateMachine.isPlaying) {
      stateMachine.triggerGameOver('Timo lost all energy!');
    } else if (scoreManager.score >= targetScore && stateMachine.isPlaying && !isTimedGame) {
      stateMachine.triggerCompletion(stars: scoreManager.calculateStars());
    }
  }

  @override
  void update(double dt) {
    if (!stateMachine.isPlaying) return;
    super.update(dt);

    if (isTimedGame && remainingTime > 0) {
      remainingTime -= dt;
      if (remainingTime <= 0) {
        remainingTime = 0;
        if (scoreManager.score >= targetScore) {
          stateMachine.triggerCompletion(stars: scoreManager.calculateStars());
        } else {
          stateMachine.triggerGameOver('Time is up! Reach the target score next time!');
        }
      }
    }
  }

  /// Called when user taps "Start" on the ready overlay
  void onReadyDismissed() {
    stateMachine.startGame();
    audio.playTap();
  }

  /// Pause game
  void pauseSession() {
    stateMachine.pauseGame();
  }

  /// Resume game
  void resumeSession() {
    stateMachine.resumeGame();
  }

  /// Restart current mini-game
  void restartSession() {
    remainingTime = durationSeconds.toDouble();
    scoreManager.reset();
    resetWorldComponents();
    stateMachine.restart();
  }

  /// Subclasses implement to reset character positions, obstacles, and spawners
  void resetWorldComponents();

  /// Collision hook invoked by collidable player components
  void handleCollision(PositionComponent other) {}

  /// User completed game and wants to continue
  void continueToStory() {
    final stars = scoreManager.calculateStars();
    onGameCompleted(scoreManager.score, stars);
  }

  @override
  void onRemove() {
    stateMachine.removeListener(_onStateChanged);
    scoreManager.removeListener(_onScoreChanged);
    super.onRemove();
  }
}
