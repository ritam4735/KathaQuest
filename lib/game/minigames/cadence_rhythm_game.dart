import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../components/enemy/hare_enemy.dart';
import '../components/player/tortoise_player.dart';
import '../components/world/scrolling_background.dart';
import '../core/katha_flame_game.dart';
import '../core/sprite_sheet_manager.dart';

/// Musical footstep note flowing down the cadence track.
class RhythmNoteComponent extends PositionComponent {
  final bool isLeftLane;
  final double speed;
  bool isHit = false;
  bool isMissed = false;

  RhythmNoteComponent({
    required this.isLeftLane,
    required Vector2 position,
    required this.speed,
    Vector2? size,
  }) : super(
          position: position,
          size: size ?? Vector2(52, 52),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
  }

  @override
  void render(Canvas canvas) {
    if (isHit) return;
    super.render(canvas);

    // Glowing circle backdrop
    final color = isLeftLane ? const Color(0xFF4DD0E1) : const Color(0xFF81C784);
    final paint = Paint()..color = color.withOpacity(0.9);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x * 0.42, paint);

    // Footstep Emoji
    final textPainter = TextPainter(
      text: TextSpan(
        text: isLeftLane ? '🐾' : '👣',
        style: TextStyle(fontSize: size.x * 0.55),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2),
    );
  }
}

/// Mini-Game 3: Steady March Rhythm ("Cadence Stepper")
/// Rhythm & cadence game where player taps falling footsteps in time while the hare sleeps under the tree.
class CadenceRhythmGame extends KathaFlameGame with TapCallbacks {
  late final TortoisePlayer player;
  late final HareEnemy sleepingHare;
  late final ScrollingBackground background;

  final List<RhythmNoteComponent> _notes = [];
  final Random _random = Random();
  double _spawnTimer = 0.0;
  double _spawnInterval = 1.1;
  double _noteSpeed = 210.0;
  double get _hitLineY => (hasLayout ? size.y : 800.0) * 0.76;

  String? feedbackText;
  Color feedbackColor = const Color(0xFFFF6F00);
  double _feedbackTimer = 0.0;

  int _perfectCount = 0;
  int _goodCount = 0;
  int _missCount = 0;

  int get accuracyPercentage {
    final total = _perfectCount + _goodCount + _missCount;
    if (total == 0) return 100;
    return (((_perfectCount * 100 + _goodCount * 65) / (total * 100)) * 100).round();
  }

  CadenceRhythmGame({
    required super.targetScore,
    required super.durationSeconds,
    required super.onGameCompleted,
    super.onExitRequested,
  }) : super(
          gameId: 'mg_rhythm_steps',
          title: 'Steady March Rhythm',
          instructions: 'Tap the falling footsteps 🐾 right on the green line! Keep steady cadence while the hare snores!',
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final groundY = size.y * 0.76;

    // 1. Apple Tree Meadow Background
    background = ScrollingBackground(
      imagePath: 'assets/images/backgrounds_for_hare_tortoise_story/4.png',
      size: size,
    );
    add(background);

    // 2. Sleeping Hare resting firmly on the ground under the tree (NOT floating in the sky!)
    sleepingHare = HareEnemy(
      position: Vector2(size.x * 0.80, groundY + 8),
      size: Vector2(76, 76),
      initialAnimation: CharacterAnimationState.sleep,
      isFacingRight: true,
    );
    add(sleepingHare);

    // 3. Marching Tortoise on the path
    player = TortoisePlayer(
      position: Vector2(size.x * 0.20, groundY),
      size: Vector2(74, 74),
    );
    player.setFacing(true);
    player.setAnimationState(CharacterAnimationState.walk);
    add(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!stateMachine.isPlaying) return;

    // Difficulty curve: tempo and note speed increase naturally as score approaches target
    final progress = (targetScore > 0) ? (scoreManager.score / targetScore).clamp(0.0, 1.2) : 0.0;
    _noteSpeed = 210.0 + (progress * 70.0);
    _spawnInterval = (1.15 - (progress * 0.40)).clamp(0.72, 1.2);

    // Spawn rhythmic footsteps
    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0.0;
      _spawnFootstep();
    }

    // Check missed notes passing the timing window
    for (final note in _notes) {
      if (!note.isHit && !note.isMissed && note.position.y > _hitLineY + 55.0) {
        note.isMissed = true;
        _missCount++;
        scoreManager.loseLife(1);
        scoreManager.resetCombo();
        audio.playWrong();
        feedbackText = 'MISS! ❌';
        feedbackColor = const Color(0xFFE53935);
        _feedbackTimer = 0.65;

        if (scoreManager.isDead) {
          stateMachine.triggerGameOver('Lost the steady cadence! Keep in step with the rhythm!');
          return;
        }
      }
    }

    // Remove old notes
    _notes.removeWhere((n) {
      if (n.position.y > size.y + 60 || n.isHit) {
        n.removeFromParent();
        return true;
      }
      return false;
    });

    // Handle feedback timer
    if (_feedbackTimer > 0) {
      _feedbackTimer -= dt;
      if (_feedbackTimer <= 0) feedbackText = null;
    }
  }

  void _spawnFootstep() {
    final isLeft = _random.nextBool();
    final laneX = isLeft ? (size.x * 0.38) : (size.x * 0.58);

    final note = RhythmNoteComponent(
      isLeftLane: isLeft,
      position: Vector2(laneX, -30),
      speed: _noteSpeed,
    );
    _notes.add(note);
    add(note);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!stateMachine.isPlaying) return;
    final isLeftTap = event.localPosition.x < size.x / 2;
    _processLaneTap(isLeftTap);
  }

  @visibleForTesting
  void addNoteForTesting(RhythmNoteComponent note) {
    _notes.add(note);
    add(note);
  }

  @visibleForTesting
  void simulateTap(bool isLeft) {
    _processLaneTap(isLeft);
  }

  void _processLaneTap(bool isLeftTap) {
    // Find nearest unhit note in the tapped lane
    RhythmNoteComponent? targetNote;
    double minDistance = 999.0;

    for (final note in _notes) {
      if (note.isLeftLane == isLeftTap && !note.isHit && !note.isMissed) {
        final dist = (note.position.y - _hitLineY).abs();
        if (dist < 65.0 && dist < minDistance) {
          minDistance = dist;
          targetNote = note;
        }
      }
    }

    if (targetNote != null) {
      targetNote.isHit = true;
      if (minDistance <= 22.0) {
        // PERFECT! Timing window
        _perfectCount++;
        scoreManager.addPoints(30, isItem: true);
        audio.playStar();
        feedbackText = 'PERFECT! ⭐';
        feedbackColor = const Color(0xFFFFB300);
      } else {
        // GOOD! Timing window
        _goodCount++;
        scoreManager.addPoints(15, isItem: true);
        audio.playFootstep();
        feedbackText = 'GOOD! 🎵';
        feedbackColor = const Color(0xFF2EC4B6);
      }
      _feedbackTimer = 0.65;

      if (scoreManager.score >= targetScore) {
        stateMachine.triggerCompletion(stars: scoreManager.calculateStars());
      }
    } else {
      // Off-beat tap: tapped when no note was in window
      audio.playTap();
      scoreManager.resetCombo();
      feedbackText = 'EARLY! ⚠️';
      feedbackColor = const Color(0xFFFF9800);
      _feedbackTimer = 0.45;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw Hit Target Line across lanes
    final linePaint = Paint()
      ..color = const Color(0xFF00E676).withOpacity(0.85)
      ..strokeWidth = 4.0;
    canvas.drawLine(
      Offset(size.x * 0.30, _hitLineY),
      Offset(size.x * 0.68, _hitLineY),
      linePaint,
    );

    // Glowing target circles on the line
    final leftCircle = Paint()..color = const Color(0xFF00E676).withOpacity(0.35);
    canvas.drawCircle(Offset(size.x * 0.38, _hitLineY), 28, leftCircle);
    canvas.drawCircle(Offset(size.x * 0.58, _hitLineY), 28, leftCircle);

    // Accuracy display pill on top right
    final accPainter = TextPainter(
      text: TextSpan(
        text: 'Accuracy: $accuracyPercentage%',
        style: const TextStyle(
          color: Color(0xFF2E7D32),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.white70,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    accPainter.paint(canvas, Offset(size.x - accPainter.width - 16, 68));

    // Draw Snoring 'Zzz...' over the resting hare
    final snorePainter = TextPainter(
      text: const TextSpan(
        text: 'Zzz... 😴',
        style: TextStyle(
          color: Color(0xFF4A148C),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.white70,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    snorePainter.paint(
      canvas,
      Offset(size.x * 0.75, _hitLineY - 65),
    );

    // Floating timing feedback text (PERFECT / GOOD / MISS / EARLY)
    if (feedbackText != null) {
      final fbPainter = TextPainter(
        text: TextSpan(
          text: feedbackText!,
          style: TextStyle(
            color: feedbackColor,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            shadows: const [
              Shadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      fbPainter.paint(
        canvas,
        Offset((size.x - fbPainter.width) / 2, _hitLineY - 88),
      );
    }
  }

  @override
  void resetWorldComponents() {
    for (final note in _notes) {
      note.removeFromParent();
    }
    _notes.clear();
    _spawnTimer = 0.0;
    _noteSpeed = 210.0;
    _perfectCount = 0;
    _goodCount = 0;
    _missCount = 0;
    feedbackText = null;
  }
}
