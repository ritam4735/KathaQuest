import 'dart:math' as math;
import 'package:flutter/material.dart';

class ClosedBookWidget extends StatelessWidget {
  final double progress; // 0.0 to 1.0 (from 0s to ~4.5s)
  final double pulseTime;

  const ClosedBookWidget({
    super.key,
    required this.progress,
    required this.pulseTime,
  });

  @override
  Widget build(BuildContext context) {
    // Once book has fully opened (progress >= 1.0), it disappears completely
    if (progress >= 1.0) return const SizedBox.shrink();

    // Opening progression:
    // 0.0 to 0.45: Closed, dormant, then vibrating
    // 0.45 to 1.0: Cover flips open (0 to -pi/2), fading out to reveal open book underneath
    final shakeProgress = (progress / 0.45).clamp(0.0, 1.0);
    final openProgress = ((progress - 0.45) / 0.55).clamp(0.0, 1.0);

    double shakeX = 0.0;
    if (progress > 0.15 && progress < 0.55) {
      final intensity = math.sin(shakeProgress * math.pi) * 3.5;
      shakeX = math.sin(pulseTime * 50) * intensity;
    }

    final coverAngle = openProgress * (math.pi / 1.8);
    final opacity = (1.0 - (openProgress * 1.2)).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Position directly over the scripture book stand in splash_hero_art.jpg
        // Book center is at x ≈ 0.52 * w, y ≈ 0.74 * h
        final bookWidth = (w * 0.36).clamp(130.0, 260.0);
        final bookHeight = bookWidth * 0.58;

        return Stack(
          children: [
            Positioned(
              left: (0.52 * w) - (bookWidth / 2) + shakeX,
              top: (0.74 * h) - (bookHeight / 2),
              width: bookWidth,
              height: bookHeight,
              child: Opacity(
                opacity: opacity,
                child: Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0018)
                    ..rotateY(-coverAngle),
                  child: CustomPaint(
                    size: Size(bookWidth, bookHeight),
                    painter: _ClosedBookPainter(
                      progress: progress,
                      pulseTime: pulseTime,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ClosedBookPainter extends CustomPainter {
  final double progress;
  final double pulseTime;

  _ClosedBookPainter({
    required this.progress,
    required this.pulseTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(8),
    );

    // 1. Deep Maroon Ancient Leather Cover
    final bookPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF5D101D), // Royal Crimson
          Color(0xFF3B0A12), // Deep Shadow Maroon
          Color(0xFF22050B),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Shadow underneath book
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(rect.shift(const Offset(0, 6)), shadowPaint);

    // Draw Book Cover
    canvas.drawRRect(rect, bookPaint);

    // 2. Embossed Golden Border Tooling
    final borderRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(6, 6, w - 12, h - 12),
      const Radius.circular(5),
    );
    final borderPaint = Paint()
      ..color = const Color(0xFFFFD54F).withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawRRect(borderRect, borderPaint);

    // Inner fine filigree line
    final innerBorderRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 10, w - 20, h - 20),
      const Radius.circular(4),
    );
    final innerBorderPaint = Paint()
      ..color = const Color(0xFFFFE082).withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawRRect(innerBorderRect, innerBorderPaint);

    // 3. Golden Corner Guards (Brass Brackets)
    final cornerPaint = Paint()..color = const Color(0xFFFFD54F);
    _drawCornerPlate(canvas, const Offset(6, 6), 10, cornerPaint);
    _drawCornerPlate(canvas, Offset(w - 6, 6), 10, cornerPaint);
    _drawCornerPlate(canvas, Offset(6, h - 6), 10, cornerPaint);
    _drawCornerPlate(canvas, Offset(w - 6, h - 6), 10, cornerPaint);

    // 4. Center Golden Mandala / Royal Seal
    final center = Offset(w / 2, h / 2);
    final mandalaPaint = Paint()
      ..color = const Color(0xFFFFE082).withOpacity(0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, h * 0.26, mandalaPaint);
    canvas.drawCircle(center, h * 0.16, mandalaPaint);

    // Mandala petals
    for (int i = 0; i < 8; i++) {
      final angle = i * (math.pi / 4);
      final petalCenter = Offset(
        center.dx + math.cos(angle) * (h * 0.21),
        center.dy + math.sin(angle) * (h * 0.21),
      );
      canvas.drawCircle(petalCenter, 2.5, Paint()..color = const Color(0xFFFFD54F));
    }

    // 5. Center Golden Clasp Lock
    final claspPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFF9C4), Color(0xFFFFB300), Color(0xFFFF8F00)],
      ).createShader(Rect.fromLTWH(center.dx - 8, center.dy - 12, 16, 24));
    final claspRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 14, height: 22),
      const Radius.circular(4),
    );
    canvas.drawRRect(claspRect, claspPaint);

    // 6. Glowing Leaks from Cover Seams (intensifies as progress approaches 0.45)
    if (progress > 0.1) {
      final glowIntensity = (progress / 0.45).clamp(0.0, 1.0);
      final seamGlowPaint = Paint()
        ..color = const Color(0xFFFFF9C4).withOpacity(glowIntensity * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      // Light leaking from left, right, and top edges
      canvas.drawLine(Offset(2, 4), Offset(2, h - 4), seamGlowPaint);
      canvas.drawLine(Offset(w - 2, 4), Offset(w - 2, h - 4), seamGlowPaint);
      canvas.drawLine(Offset(4, 2), Offset(w - 4, 2), seamGlowPaint);
    }
  }

  void _drawCornerPlate(Canvas canvas, Offset p, double size, Paint paint) {
    final path = Path()
      ..moveTo(p.dx, p.dy)
      ..lineTo(p.dx + (p.dx < 100 ? size : -size), p.dy)
      ..lineTo(p.dx, p.dy + (p.dy < 100 ? size : -size))
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ClosedBookPainter oldDelegate) => true;
}
