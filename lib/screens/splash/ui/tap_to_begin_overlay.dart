import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'loading_progress_bar.dart';

/// TapToBeginOverlay orchestrates the KathaQuest title presentation,
/// the glowing LoadingProgressBar during initialization, and the smooth
/// animated transition to the interactive "Tap to Begin" prompt once loaded.
class TapToBeginOverlay extends StatelessWidget {
  final double introProgress;   // 0.0 to 1.0 (title reveals around 0.65+)
  final double idleTime;        // Continuous idle time in seconds
  final double loadingProgress; // 0.0 to 1.0 app initialization progress
  final bool isLoaded;          // True when initialization is 100% complete
  final VoidCallback onTap;     // Interactive tap action

  const TapToBeginOverlay({
    super.key,
    required this.introProgress,
    required this.idleTime,
    required this.loadingProgress,
    required this.isLoaded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (introProgress < 0.15) return const SizedBox.shrink();

    // Title fades in after intro stage 2 (0.50 to 0.85)
    final titleOpacity = ((introProgress - 0.50) / 0.35).clamp(0.0, 1.0);
    final pulse = (math.sin(idleTime * 2.8) + 1.0) * 0.5;

    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. TOP TITLE HEADER: "कथाQuest" with royal gold filigree
          Positioned(
            top: 24,
            left: 20,
            right: 20,
            child: Opacity(
              opacity: titleOpacity,
              child: Transform.translate(
                offset: Offset(0, (1.0 - titleOpacity) * -16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ornate Crown Icon / Crest
                    Icon(
                      Icons.auto_stories_rounded,
                      size: 28,
                      color: const Color(0xFFFFD54F).withOpacity(0.9),
                      shadows: const [
                        Shadow(
                          color: Color(0xFFFF8F00),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Title with Dual Font / Royal Gradient
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFFFF9C4), // Light gold
                          Color(0xFFFFD54F), // Deep gold
                          Color(0xFFFF9800), // Saffron
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      child: const Text(
                        'कथाQuest',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: Colors.white,
                          fontFamily: 'serif',
                          shadows: [
                            Shadow(
                              color: Color(0x99000000),
                              offset: Offset(0, 3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      'AN INTERACTIVE STORYBOOK ADVENTURE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.2,
                        color: Colors.white.withOpacity(0.85),
                        shadows: const [
                          Shadow(
                            color: Colors.black87,
                            offset: Offset(0, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. BOTTOM PROMPT: Smooth morph between Loading Bar and "Tap to Begin"
          Positioned(
            bottom: 36,
            left: 20,
            right: 20,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 650),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.25),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: isLoaded && introProgress >= 0.70
                    ? _buildTapToBeginPrompt(pulse)
                    : _buildLoadingState(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return LoadingProgressBar(
      key: const ValueKey('loading_bar'),
      progress: loadingProgress,
      idleTime: idleTime,
    );
  }

  Widget _buildTapToBeginPrompt(double pulse) {
    return GestureDetector(
      key: const ValueKey('tap_to_begin_btn'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Transform.scale(
        scale: 1.0 + (0.04 * pulse),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFD54F), // Gold
                Color(0xFFFF9800), // Saffron
                Color(0xFFE65100), // Deep Amber
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.85),
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB300).withOpacity(0.55 + 0.25 * pulse),
                blurRadius: 18 + (8 * pulse),
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
              const BoxShadow(
                color: Colors.black45,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.touch_app_rounded,
                color: Colors.white.withOpacity(0.95),
                size: 20,
              ),
              const SizedBox(width: 10),
              const Text(
                'Tap to Begin',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.85),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
