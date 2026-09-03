import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/models/story_model.dart';
import '../../core/audio_manager.dart';
import '../../core/app_theme.dart';
import '../../widgets/animated_sprite_widget.dart';
import 'minigame_container.dart';

class ForestWalkMiniGame extends StatefulWidget {
  final MiniGameStep step;
  final Function(int score) onComplete;

  const ForestWalkMiniGame({
    super.key,
    required this.step,
    required this.onComplete,
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

    if (_random.nextDouble() < 0.04) {
      _spawnItem();
    }

    setState(() {
      for (var item in _items) {
        item.y += item.speed;

        // Check catch by tortoise
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
      AudioManager().playStar();
    } else {
      AudioManager().playWrong();
    }

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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          '🎉 Forest Trail Complete!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐢', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              'You guided Timo through the woods and collected $_score forest points!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
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
    _gameLoop.dispose();
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _tortoiseX = (_tortoiseX + details.delta.dx / constraints.maxWidth)
                    .clamp(0.1, 0.9);
              });
            },
            onTapDown: (details) {
              setState(() {
                _tortoiseX = (details.localPosition.dx / constraints.maxWidth)
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

                  // Falling items
                  for (final item in _items)
                    Positioned(
                      left: (item.x * constraints.maxWidth) - 24,
                      top: item.y * constraints.maxHeight,
                      child: GestureDetector(
                        onTap: () => _collectItem(item),
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
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Text(
                            '👈 Drag Timo 👉',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
