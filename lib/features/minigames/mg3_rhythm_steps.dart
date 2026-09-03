import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/models/story_model.dart';
import '../../core/audio_manager.dart';
import '../../core/app_theme.dart';
import '../../widgets/animated_sprite_widget.dart';
import '../../widgets/magical_speech_bubble.dart';
import 'minigame_container.dart';

class RhythmStepsMiniGame extends StatefulWidget {
  final MiniGameStep step;
  final Function(int score) onComplete;

  const RhythmStepsMiniGame({
    super.key,
    required this.step,
    required this.onComplete,
  });

  @override
  State<RhythmStepsMiniGame> createState() => _RhythmStepsMiniGameState();
}

class _RhythmStepsMiniGameState extends State<RhythmStepsMiniGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;
  late int _remainingSeconds;
  int _score = 0;
  int _combo = 0;
  bool _isGameOver = false;
  String? _rhythmFeedback;
  Timer? _feedbackTimer;

  final List<_BeatNote> _notes = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.step.durationSeconds;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateNotes);

    _controller.repeat();

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

    _spawnNote();
  }

  void _spawnNote() {
    if (_isGameOver) return;
    final isLeftLane = _random.nextBool();
    _notes.add(
      _BeatNote(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        isLeftLane: isLeftLane,
        y: -0.1,
        speed: 0.007 + (_random.nextDouble() * 0.003),
      ),
    );
  }

  void _updateNotes() {
    if (_isGameOver || !mounted) return;

    if (_random.nextDouble() < 0.045) {
      _spawnNote();
    }

    setState(() {
      for (var note in _notes) {
        note.y += note.speed;
      }

      // Missed notes
      for (var note in _notes) {
        if (note.y > 1.05 && !note.isHit && !note.isMissed) {
          note.isMissed = true;
          _combo = 0;
        }
      }

      _notes.removeWhere((n) => n.y > 1.15 || n.isHit);
    });

    if (_score >= widget.step.targetScore) {
      _finishGame();
    }
  }

  void _handleLaneTap(bool isLeft) {
    if (_isGameOver) return;

    // Find the note closest to the hit line (y: 0.75 - 0.95)
    _BeatNote? targetNote;
    double minDistance = 999.0;

    for (var note in _notes) {
      if (note.isLeftLane == isLeft && !note.isHit) {
        final distance = (note.y - 0.82).abs();
        if (distance < 0.16 && distance < minDistance) {
          minDistance = distance;
          targetNote = note;
        }
      }
    }

    if (targetNote != null) {
      targetNote.isHit = true;
      _combo++;
      final pointsAwarded = 10 + (_combo > 3 ? 5 : 0);
      _score += pointsAwarded;
      _rhythmFeedback = _combo > 2 ? 'Combo x$_combo! 🌟' : 'Perfect! 🎵';
      AudioManager().playFootstep();
      AudioManager().playStar();
    } else {
      _combo = 0;
      _rhythmFeedback = 'Tap on line! 🐾';
      AudioManager().playTap();
    }

    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _rhythmFeedback = null);
    });

    setState(() {});

    if (_score >= widget.step.targetScore) {
      _finishGame();
    }
  }

  void _finishGame() {
    if (_isGameOver) return;
    _isGameOver = true;
    _controller.stop();
    _timer?.cancel();

    AudioManager().playCheer();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          '🎵 Rhythm Walk Perfected!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐢🎶', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              'Timo quietly marched past the sleeping hare with great musical rhythm! Final score: $_score!',
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
    _controller.dispose();
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
          final halfWidth = constraints.maxWidth / 2;

          return Stack(
            children: [
              // High-Res Tree background
              Positioned.fill(
                child: Image.asset(
                  'assets/images/backgrounds_for_hare_tortoise_story/4.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),

              // Semi-transparent overlay to keep rhythm lanes legible
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.80),
                ),
              ),

              // Snoring Hare animated sprite in background with Glowing Dream Bubble
              Positioned(
                top: 14,
                right: 16,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    AnimatedSpriteWidget(
                      animation: 'hare_sleep',
                      width: 52,
                      height: 52,
                    ),
                    SizedBox(width: 6),
                    MagicalFloatingBubble(
                      text: 'Zzz... 😴',
                      icon: '🌙',
                      glowColor: Color(0xFF80D8FF),
                      fontSize: 12,
                    ),
                  ],
                ),
              ),

              // Two Lane Tracks
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Colors.grey.shade300,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),

              // Dynamic Rhythm Hit Feedback Bubble
              if (_rhythmFeedback != null)
                Positioned(
                  top: constraints.maxHeight * 0.72,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: MagicalFloatingBubble(
                      text: _rhythmFeedback!,
                      glowColor: const Color(0xFFFFD54F),
                      fontSize: 13,
                    ),
                  ),
                ),

              // Glowing Hit Target Line
              Positioned(
                top: constraints.maxHeight * 0.80,
                left: 0,
                right: 0,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2EC4B6).withOpacity(0.2),
                    border: const Border.symmetric(
                      horizontal: BorderSide(color: Color(0xFF2EC4B6), width: 2),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '⭐ TAP THE STEP HERE ⭐',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0077B6),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),

              // Scrolling Beat Notes
              for (final note in _notes)
                Positioned(
                  left: note.isLeftLane
                      ? (halfWidth * 0.5) - 30
                      : (halfWidth * 1.5) - 30,
                  top: note.y * constraints.maxHeight,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: note.isLeftLane
                          ? const Color(0xFFFF9F1C)
                          : const Color(0xFF2EC4B6),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (note.isLeftLane
                                  ? const Color(0xFFFF9F1C)
                                  : const Color(0xFF2EC4B6))
                              .withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        note.isLeftLane ? '🐾' : '🎵',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                ),

              // Left Lane Tap Area Button
              Positioned(
                bottom: 16,
                left: 20,
                width: halfWidth - 30,
                height: 70,
                child: ElevatedButton.icon(
                  icon: const Text('🐾', style: TextStyle(fontSize: 24)),
                  label: const Text('LEFT STEP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9F1C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => _handleLaneTap(true),
                ),
              ),

              // Right Lane Tap Area Button
              Positioned(
                bottom: 16,
                right: 20,
                width: halfWidth - 30,
                height: 70,
                child: ElevatedButton.icon(
                  icon: const Text('🎵', style: TextStyle(fontSize: 24)),
                  label: const Text('RIGHT STEP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2EC4B6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => _handleLaneTap(false),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BeatNote {
  final String id;
  final bool isLeftLane;
  double y;
  double speed;
  bool isHit = false;
  bool isMissed = false;

  _BeatNote({
    required this.id,
    required this.isLeftLane,
    required this.y,
    required this.speed,
  });
}
