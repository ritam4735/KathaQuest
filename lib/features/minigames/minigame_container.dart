import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/haptic_feedback_helper.dart';
import '../../widgets/magical_speech_bubble.dart';

class MiniGameContainer extends StatefulWidget {
  final String title;
  final String instructions;
  final int currentScore;
  final int targetScore;
  final int remainingSeconds;
  final VoidCallback? onPause;
  final Widget child;

  const MiniGameContainer({
    super.key,
    required this.title,
    required this.instructions,
    required this.currentScore,
    required this.targetScore,
    required this.remainingSeconds,
    this.onPause,
    required this.child,
  });

  @override
  State<MiniGameContainer> createState() => _MiniGameContainerState();
}

class _MiniGameContainerState extends State<MiniGameContainer>
    with TickerProviderStateMixin {
  late AnimationController _scorePopController;
  late AnimationController _timerPulseController;
  int _lastScore = 0;

  @override
  void initState() {
    super.initState();

    _scorePopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Calmer, slower breathing animation (1200ms) for timer focus
    _timerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _lastScore = widget.currentScore;
  }

  @override
  void didUpdateWidget(covariant MiniGameContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Score pop animation
    if (widget.currentScore != _lastScore) {
      _scorePopController.forward(from: 0.0);
      _lastScore = widget.currentScore;
    }

    // Calm breathing pulse when under 8 seconds to promote calm focus (Slow and steady!)
    if (widget.remainingSeconds <= 8 && widget.remainingSeconds > 0) {
      if (!_timerPulseController.isAnimating) {
        _timerPulseController.repeat(reverse: true);
      }
    } else {
      _timerPulseController.stop();
      _timerPulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _scorePopController.dispose();
    _timerPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.currentScore / widget.targetScore).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FDF9),
      body: SafeArea(
        child: Column(
          children: [
            // Top Minigame HUD
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Minigame Title
                      Expanded(
                        child: Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Timer Pill with Gentle Calm Breathing Glow (No aggressive red flashing)
                      AnimatedBuilder(
                        animation: _timerPulseController,
                        builder: (context, child) {
                          final isEnding = widget.remainingSeconds <= 8;
                          final breathe = isEnding
                              ? sin(_timerPulseController.value * pi)
                              : 0.0;

                          // Soothing warm gold/amber glow instead of alarm red
                          final bgColor = isEnding
                              ? Color.lerp(
                                  const Color(0xFFFFF9E6),
                                  const Color(0xFFFFECC8),
                                  breathe,
                                )!
                              : const Color(0xFFE8F5E9);

                          final borderColor = isEnding
                              ? Color.lerp(
                                  const Color(0xFFFFB703),
                                  const Color(0xFFFB8500),
                                  breathe,
                                )!
                              : AppTheme.secondary;

                          return Transform.scale(
                            scale: 1.0 + (breathe * 0.05),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor, width: 1.5),
                                boxShadow: isEnding
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFFFFB703).withOpacity(0.25 * breathe),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 15,
                                    color: isEnding
                                        ? const Color(0xFFD48B00)
                                        : AppTheme.secondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.remainingSeconds}s',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isEnding
                                          ? const Color(0xFFB57000)
                                          : AppTheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),

                      // Score Pill with pop animation
                      AnimatedBuilder(
                        animation: _scorePopController,
                        builder: (context, child) {
                          final pop = sin(_scorePopController.value * pi);
                          return Transform.scale(
                            scale: 1.0 + (pop * 0.12),
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9E6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppTheme.primary, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⭐ ', style: TextStyle(fontSize: 13)),
                              Text(
                                '${widget.currentScore} / ${widget.targetScore}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Dedicated Top-Right Pause Button in HUD with large touch target
                      if (widget.onPause != null)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticHelper.light();
                              widget.onPause?.call();
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3F5),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.pause_rounded,
                                  size: 24,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Progress Bar with spring animation
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedProgress, _) {
                        return LinearProgressIndicator(
                          value: animatedProgress,
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.secondary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Instructions Hint Bar with Magical Glowing Style
            MagicalHintBanner(instructions: widget.instructions),

            // Game Play Area
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}
