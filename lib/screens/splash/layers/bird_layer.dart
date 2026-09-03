import 'dart:math' as math;
import 'package:flutter/material.dart';

/// BirdLayer rendering distant silhouette birds soaring gracefully across the sky horizon.
class BirdLayer extends StatelessWidget {
  final double introProgress; // 0.0 to 1.0
  final double idleTime;      // Continuous idle time in seconds

  const BirdLayer({
    super.key,
    required this.introProgress,
    required this.idleTime,
  });

  @override
  Widget build(BuildContext context) {
    if (introProgress < 0.15) return const SizedBox.shrink();

    final opacity = ((introProgress - 0.15) / 0.35).clamp(0.0, 1.0);

    return RepaintBoundary(
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          size: Size.infinite,
          painter: _BirdFlightPainter(time: idleTime),
        ),
      ),
    );
  }
}

class _BirdFlightPainter extends CustomPainter {
  final double time;

  _BirdFlightPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Flock of 3 birds with slightly staggered depths, heights, and speeds
    _drawBird(
      canvas: canvas,
      w: w,
      h: h,
      baseY: h * 0.14,
      speed: 0.065,
      timeOffset: 0.0,
      scale: 1.0,
      flapSpeed: 7.0,
    );

    _drawBird(
      canvas: canvas,
      w: w,
      h: h,
      baseY: h * 0.17,
      speed: 0.058,
      timeOffset: 2.8,
      scale: 0.85,
      flapSpeed: 7.8,
    );

    _drawBird(
      canvas: canvas,
      w: w,
      h: h,
      baseY: h * 0.12,
      speed: 0.072,
      timeOffset: 5.5,
      scale: 0.70,
      flapSpeed: 8.5,
    );
  }

  void _drawBird({
    required Canvas canvas,
    required double w,
    required double h,
    required double baseY,
    required double speed,
    required double timeOffset,
    required double scale,
    required double flapSpeed,
  }) {
    final totalSpan = w + 120;
    final progress = ((time + timeOffset) * speed) % 1.0;
    final x = (progress * totalSpan) - 60;

    // Gentle sinusoidal wave flight trajectory
    final y = baseY + math.sin((time * 1.5) + timeOffset) * 12.0;

    // Flapping cycle: flap angle alternates between -0.45 and +0.45 radians
    final flapPhase = math.sin((time * flapSpeed) + timeOffset);
    final wingAngle = flapPhase * 0.42;

    final paint = Paint()
      ..color = const Color(0xD83E2723) // Deep silhouette umber/night violet
      ..strokeWidth = 1.8 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = const Color(0x33FFD54F) // Subtle golden atmospheric fringe
      ..strokeWidth = 3.2 * scale
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale);

    // Bird wings path: arched curved wings flapping from central body
    final wingSpan = 14.0;
    final wingLift = math.sin(wingAngle) * 7.0;

    final birdPath = Path();
    // Left Wing
    birdPath.moveTo(0, 0);
    birdPath.quadraticBezierTo(-wingSpan * 0.5, -wingLift - 2, -wingSpan, wingLift * 0.4);
    // Right Wing
    birdPath.moveTo(0, 0);
    birdPath.quadraticBezierTo(wingSpan * 0.5, -wingLift - 2, wingSpan, wingLift * 0.4);

    // Draw atmospheric fringe & silhouette
    canvas.drawPath(birdPath, glowPaint);
    canvas.drawPath(birdPath, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BirdFlightPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}
