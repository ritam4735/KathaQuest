import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/story_model.dart';
import '../../core/audio_manager.dart';
import '../../core/app_theme.dart';
import '../../core/haptic_feedback_helper.dart';
import '../../state/game_state.dart';
import '../../widgets/animated_sprite_widget.dart';
import '../../widgets/magical_speech_bubble.dart';
import 'minigame_container.dart';
import 'minigame_celebration_dialog.dart';

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

class _FinalSprintMiniGameState extends State<FinalSprintMiniGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Timer? _timer;
  late int _remainingSeconds;
  int _score = 0;
  double _tortoiseProgress = 0.05;
  double _hareProgress = 0.10;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.step.durationSeconds;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(_gameLoop);

    _animController.repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final isPaused = context.read<GameState>().isPaused;
      if (isPaused) return; // Freeze timer countdown while paused

      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _finishGame();
        }
      });
    });
  }

  void _gameLoop() {
    if (_isGameOver || !mounted) return;
    final isPaused = context.read<GameState>().isPaused;
    if (isPaused) return; // Freeze hare sprint while paused

    setState(() {
      // Hare sprints desperately
      _hareProgress = (_hareProgress + 0.007).clamp(0.0, 0.88);
    });

    if (_tortoiseProgress >= 0.90) {
      _finishGame();
    }
  }

  void _handleCheerTap() {
    if (_isGameOver) return;
    final isPaused = context.read<GameState>().isPaused;
    if (isPaused) return;

    HapticHelper.light();
    AudioManager().playFootstep();
    setState(() {
      _score += 5;
      _tortoiseProgress = (_tortoiseProgress + 0.06).clamp(0.0, 0.95);
    });

    if (_tortoiseProgress >= 0.90) {
      _finishGame();
    }
  }

  void _finishGame() {
    if (_isGameOver) return;
    _isGameOver = true;
    _animController.stop();
    _timer?.cancel();

    AudioManager().playFanfare();
    AudioManager().playCheer();

    final gameState = context.read<GameState>();
    MiniGameCelebrationDialog.show(
      context: context,
      score: _score,
      targetScore: widget.step.targetScore,
      emoji: '🏆',
      isHindi: gameState.isHindi,
      onContinue: () => widget.onComplete(_score),
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
      onPause: widget.onPause,
      child: Stack(
        children: [
          // High-Res Finish line background
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrounds_for_hare_tortoise_story/5.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Finish track visualizer
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.96),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Hare Sprint Track
                        Row(
                          children: [
                            const Text('Lane 1', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, trackConstraints) {
                                  final maxOffset = (trackConstraints.maxWidth - 44).clamp(0.0, double.infinity);
                                  return Stack(
                                    children: [
                                      Container(
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                      ),
                                      Positioned(
                                        left: (_hareProgress * maxOffset).clamp(0.0, maxOffset),
                                        child: const AnimatedSpriteWidget(
                                          animation: 'hare_run',
                                          width: 40,
                                          height: 40,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('🏁', style: TextStyle(fontSize: 24)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Tortoise Sprint Track
                        Row(
                          children: [
                            const Text('Lane 2', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, trackConstraints) {
                                  final maxOffset = (trackConstraints.maxWidth - 44).clamp(0.0, double.infinity);
                                  return Stack(
                                    children: [
                                      Container(
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                      ),
                                      Positioned(
                                        left: (_tortoiseProgress * maxOffset).clamp(0.0, maxOffset),
                                        child: const AnimatedSpriteWidget(
                                          animation: 'tortoise_run',
                                          width: 40,
                                          height: 40,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('🏁', style: TextStyle(fontSize: 24)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Glowing Magical Cheer Bubble
                  MagicalFloatingBubble(
                    text: _tortoiseProgress > 0.85
                        ? 'Finish line in sight! 🏆'
                        : (_tortoiseProgress > 0.4
                            ? 'Keep cheering! Timo leads! 🌟'
                            : 'Cheer Timo to run faster! 🏁'),
                    glowColor: const Color(0xFFFF9F1C),
                  ),
                  const SizedBox(height: 10),

                  // Giant Tactile Cheer Button
                  GestureDetector(
                    onTap: _handleCheerTap,
                    child: Container(
                      width: 240,
                      height: 108,
                      decoration: AppTheme.tactileButtonDecoration(
                        topColor: const Color(0xFFFF9F1C),
                        bottomColor: const Color(0xFFE76F51),
                        radius: 32,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('📣 🐢 🏁', style: TextStyle(fontSize: 32)),
                          SizedBox(height: 4),
                          Text(
                            'CHEER TIMO!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'TAP FAST TO FINISH!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
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
