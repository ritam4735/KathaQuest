import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/models/story_model.dart';
import '../../core/audio_manager.dart';
import '../../core/app_theme.dart';
import '../../widgets/steady_meter.dart';
import '../../widgets/animated_sprite_widget.dart';
import 'minigame_container.dart';

class RaceBeginsMiniGame extends StatefulWidget {
  final MiniGameStep step;
  final Function(int score) onComplete;

  const RaceBeginsMiniGame({
    super.key,
    required this.step,
    required this.onComplete,
  });

  @override
  State<RaceBeginsMiniGame> createState() => _RaceBeginsMiniGameState();
}

class _RaceBeginsMiniGameState extends State<RaceBeginsMiniGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Timer? _timer;
  late int _remainingSeconds;
  int _score = 0;
  double _needleValue = 0.2; // 0.0 to 1.0 (0.4 - 0.7 is steady)
  bool _isGameOver = false;

  bool get isInSteadyZone => _needleValue >= 0.38 && _needleValue <= 0.68;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.step.durationSeconds;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(_gameTick);

    _animController.repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _finishGame();
        }
      });
    });
  }

  void _gameTick() {
    if (_isGameOver || !mounted) return;

    setState(() {
      // Natural decay towards slow
      _needleValue = (_needleValue - 0.008).clamp(0.05, 0.95);

      // Score bonus when in steady zone
      if (isInSteadyZone) {
        _score += 1;
        if (_score % 10 == 0) {
          AudioManager().playFootstep();
        }
      }
    });

    if (_score >= widget.step.targetScore) {
      _finishGame();
    }
  }

  void _handleTap() {
    if (_isGameOver) return;
    AudioManager().playTap();
    setState(() {
      _needleValue = (_needleValue + 0.12).clamp(0.0, 1.0);
    });
  }

  void _finishGame() {
    if (_isGameOver) return;
    _isGameOver = true;
    _animController.stop();
    _timer?.cancel();

    AudioManager().playCheer();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          '🎉 Steady Pacing Mastered!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐢⚖️', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              'Wonderful! You kept Timo moving with calm, steady determination and scored $_score points!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                widget.onComplete(_score);
              },
              child: const Text('Continue Story! ➡️'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MiniGameContainer(
      title: widget.step.title,
      instructions: widget.step.instructionsEn,
      currentScore: _score,
      targetScore: widget.step.targetScore,
      remainingSeconds: _remainingSeconds,
      child: Stack(
        children: [
          // Background scenic track
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrounds_for_hare_tortoise_story/3.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.82),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Visual race track representation
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Lane 1: Sprinting Hare
                        Row(
                          children: [
                            const AnimatedSpriteWidget(
                              animation: 'hare_run',
                              width: 44,
                              height: 44,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 10,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.orange.shade200),
                                ),
                                child: const Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('💨💨', style: TextStyle(fontSize: 10)),
                                ),
                              ),
                            ),
                            const Text('🏁', style: TextStyle(fontSize: 22)),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Lane 2: Steady Tortoise advancing
                        Row(
                          children: [
                            const AnimatedSpriteWidget(
                              animation: 'tortoise_walk',
                              width: 44,
                              height: 44,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, laneConstraints) {
                                  final progress = (_score / widget.step.targetScore).clamp(0.0, 1.0);
                                  final maxOffset = (laneConstraints.maxWidth - 36).clamp(0.0, double.infinity);
                                  return Stack(
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      Container(
                                        height: 10,
                                        margin: const EdgeInsets.symmetric(horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(color: Colors.green.shade200),
                                        ),
                                      ),
                                      Positioned(
                                        left: 8 + (progress * maxOffset),
                                        child: Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            color: AppTheme.secondary,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppTheme.secondary.withOpacity(0.5),
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Icon(Icons.star, size: 12, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const Text('🏁', style: TextStyle(fontSize: 22)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Steady Meter
                  SteadyMeter(
                    value: _needleValue,
                    isInSteadyZone: isInSteadyZone,
                  ),

              // Big Kid-Friendly Tap Button
              GestureDetector(
                onTap: _handleTap,
                child: Container(
                  width: 220,
                  height: 80,
                  decoration: AppTheme.tactileButtonDecoration(
                    topColor: isInSteadyZone
                        ? const Color(0xFF2EC4B6)
                        : const Color(0xFFFF9F1C),
                    bottomColor: isInSteadyZone
                        ? const Color(0xFF00A896)
                        : const Color(0xFFE76F51),
                    radius: 28,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('🐾', style: TextStyle(fontSize: 32)),
                      SizedBox(width: 12),
                      Text(
                        'TAP STEADY!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
);
  }
}
