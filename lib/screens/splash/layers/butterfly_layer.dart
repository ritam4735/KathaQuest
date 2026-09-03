import 'dart:math' as math;
import 'package:flutter/material.dart';

/// ButterflyLayer rendering jewel-toned animated butterflies fluttering near the flower gardens.
class ButterflyLayer extends StatelessWidget {
  final double introProgress; // 0.0 to 1.0
  final double idleTime;      // Continuous idle time in seconds

  const ButterflyLayer({
    super.key,
    required this.introProgress,
    required this.idleTime,
  });

  @override
  Widget build(BuildContext context) {
    if (introProgress < 0.20) return const SizedBox.shrink();

    final opacity = ((introProgress - 0.20) / 0.30).clamp(0.0, 1.0);

    return RepaintBoundary(
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          size: Size.infinite,
          painter: _ButterflyPainter(time: idleTime),
        ),
      ),
    );
  }
}

class _ButterflyPainter extends CustomPainter {
  final double time;

  _ButterflyPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Golden Saffron Butterfly dancing on the left near flowers
    _drawButterfly(
      canvas: canvas,
      center: Offset(
        w * 0.24 + math.sin(time * 1.3) * 35.0 + math.cos(time * 0.7) * 15.0,
        h * 0.72 + math.cos(time * 1.8) * 25.0 + math.sin(time * 0.9) * 12.0,
      ),
      scale: 1.0,
      flapTime: time * 12.0,
      headingAngle: math.sin(time * 1.3) * 0.3 - 0.2,
      wingColor1: const Color(0xFFFFB300), // Amber Gold
      wingColor2: const Color(0xFFFF6F00), // Saffron Orange
    );

    // 2. Emerald Teal Butterfly dancing near the book and right foliage
    _drawButterfly(
      canvas: canvas,
      center: Offset(
        w * 0.76 + math.cos(time * 1.1 + 1.5) * 40.0 + math.sin(time * 0.5) * 15.0,
        h * 0.68 + math.sin(time * 1.6 + 2.0) * 28.0 + math.cos(time * 0.8) * 14.0,
      ),
      scale: 0.85,
      flapTime: (time + 1.7) * 13.5,
      headingAngle: math.cos(time * 1.1) * 0.3 + 0.15,
      wingColor1: const Color(0xFF00E676), // Bright Emerald
      wingColor2: const Color(0xFF00B0FF), // Peacock Cyan
    );

    // 3. Royal Violet Shimmer Butterfly dancing higher in the middle
    _drawButterfly(
      canvas: canvas,
      center: Offset(
        w * 0.48 + math.sin(time * 0.9 + 3.0) * 45.0,
        h * 0.58 + math.cos(time * 1.4 + 1.0) * 20.0,
      ),
      scale: 0.70,
      flapTime: (time + 3.2) * 11.0,
      headingAngle: math.sin(time * 0.9) * 0.25,
      wingColor1: const Color(0xFFEA80FC), // Celestial Violet
      wingColor2: const Color(0xFFFFD54F), // Golden trim
    );
  }

  void _drawButterfly({
    required Canvas canvas,
    required Offset center,
    required double scale,
    required double flapTime,
    required double headingAngle,
    required Color wingColor1,
    required Color wingColor2,
  }) {
    // Flap cycles width scale from 0.15 (wings closed) to 1.0 (wings spread)
    final flapPhase = (math.sin(flapTime) + 1.0) * 0.5; // 0.0 to 1.0
    final wingWidthScale = 0.20 + (0.80 * flapPhase);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(headingAngle);
    canvas.scale(scale);

    // Soft magical sparkle halo
    final auraPaint = Paint()
      ..color = wingColor1.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
    canvas.drawCircle(Offset.zero, 12.0, auraPaint);

    // Butterfly Body
    final bodyPaint = Paint()..color = const Color(0xFF2C1810);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 2.2, height: 10.0),
      bodyPaint,
    );

    // Antennae
    final antPaint = Paint()
      ..color = const Color(0xFF2C1810)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, -4), const Offset(-3, -8), antPaint);
    canvas.drawLine(const Offset(0, -4), const Offset(3, -8), antPaint);

    // Wings (Left & Right) with 3D flap width scale
    _drawWingPair(canvas, wingWidthScale, wingColor1, wingColor2);

    canvas.restore();
  }

  void _drawWingPair(
    Canvas canvas,
    double widthScale,
    Color color1,
    Color color2,
  ) {
    // Upper Wing Path (Right)
    final rUpper = Path()
      ..moveTo(0, -2)
      ..cubicTo(8 * widthScale, -12, 16 * widthScale, -4, 12 * widthScale, 2)
      ..cubicTo(8 * widthScale, 4, 2 * widthScale, 2, 0, 0);

    // Lower Wing Path (Right)
    final rLower = Path()
      ..moveTo(0, 0)
      ..cubicTo(8 * widthScale, 2, 11 * widthScale, 8, 7 * widthScale, 10)
      ..cubicTo(3 * widthScale, 10, 1 * widthScale, 4, 0, 3);

    final wingGradientRight = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [color2, color1],
    );

    final wingPaintR = Paint()
      ..shader = wingGradientRight.createShader(Rect.fromLTWH(0, -12, 16 * widthScale, 22));

    canvas.drawPath(rUpper, wingPaintR);
    canvas.drawPath(rLower, wingPaintR);

    // Left Wings (mirrored)
    canvas.save();
    canvas.scale(-1.0, 1.0);
    final wingGradientLeft = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [color2, color1],
    );
    final wingPaintL = Paint()
      ..shader = wingGradientLeft.createShader(Rect.fromLTWH(0, -12, 16 * widthScale, 22));
    canvas.drawPath(rUpper, wingPaintL);
    canvas.drawPath(rLower, wingPaintL);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ButterflyPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}
