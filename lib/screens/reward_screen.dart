import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/audio_manager.dart';
import '../core/haptic_feedback_helper.dart';
import '../core/models/story_model.dart';
import '../state/game_state.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/star_rating_bar.dart';

class RewardScreen extends StatefulWidget {
  final RewardStep step;
  final VoidCallback onReplay;
  final VoidCallback onReturnToLibrary;

  const RewardScreen({
    super.key,
    required this.step,
    required this.onReplay,
    required this.onReturnToLibrary,
  });

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _badgeController;
  late AnimationController _gradientController;

  late Animation<double> _titleSlide;
  late Animation<double> _badgeScale;
  late Animation<double> _badgeRotation;
  late Animation<double> _cardFade;

  int _visibleStars = 0;

  @override
  void initState() {
    super.initState();

    // Entrance stagger controller
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Title slides down from top
    _titleSlide = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOutCubic),
    );

    // Badge dramatic zoom+rotate entrance
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _badgeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.elasticOut),
    );

    _badgeRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.easeOutBack),
    );

    // Card fade in
    _cardFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    );

    // Animated gradient shift
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    // Start the sequence
    _entranceController.forward();
    _startSequentialReveal();
  }

  void _startSequentialReveal() async {
    final gameState = context.read<GameState>();
    final stars = gameState.sessionStarsEarned;

    // Wait for title
    await Future.delayed(const Duration(milliseconds: 600));

    // Badge flip entrance
    if (mounted) _badgeController.forward();
    AudioManager().playBadgeUnlock();
    HapticHelper.success();

    // Sequential star reveals
    await Future.delayed(const Duration(milliseconds: 800));
    for (int i = 0; i < stars && i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        setState(() => _visibleStars = i + 1);
        AudioManager().playStar();
        HapticHelper.collect();
      }
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _badgeController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final isHindi = gameState.isHindi;
    final stars = gameState.sessionStarsEarned;

    return Scaffold(
      body: ConfettiOverlay(
        isPlaying: true,
        child: AnimatedBuilder(
          animation: _gradientController,
          builder: (context, child) {
            // Animated gradient shift
            final t = _gradientController.value;
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.lerp(
                      const Color(0xFFFFF3B0),
                      const Color(0xFFFFE0B2),
                      t,
                    )!,
                    Color.lerp(
                      const Color(0xFFFFD166),
                      const Color(0xFFFFCC80),
                      t,
                    )!,
                    Color.lerp(
                      const Color(0xFFFF9F1C),
                      const Color(0xFFF4845F),
                      t,
                    )!,
                  ],
                ),
              ),
              child: child,
            );
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Title banner — slides down
                  AnimatedBuilder(
                    animation: _titleSlide,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -40 * (1.0 - _titleSlide.value)),
                        child: Opacity(
                          opacity: _titleSlide.value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        isHindi ? '🎉 शाबाश! आपने कर दिखाया!' : '🎉 QUEST COMPLETED!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryDark,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),

                  // Badge — dramatic zoom+spin entrance
                  AnimatedBuilder(
                    animation: _badgeController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _badgeScale.value,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY((1.0 - _badgeRotation.value) * 3.14159),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFB703), width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x44FFB703),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: widget.step.badgeName.contains('Emerald')
                            ? ClipOval(
                                child: Image.asset(
                                  'assets/spritesheets/badges/emrald_badge_hero.png',
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Text(
                                widget.step.badgeIcon,
                                style: const TextStyle(fontSize: 72),
                              ),
                      ),
                    ),
                  ),

                  // Stars Earned — sequential reveal
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (i) {
                          final isVisible = i < _visibleStars;
                          return AnimatedScale(
                            scale: isVisible ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.elasticOut,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                isVisible ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 52,
                                color: isVisible
                                    ? const Color(0xFFFFB703)
                                    : Colors.grey.shade300,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isHindi
                            ? '$stars / 3 सितारे अर्जित किए!'
                            : '$stars of 3 Stars Earned!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),

                  // Badge Unlock Card — fades in
                  AnimatedBuilder(
                    animation: _cardFade,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _cardFade.value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1.0 - _cardFade.value)),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: AppTheme.kidCardDecoration(
                        color: Colors.white,
                        borderColor: AppTheme.secondary,
                        radius: 24,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🏅 ', style: TextStyle(fontSize: 20)),
                              Text(
                                isHindi
                                    ? 'नया पदक: ${widget.step.badgeName}'
                                    : 'Badge Unlocked: ${widget.step.badgeName}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isHindi
                                ? widget.step.badgeDescriptionRegional
                                : widget.step.badgeDescriptionEn,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textDark,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(isHindi ? 'फिर से खेलें' : 'Read Again'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textDark,
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: widget.onReplay,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.home_rounded),
                          label: Text(isHindi ? 'कहानी सूची' : 'Library'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryDark,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: widget.onReturnToLibrary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
