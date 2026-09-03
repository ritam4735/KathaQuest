import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Hero Background Layer rendering the palace, pillars, temple arches, and horizon.
class HeroBackgroundLayer extends StatelessWidget {
  final double introProgress; // 0.0 to 1.0 over intro timeline
  final double idleTime;      // Continuous idle time in seconds
  final double cameraZoom;    // Camera zoom factor (e.g. 1.00 to 1.045)
  final double brightness;    // 0.0 to 1.0 brightness ramp
  final Offset parallaxOffset; // Parallax pan offset

  const HeroBackgroundLayer({
    super.key,
    required this.introProgress,
    required this.idleTime,
    this.cameraZoom = 1.0,
    this.brightness = 1.0,
    this.parallaxOffset = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    // Subtle organic breathing motion in idle
    final breathingScale = 1.0 + 0.006 * math.sin(idleTime * 1.2);
    final totalScale = cameraZoom * breathingScale;

    // Slow ambient sway
    final swayX = parallaxOffset.dx * 0.12 + math.sin(idleTime * 0.4) * 3.0;
    final swayY = parallaxOffset.dy * 0.12 + math.cos(idleTime * 0.3) * 2.0;

    return RepaintBoundary(
      child: Transform.translate(
        offset: Offset(swayX, swayY),
        child: Transform.scale(
          scale: totalScale,
          alignment: Alignment.center,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Primary Background Palace & Landscape Artwork
              ColorFiltered(
                colorFilter: ColorFilter.matrix([
                  // Brightness & warmth matrix based on brightness param
                  brightness, 0, 0, 0, (1 - brightness) * -30,
                  0, brightness * 0.98, 0, 0, (1 - brightness) * -35,
                  0, 0, brightness * 0.94, 0, (1 - brightness) * -40,
                  0, 0, 0, 1, 0,
                ]),
                child: Image.asset(
                  'assets/images/hero_splash/background.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.medium,
                ),
              ),

              // 2. Soft Ambient Golden Light Cast (Awakens during Stage 2 & 3)
              if (introProgress > 0.1)
                Opacity(
                  opacity: ((introProgress - 0.1) / 0.9).clamp(0.0, 1.0) * 0.22,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0.0, 0.2),
                        radius: 0.9,
                        colors: [
                          Color(0x66FFD54F),
                          Color(0x22FF9800),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),

              // 3. Cinematic Vignette (Edge shadowing for premium storybook focus)
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.15,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.35),
                        Colors.black.withOpacity(0.70),
                      ],
                      stops: const [0.55, 0.85, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
