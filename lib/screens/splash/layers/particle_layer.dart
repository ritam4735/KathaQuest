import 'dart:math' as math;
import 'package:flutter/material.dart';

/// ParticleLayer rendering floating magical stardust, twinkling fireflies, and ascending book embers.
class ParticleLayer extends StatelessWidget {
  final double introProgress; // 0.0 to 1.0 (phase progression)
  final double idleTime;      // Continuous idle time in seconds
  final int particleCount;

  const ParticleLayer({
    super.key,
    required this.introProgress,
    required this.idleTime,
    this.particleCount = 45,
  });

  @override
  Widget build(BuildContext context) {
    if (introProgress < 0.10) return const SizedBox.shrink();

    final opacity = ((introProgress - 0.10) / 0.40).clamp(0.0, 1.0);

    return RepaintBoundary(
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          size: Size.infinite,
          painter: _MagicParticlePainter(
            time: idleTime,
            introProgress: introProgress,
            count: particleCount,
          ),
        ),
      ),
    );
  }
}

class _MagicParticlePainter extends CustomPainter {
  final double time;
  final double introProgress;
  final int count;

  // Cached deterministic pseudo-random seeds
  static final List<double> _seeds = List.generate(120, (i) => math.Random(i * 37 + 11).nextDouble());

  _MagicParticlePainter({
    required this.time,
    required this.introProgress,
    required this.count,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Ascending Spiral Embers from the Sacred Book (Centered around x: 0.52w, y: 0.75h)
    _drawAscendingEmbers(canvas, w, h);

    // 2. Ambient Floating Stardust & Twinkles across the full atmosphere
    _drawAmbientStardust(canvas, w, h);
  }

  void _drawAscendingEmbers(Canvas canvas, double w, double h) {
    final bookOriginX = w * 0.50;
    final bookOriginY = h * 0.74;

    final emberPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    // Scale ember density and ascent with intro progress
    final emberCount = (18 * introProgress).round().clamp(6, 18);

    for (int i = 0; i < emberCount; i++) {
      final seed1 = _seeds[i % _seeds.length];
      final seed2 = _seeds[(i + 13) % _seeds.length];
      final seed3 = _seeds[(i + 27) % _seeds.length];

      final lifespan = 3.5;
      final particleAge = (time * (0.8 + seed1 * 0.4) + seed2 * lifespan) % lifespan;
      final progress = particleAge / lifespan; // 0.0 (book) to 1.0 (sky)

      // Helical spiral upward
      final spiralRadius = 20.0 + (progress * 80.0 * seed3);
      final angle = (time * 2.5) + (seed1 * math.pi * 2) + (progress * math.pi * 4);

      final px = bookOriginX + math.cos(angle) * spiralRadius;
      final py = bookOriginY - (progress * h * 0.45);

      // Fade in at birth, peak at 0.4, fade out at top
      final fade = math.sin(progress * math.pi);
      final radius = (1.5 + seed2 * 2.2) * (1.0 + 0.3 * math.sin(time * 6.0 + i));

      emberPaint.color = Color.lerp(
        const Color(0xFFFFD54F), // Gold
        const Color(0xFFFF6D00), // Fiery amber
        seed3,
      )!.withOpacity((fade * 0.85).clamp(0.0, 1.0));

      canvas.drawCircle(Offset(px, py), radius, emberPaint);

      // Cross glint for larger particles
      if (radius > 2.5 && fade > 0.6) {
        _drawCrossGlint(canvas, Offset(px, py), radius * 1.8, emberPaint.color.withOpacity(fade * 0.9));
      }
    }
  }

  void _drawAmbientStardust(Canvas canvas, double w, double h) {
    final starPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final seedX = _seeds[(i * 3) % _seeds.length];
      final seedY = _seeds[(i * 3 + 1) % _seeds.length];
      final seedSpeed = _seeds[(i * 3 + 2) % _seeds.length];

      // Smooth floating motion
      final px = (seedX * w + math.sin((time * 0.6 * seedSpeed) + i) * 20.0) % w;
      final py = (seedY * h - (time * 12.0 * seedSpeed) % (h * 0.85)) % h;

      // Twinkle pulse
      final twinkle = (math.sin((time * (2.0 + seedSpeed * 4.0)) + (i * 1.7)) + 1.0) * 0.5;
      final radius = 1.0 + (seedSpeed * 1.8) * twinkle;
      final alpha = (0.35 + 0.55 * twinkle) * introProgress.clamp(0.0, 1.0);

      starPaint.color = (i % 4 == 0)
          ? const Color(0xFF80D8FF).withOpacity(alpha) // Subtle celestial cyan
          : const Color(0xFFFFF9C4).withOpacity(alpha); // Golden warm star

      canvas.drawCircle(Offset(px, py), radius, starPaint);
    }
  }

  void _drawCrossGlint(Canvas canvas, Offset p, double r, Color color) {
    final glintPaint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(p.dx - r, p.dy), Offset(p.dx + r, p.dy), glintPaint);
    canvas.drawLine(Offset(p.dx, p.dy - r), Offset(p.dx, p.dy + r), glintPaint);
  }

  @override
  bool shouldRepaint(covariant _MagicParticlePainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.introProgress != introProgress;
  }
}
