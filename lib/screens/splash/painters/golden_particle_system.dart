import 'dart:math' as math;
import 'package:flutter/material.dart';

class GoldenParticle {
  final double seed;
  final double speed;
  final double radius;
  final double maxRiseHeight;
  final double orbitRadius;

  GoldenParticle({
    required this.seed,
    required this.speed,
    required this.radius,
    required this.maxRiseHeight,
    required this.orbitRadius,
  });
}

class GoldenParticleSystem extends CustomPainter {
  final double progress; // 0.0 to 1.0 (phase intensity)
  final double time; // continuously advancing timer for rotation

  GoldenParticleSystem({
    required this.progress,
    required this.time,
  });

  static final List<GoldenParticle> _particles = List.generate(55, (i) {
    final random = math.Random(i * 197);
    return GoldenParticle(
      seed: random.nextDouble() * 2 * math.pi,
      speed: 0.4 + (random.nextDouble() * 0.7),
      radius: 1.2 + (random.nextDouble() * 2.6),
      maxRiseHeight: 0.35 + (random.nextDouble() * 0.45),
      orbitRadius: 0.04 + (random.nextDouble() * 0.16),
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.05) return;

    final w = size.width;
    final h = size.height;

    // Origin: Center of the holy scripture book on the wooden stand
    final originX = 0.52 * w;
    final originY = 0.73 * h;

    final activeIntensity = (progress * 1.2).clamp(0.0, 1.0);

    for (final p in _particles) {
      // Advance normalized vertical progress [0.0 to 1.0]
      final t = ((time * p.speed) + (p.seed / (2 * math.pi))) % 1.0;

      // Particle rises upwards from book
      final currentHeight = t * p.maxRiseHeight * h * activeIntensity;
      final posY = originY - currentHeight;

      // Helical spiral expanding outward as it climbs
      final spiralExpansion = 1.0 + (t * 2.2);
      final angle = (t * 8 * math.pi) + p.seed;
      final posX = originX + (math.cos(angle) * p.orbitRadius * w * spiralExpansion);

      // Fade in at bottom, bright in middle, soft fade out at top
      final alphaFactor = math.sin(t * math.pi);
      final alpha = (alphaFactor * activeIntensity * 0.85).clamp(0.0, 1.0);

      if (alpha > 0.02) {
        final pos = Offset(posX, posY);

        // Outer golden glow
        final glowPaint = Paint()
          ..color = const Color(0xFFFFB300).withOpacity(alpha * 0.4)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.radius * 2.0);
        canvas.drawCircle(pos, p.radius * 2.2, glowPaint);

        // Bright sparkling core
        final corePaint = Paint()
          ..color = const Color(0xFFFFF9C4).withOpacity(alpha);
        canvas.drawCircle(pos, p.radius, corePaint);

        // Star cross glint for larger particles
        if (p.radius > 2.2 && alpha > 0.4) {
          final glintPaint = Paint()
            ..color = Colors.white.withOpacity(alpha * 0.9)
            ..strokeWidth = 0.8;
          final len = p.radius * 2.0;
          canvas.drawLine(Offset(pos.dx - len, pos.dy), Offset(pos.dx + len, pos.dy), glintPaint);
          canvas.drawLine(Offset(pos.dx, pos.dy - len), Offset(pos.dx, pos.dy + len), glintPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant GoldenParticleSystem oldDelegate) => true;
}
