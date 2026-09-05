import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../components/enemy/hare_enemy.dart';
import '../components/player/tortoise_player.dart';
import '../components/world/finish_ribbon.dart';
import '../components/world/scrolling_background.dart';
import '../core/katha_flame_game.dart';
import '../core/sprite_sheet_manager.dart';

/// Mini-Game 4: Final Sprint to the Ribbon! ("Ribbon Breaker")
/// High-octane sprint with authentic stamina pacing, speedometer, opponent AI,
/// and a physical victory ribbon collision before the chasing hare crosses.
class RibbonSprintGame extends KathaFlameGame with TapCallbacks {
  late final TortoisePlayer player;
  late final HareEnemy hare;
  late final FinishRibbon finishRibbon;
  late final ScrollingBackground background;

  // Race distance simulation
  static const double raceDistance = 1000.0;
  double _timoDistance = 0.0;
  double _hareDistance = 60.0; // Hare starts with a slight head start

  // Physical sprint & stamina properties
  double _timoSpeed = 45.0;
  double _hareSpeed = 80.0;
  double _stamina = 100.0; // 0.0 to 100.0
  static const double maxStamina = 100.0;
  static const double staminaTapCost = 12.0;
  static const double staminaRecoveryRate = 24.0; // per second

  bool _isFinished = false;

  double get timoProgress => (_timoDistance / raceDistance).clamp(0.0, 1.0);
  double get hareProgress => (_hareDistance / raceDistance).clamp(0.0, 1.0);
  double get staminaRatio => (_stamina / maxStamina).clamp(0.0, 1.0);

  RibbonSprintGame({
    required super.targetScore,
    required super.durationSeconds,
    required super.onGameCompleted,
    super.onExitRequested,
  }) : super(
          gameId: 'mg_final_sprint',
          title: 'Final Sprint to the Ribbon!',
          instructions: 'Pace your taps to maintain high sprint speed! Don\'t drain all your stamina ⚡ before the finish ribbon! 🏁',
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final lane1Y = size.y * 0.52; // Hare track
    final lane2Y = size.y * 0.72; // Timo track

    // 1. Finish line background
    background = ScrollingBackground(
      imagePath: 'assets/images/backgrounds_for_hare_tortoise_story/5.png',
      size: size,
    );
    add(background);

    // 2. Physical Red Victory Ribbon across finish line
    final finishX = size.x * 0.88;
    finishRibbon = FinishRibbon(
      position: Vector2(finishX, lane2Y),
      size: Vector2(24, 70),
      onRibbonBroken: _onTimoWon,
    );
    add(finishRibbon);

    // 3. Sprinting Hare in Lane 1
    hare = HareEnemy(
      position: Vector2(size.x * 0.20, lane1Y),
      size: Vector2(68, 68),
      initialAnimation: CharacterAnimationState.run,
      isFacingRight: true,
    );
    add(hare);

    // 4. Timo Tortoise in Lane 2
    player = TortoisePlayer(
      position: Vector2(size.x * 0.16, lane2Y),
      size: Vector2(74, 74),
    );
    player.groundY = lane2Y;
    player.setFacing(true);
    player.setAnimationState(CharacterAnimationState.run);
    add(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!stateMachine.isPlaying || _isFinished) return;

    // Passive stamina recovery over time
    _stamina = (_stamina + staminaRecoveryRate * dt).clamp(0.0, maxStamina);

    // Dynamic Hare AI behavior across the race
    if (_hareDistance < 350.0) {
      _hareSpeed = 82.0; // Early strong pace
      hare.setAnimationState(CharacterAnimationState.run);
    } else if (_hareDistance < 680.0) {
      _hareSpeed = 64.0; // Boastful complacency / mid-race lull
      hare.setAnimationState(CharacterAnimationState.walk);
    } else {
      // Final stretch panic sprint
      final isBehind = _timoDistance >= _hareDistance - 30;
      _hareSpeed = isBehind ? 104.0 : 92.0;
      hare.setAnimationState(CharacterAnimationState.run);
    }

    // Natural speed decay towards cruising speed (30 px/s)
    final decayRate = (_stamina < 15.0) ? 38.0 : 22.0;
    _timoSpeed = (_timoSpeed - dt * decayRate).clamp(24.0, 190.0);

    // Advance distances
    _timoDistance += _timoSpeed * dt;
    _hareDistance += _hareSpeed * dt;

    // Update screen positions based on race progress
    final screenW = hasLayout ? size.x : 400.0;
    final trackStartX = screenW * 0.15;
    final trackEndX = screenW * 0.88;

    player.position.x = trackStartX + (timoProgress * (trackEndX - trackStartX));
    hare.position.x = trackStartX + (hareProgress * (trackEndX - trackStartX));

    // Check Defeat: Hare crosses the finish line first!
    if (_hareDistance >= raceDistance && _timoDistance < raceDistance) {
      _isFinished = true;
      hare.setAnimationState(CharacterAnimationState.cheer);
      player.setAnimationState(CharacterAnimationState.idle);
      audio.playWrong();
      stateMachine.triggerGameOver('The Hare crossed the finish line first! Pace your stamina to sprint across the finish!');
      return;
    }

    // Check Victory: Timo reaches the finish ribbon first!
    if (_timoDistance >= raceDistance && !_isFinished) {
      if (!finishRibbon.isBroken) {
        finishRibbon.breakRibbon();
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    simulateSprintTap();
  }

  @visibleForTesting
  void simulateSprintTap() {
    if (!stateMachine.isPlaying || _isFinished) return;

    if (_stamina >= staminaTapCost) {
      // Full stamina sprint impulse!
      _stamina -= staminaTapCost;
      _timoSpeed = (_timoSpeed + 32.0).clamp(24.0, 190.0);
      audio.playFootstep();
      player.setAnimationState(CharacterAnimationState.run);
    } else {
      // Low stamina fatigue: weak push, teaches pacing
      _stamina = max(0.0, _stamina - 4.0);
      _timoSpeed = (_timoSpeed + 8.0).clamp(24.0, 190.0);
      audio.playTap();
    }
  }

  void _onTimoWon() {
    if (_isFinished) return;
    _isFinished = true;

    player.setAnimationState(CharacterAnimationState.win);
    hare.setAnimationState(CharacterAnimationState.surprised);

    // Authentic gameplay score calculation based on race performance:
    // Base 50 points + stamina efficiency bonus (up to 25) + lead margin bonus (up to 25)
    final staminaBonus = (staminaRatio * 25).round();
    final leadMargin = ((_timoDistance - _hareDistance).clamp(0.0, 200.0) / 8).round();
    final earnedScore = 50 + staminaBonus + leadMargin;

    scoreManager.addPoints(earnedScore);
    stateMachine.triggerCompletion(stars: scoreManager.calculateStars());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (!stateMachine.isPlaying && !stateMachine.isReady) return;

    // 1. Race Mini-Map Progress Track at top
    const trackTop = 64.0;
    final trackLeft = size.x * 0.18;
    final trackWidth = size.x * 0.64;

    // Track background line
    final trackPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(trackLeft, trackTop), Offset(trackLeft + trackWidth, trackTop), trackPaint);

    // Hare marker 🐰
    final hareMarkerX = trackLeft + (hareProgress * trackWidth);
    final harePainter = TextPainter(
      text: const TextSpan(text: '🐰', style: TextStyle(fontSize: 16)),
      textDirection: TextDirection.ltr,
    )..layout();
    harePainter.paint(canvas, Offset(hareMarkerX - (harePainter.width / 2), trackTop - 20));

    // Timo marker 🐢
    final timoMarkerX = trackLeft + (timoProgress * trackWidth);
    final timoPainter = TextPainter(
      text: const TextSpan(text: '🐢', style: TextStyle(fontSize: 18)),
      textDirection: TextDirection.ltr,
    )..layout();
    timoPainter.paint(canvas, Offset(timoMarkerX - (timoPainter.width / 2), trackTop - 2));

    // Finish flag 🏁
    final flagPainter = TextPainter(
      text: const TextSpan(text: '🏁', style: TextStyle(fontSize: 16)),
      textDirection: TextDirection.ltr,
    )..layout();
    flagPainter.paint(canvas, Offset(trackLeft + trackWidth - 2, trackTop - 12));

    // 2. Stamina Bar (Bottom Left)
    const barLeft = 18.0;
    final barBottom = size.y * 0.94;
    final barWidth = size.x * 0.44;
    const barHeight = 12.0;

    // Background
    final staminaBgPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(barLeft, barBottom, barWidth, barHeight), const Radius.circular(6)),
      staminaBgPaint,
    );

    // Fill
    final staminaColor = staminaRatio > 0.45
        ? const Color(0xFF00E676)
        : (staminaRatio > 0.20 ? const Color(0xFFFFB300) : const Color(0xFFEF5350));
    final staminaFillPaint = Paint()
      ..color = staminaColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barLeft, barBottom, barWidth * staminaRatio, barHeight),
        const Radius.circular(6),
      ),
      staminaFillPaint,
    );

    final staminaLabelPainter = TextPainter(
      text: TextSpan(
        text: '⚡ STAMINA: ${(_stamina).round()}%',
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    staminaLabelPainter.paint(canvas, Offset(barLeft, barBottom - 16));

    // 3. Speed Meter Gauge (Bottom Right)
    final speedKmH = (_timoSpeed * 0.48).round();
    final speedLabelPainter = TextPainter(
      text: TextSpan(
        text: '🚀 SPEED: $speedKmH km/h',
        style: TextStyle(
          color: _stamina < 15 ? const Color(0xFFFFCC80) : const Color(0xFF80D8FF),
          fontSize: 12,
          fontWeight: FontWeight.w900,
          backgroundColor: Colors.black45,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    speedLabelPainter.paint(canvas, Offset(size.x - speedLabelPainter.width - 18, barBottom - 10));
  }

  @override
  void resetWorldComponents() {
    _isFinished = false;
    _timoDistance = 0.0;
    _hareDistance = 60.0;
    _timoSpeed = 45.0;
    _hareSpeed = 80.0;
    _stamina = 100.0;

    final safeSize = hasLayout ? size : Vector2(400, 800);
    final lane1Y = safeSize.y * 0.52;
    final lane2Y = safeSize.y * 0.72;

    hare.position = Vector2(safeSize.x * 0.20, lane1Y);
    hare.setFacing(true);
    hare.setAnimationState(CharacterAnimationState.run);

    player.position = Vector2(safeSize.x * 0.16, lane2Y);
    player.setFacing(true);
    player.setAnimationState(CharacterAnimationState.run);

    finishRibbon.isBroken = false;
  }
}
