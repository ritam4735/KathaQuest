import 'dart:math' as math;
import 'package:flutter/material.dart';

/// LightGlowLayer rendering volumetric god-rays from the book, celestial constellations, and light bloom.
class LightGlowLayer extends StatelessWidget {
  final double introProgress; // 0.0 to 1.0
  final double idleTime;      // Continuous idle time in seconds

  const LightGlowLayer({
    super.key,
    required this.introProgress,
    required this.idleTime,
  });

  @override
  Widget build(BuildContext context) {
    if (introProgress < 0.25) return const SizedBox.shrink();

    // Stage 3 progress: 0.25 to 0.90
    final revealProgress = ((introProgress - 0.25) / 0.65).clamp(0.0, 1.0);
    final pulse = math.sin(idleTime * 2.4);

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Constellations in the upper twilight sky (assets/images/hero_splash/constalations.png)
          if (revealProgress > 0.1)
            Positioned(
              top: 35,
              right: 15,
              width: 220,
              height: 380,
              child: Opacity(
                opacity: ((revealProgress - 0.1) / 0.5).clamp(0.0, 1.0) * (0.65 + 0.25 * pulse),
                child: Image.asset(
                  'assets/images/hero_splash/constalations.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),

          // 2. Volumetric God-Rays Painter originating from the sacred book
          CustomPaint(
            size: Size.infinite,
            painter: _VolumetricGodRaysPainter(
              progress: revealProgress,
              pulse: pulse,
              time: idleTime,
            ),
          ),

          // 3. Central Radial Book Bloom Glow
          Positioned(
            left: 0,
            right: 0,
            bottom: 120,
            height: 320,
            child: Opacity(
              opacity: (revealProgress * 0.75 + 0.15 * pulse).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xAAFFF9C4), // Divine warm core
                      const Color(0x66FFD54F), // Amber halo
                      const Color(0x22FF9800), // Saffron fringe
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.35, 0.65, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VolumetricGodRaysPainter extends CustomPainter {
  final double progress;
  final double pulse;
  final double time;

  _VolumetricGodRaysPainter({
    required this.progress,
    required this.pulse,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.05) return;

    final w = size.width;
    final h = size.height;

    // Origin: Center of the sacred book
    final origin = Offset(w * 0.50, h * 0.74);
    final rayCount = 8;
    final maxRayLength = h * 0.65;

    for (int i = 0; i < rayCount; i++) {
      // Angles radiating upward into the celestial sky
      final baseAngle = -math.pi * 0.5 + ((i - (rayCount - 1) / 2) * 0.22);
      final dynamicAngle = baseAngle + math.sin(time * 0.8 + i) * 0.04;

      final rayProgress = (progress * 1.2 - (i * 0.06)).clamp(0.0, 1.0);
      if (rayProgress <= 0) continue;

      final length = maxRayLength * rayProgress * (0.85 + 0.15 * math.sin(time * 1.5 + i));
      final spread = 0.075 + (0.02 * math.sin(time * 2.0 + i));

      final p1 = origin;
      final p2 = Offset(
        origin.dx + math.cos(dynamicAngle - spread) * length,
        origin.dy + math.sin(dynamicAngle - spread) * length,
      );
      final p3 = Offset(
        origin.dx + math.cos(dynamicAngle + spread) * length,
        origin.dy + math.sin(dynamicAngle + spread) * length,
      );

      final rayPath = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..close();

      final rayAlpha = (0.22 + 0.08 * pulse) * rayProgress;

      final rayPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFFFFE082).withOpacity(rayAlpha.clamp(0.0, 1.0)),
            const Color(0xFFFFF9C4).withOpacity((rayAlpha * 0.6).clamp(0.0, 1.0)),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromPoints(p1, Offset(origin.dx, origin.dy - length)))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

      canvas.drawPath(rayPath, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VolumetricGodRaysPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.pulse != pulse;
  }
}
