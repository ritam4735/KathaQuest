import 'dart:math' as math;
import 'package:flutter/material.dart';

class LivingWorldPainter extends CustomPainter {
  final double animationValue; // 0.0 to 1.0 continuous loop or progress
  final double worldProgress; // overall timeline progress

  LivingWorldPainter({
    required this.animationValue,
    required this.worldProgress,
  });

  // Pre-calculated deterministic star positions (normalized x, y: 0.0 to 1.0)
  static final List<Offset> _stars = [
    const Offset(0.12, 0.05),
    const Offset(0.24, 0.08),
    const Offset(0.38, 0.04),
    const Offset(0.55, 0.06),
    const Offset(0.68, 0.03),
    const Offset(0.82, 0.07),
    const Offset(0.91, 0.11),
    const Offset(0.18, 0.14),
    const Offset(0.32, 0.16),
    const Offset(0.48, 0.12),
    const Offset(0.62, 0.15),
    const Offset(0.75, 0.18),
    const Offset(0.88, 0.15),
    const Offset(0.08, 0.20),
    const Offset(0.28, 0.22),
    const Offset(0.72, 0.25),
    const Offset(0.84, 0.22),
  ];

  // Lantern positions matching splash_hero_art.jpg arches & balconies
  static final List<Offset> _lanterns = [
    const Offset(0.04, 0.23), // upper left balcony
    const Offset(0.14, 0.31), // mid left archway
    const Offset(0.08, 0.46), // lower left wall lamp
    const Offset(0.16, 0.46), // courtyard left pillar lamp
    const Offset(0.41, 0.26), // center dome lantern
    const Offset(0.92, 0.48), // right arch lamp
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawTwinklingStars(canvas, w, h);
    _drawFlickeringLanterns(canvas, w, h);
    _drawFountainShimmer(canvas, w, h);
    _drawFloatingFireflies(canvas, w, h);
  }

  void _drawTwinklingStars(Canvas canvas, double w, double h) {
    for (int i = 0; i < _stars.length; i++) {
      final star = _stars[i];
      // Individual twinkle phase
      final twinkle = math.sin((animationValue * 2 * math.pi) + (i * 1.3));
      final opacity = (0.35 + (0.55 * (twinkle + 1) / 2)).clamp(0.0, 1.0);
      final radius = 1.0 + (1.6 * (twinkle + 1) / 2);

      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);

      final center = Offset(star.dx * w, star.dy * h);
      canvas.drawCircle(center, radius, paint);

      // Diamond sparkle ray for brighter stars
      if (i % 3 == 0) {
        final sparkPaint = Paint()
          ..color = const Color(0xFFFFF9C4).withOpacity(opacity * 0.8)
          ..strokeWidth = 0.8;

        final rayLen = radius * 2.5;
        canvas.drawLine(
          Offset(center.dx - rayLen, center.dy),
          Offset(center.dx + rayLen, center.dy),
          sparkPaint,
        );
        canvas.drawLine(
          Offset(center.dx, center.dy - rayLen),
          Offset(center.dx, center.dy + rayLen),
          sparkPaint,
        );
      }
    }
  }

  void _drawFlickeringLanterns(Canvas canvas, double w, double h) {
    for (int i = 0; i < _lanterns.length; i++) {
      final pos = _lanterns[i];
      // Warm organic flicker
      final flicker = math.sin((animationValue * 4 * math.pi) + (i * 2.1)) *
          math.cos((animationValue * 6 * math.pi) + (i * 0.7));
      final radius = (16.0 + (4.0 * flicker)).clamp(12.0, 24.0);
      final alpha = (0.22 + (0.10 * flicker)).clamp(0.1, 0.4);

      final center = Offset(pos.dx * w, pos.dy * h);

      final gradient = RadialGradient(
        colors: [
          const Color(0xFFFFD54F).withOpacity(alpha * 1.4),
          const Color(0xFFFF8F00).withOpacity(alpha * 0.6),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: radius),
        );

      canvas.drawCircle(center, radius, paint);
    }
  }

  void _drawFountainShimmer(Canvas canvas, double w, double h) {
    // Fountain located at ~ (0.92 * w, 0.60 * h)
    final fountainCenter = Offset(0.92 * w, 0.60 * h);
    final time = animationValue * 2 * math.pi;

    final dropletPaint = Paint()..color = const Color(0xFFE0F7FA).withOpacity(0.5);

    // Subtle water spray mist droplets
    for (int i = 0; i < 7; i++) {
      final angle = (i * 0.45) - 1.35;
      final dist = 10.0 + (8.0 * math.sin(time + (i * 1.1)));
      final dropX = fountainCenter.dx + (math.cos(angle) * dist);
      final dropY = fountainCenter.dy - (math.sin(angle).abs() * dist * 1.4);

      canvas.drawCircle(Offset(dropX, dropY), 1.2, dropletPaint);
    }

    // Gentle fountain ripple glow
    final rippleRadius = 22.0 + (6.0 * math.sin(time * 1.5));
    final ripplePaint = Paint()
      ..color = const Color(0xFF80DEEA).withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(fountainCenter.dx, fountainCenter.dy + 12),
        width: rippleRadius * 1.8,
        height: rippleRadius * 0.6,
      ),
      ripplePaint,
    );
  }

  void _drawFloatingFireflies(Canvas canvas, double w, double h) {
    // 12 drifting fireflies hovering near gardens & courtyard
    for (int i = 0; i < 12; i++) {
      final seed = i * 47.3;
      final speed = 0.5 + (i % 3) * 0.3;
      final t = (animationValue * speed + (seed % 1.0)) % 1.0;

      // Lissajous curve for natural floating movement
      final posX = (0.05 + ((seed * 13.7) % 0.90)) +
          (0.04 * math.sin((t * 2 * math.pi) + seed));
      final posY = (0.35 + ((seed * 29.3) % 0.55)) +
          (0.03 * math.cos((t * 3 * math.pi) + (seed * 0.5)));

      // Pulsing bioluminescent light
      final pulse = math.sin((t * 4 * math.pi) + seed);
      if (pulse > 0) {
        final alpha = (pulse * 0.75).clamp(0.0, 0.85);
        final center = Offset(posX * w, posY * h);

        // Outer warm glow
        final glowPaint = Paint()
          ..color = const Color(0xFFC6FF00).withOpacity(alpha * 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
        canvas.drawCircle(center, 4.0, glowPaint);

        // Bright core
        final corePaint = Paint()
          ..color = const Color(0xFFEEFF41).withOpacity(alpha);
        canvas.drawCircle(center, 1.4, corePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant LivingWorldPainter oldDelegate) => true;
}
