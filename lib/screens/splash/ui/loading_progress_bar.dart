import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Glowing royal loading progress bar with animated fill, soft glow, and smooth interpolation.
class LoadingProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double idleTime; // Continuous idle time for shimmer effect
  final double width;
  final double height;

  const LoadingProgressBar({
    super.key,
    required this.progress,
    required this.idleTime,
    this.width = 240.0,
    this.height = 7.0,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final pulse = (math.sin(idleTime * 4.0) + 1.0) * 0.5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "Loading..." text with gentle breathing glow
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.8,
                color: const Color(0xFFFFD54F).withOpacity(0.85 + 0.15 * pulse),
                shadows: [
                  Shadow(
                    color: const Color(0xFFFFB300).withOpacity(0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(clampedProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFFF9C4).withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Glowing pill progress track
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height * 0.5),
            color: Colors.black.withOpacity(0.55),
            border: Border.all(
              color: const Color(0xFFFFD54F).withOpacity(0.35),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB300).withOpacity(0.20 + 0.15 * pulse),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated Fill Bar
              FractionallySizedBox(
                widthFactor: clampedProgress,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height * 0.5),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFFFF8F00), // Saffron
                        Color(0xFFFFD54F), // Temple Gold
                        Color(0xFFFFF9C4), // Radiance
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD54F).withOpacity(0.75),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),

              // Shimmer highlight traveling across the filled bar
              if (clampedProgress > 0.05)
                Positioned.fill(
                  child: FractionallySizedBox(
                    widthFactor: clampedProgress,
                    alignment: Alignment.centerLeft,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(height * 0.5),
                      child: LayoutBuilder(
                        builder: (context, fillConstraints) {
                          final fillWidth = fillConstraints.maxWidth;
                          final shimmerOffset = ((idleTime * 1.6) % 1.0) * (fillWidth + 40) - 20;

                          return Transform.translate(
                            offset: Offset(shimmerOffset, 0),
                            child: Container(
                              width: 25,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withOpacity(0.85),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
