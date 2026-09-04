import 'dart:async';
import 'dart:math';
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

class _ForestWalkMiniGameState extends State<ForestWalkMiniGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _gameLoop;
  Timer? _timer;
  late int _remainingSeconds;
  int _score = 0;
  double _tortoiseX = 0.5; // 0.0 to 1.0

  final List<_ForestItem> _items = [];
  final Random _random = Random();
  bool _isGameOver = false;
  String? _timoReaction;
  Timer? _reactionTimer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.step.durationSeconds;

    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateGame);

    _gameLoop.repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final isPaused = context.read<GameState>().isPaused;
      if (isPaused) return; // Freeze countdown while paused

      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _finishGame();
        }
      });
    });

    _spawnItem();
  }

  void _spawnItem() {
    if (_isGameOver) return;
    final typeRoll = _random.nextDouble();
    String type = 'star';
    String emoji = '⭐';
    int points = 15;

    if (typeRoll < 0.45) {
      type = 'star';
      emoji = '⭐';
      points = 15;
    } else if (typeRoll < 0.75) {
      type = 'clover';
      emoji = '🍀';
      points = 10;
    } else {
      type = 'mud';
      emoji = '🟫';
      points = -5;
    }

    _items.add(
      _ForestItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        x: 0.15 + _random.nextDouble() * 0.7,
        y: -0.1,
        speed: 0.005 + _random.nextDouble() * 0.005,
        type: type,
        emoji: emoji,
        points: points,
      ),
    );
  }

  void _updateGame() {
    if (_isGameOver || !mounted) return;
    final isPaused = context.read<GameState>().isPaused;
    if (isPaused) return; // Freeze movement and spawns when paused

    if (_random.nextDouble() < 0.04) {
      _spawnItem();
    }

    setState(() {
      for (var item in _items) {
        item.y += item.speed;

        // Check catch by tortoise strictly via physical collision
        if (item.y >= 0.72 && item.y <= 0.88 && !item.isCollected) {
          if ((item.x - _tortoiseX).abs() < 0.18) {
            _collectItem(item);
          }
        }
      }

      _items.removeWhere((item) => item.y > 1.1 || item.isCollected);
    });

    if (_score >= widget.step.targetScore) {
      _finishGame();
    }
  }

  void _collectItem(_ForestItem item) {
    item.isCollected = true;
    _score = max(0, _score + item.points);

    if (item.points > 0) {
      HapticHelper.collect();
      AudioManager().playStar();
      _timoReaction = '+${item.points} ${item.emoji}';
    } else {
      AudioManager().playWrong();
      _timoReaction = 'Careful! 🍃';
    }

    _reactionTimer?.cancel();
    _reactionTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _timoReaction = null);
    });

    if (_score >= widget.step.targetScore) {
      _finishGame();
    }
  }

  void _finishGame() {
    if (_isGameOver) return;
    _isGameOver = true;
    _gameLoop.stop();
    _timer?.cancel();

    AudioManager().playCheer();

    final gameState = context.read<GameState>();
    MiniGameCelebrationDialog.show(
      context: context,
      score: _score,
      targetScore: widget.step.targetScore,
      emoji: '🐢',
      isHindi: gameState.isHindi,
      onContinue: () => widget.onComplete(_score),
    );
  }

  @override
  void dispose() {
    _gameLoop.dispose();
    _timer?.cancel();
    _reactionTimer?.cancel();
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onHorizontalDragUpdate: (details) {
              final isPaused = context.read<GameState>().isPaused;
              if (isPaused || _isGameOver) return;

              setState(() {
                _tortoiseX = (_tortoiseX + details.delta.dx / constraints.maxWidth)
                    .clamp(0.1, 0.9);
              });
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
              ),
              child: Stack(
                children: [
                  // High-Res Forest Path Background
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/backgrounds_for_hare_tortoise_story/2.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Semi-transparent overlay to ensure contrast
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.15),
                    ),
                  ),

                  // Falling items: strictly physical collision with tortoise, NO direct tap bypass
                  for (final item in _items)
                    Positioned(
                      left: (item.x * constraints.maxWidth) - 24,
                      top: item.y * constraints.maxHeight,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.90),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          item.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),

                  // Controlled Tortoise Character with Animated Sprite
                  Positioned(
                    left: (_tortoiseX * constraints.maxWidth) - 45,
                    top: constraints.maxHeight * 0.74,
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.35),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: AnimatedSpriteWidget(
                              animation: 'tortoise_walk',
                              width: 80,
                              height: 80,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: _timoReaction != null
                              ? MagicalFloatingBubble(
                                  text: _timoReaction!,
                                  fontSize: 12,
                                  glowColor: const Color(0xFFFFD54F),
                                )
                              : const MagicalFloatingBubble(
                                  text: 'Drag Timo to catch',
                                  icon: '👈',
                                  fontSize: 11,
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ForestItem {
  final String id;
  double x;
  double y;
  double speed;
  String type;
  String emoji;
  int points;
  bool isCollected = false;

  _ForestItem({
    required this.id,
    required this.x,
    required this.y,
    required this.speed,
    required this.type,
    required this.emoji,
    required this.points,
  });
}
