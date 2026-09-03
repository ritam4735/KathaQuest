import 'dart:math' as math;
import 'package:flutter/material.dart';

/// CloudLayer rendering multi-tiered drifting atmospheric clouds across the upper sky.
class CloudLayer extends StatelessWidget {
  final double introProgress; // 0.0 to 1.0 (awaken stage)
  final double idleTime;      // Continuous idle time in seconds
  final double speedMultiplier;

  const CloudLayer({
    super.key,
    required this.introProgress,
    required this.idleTime,
    this.speedMultiplier = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    if (introProgress < 0.05) return const SizedBox.shrink();

    final fadeOpacity = ((introProgress - 0.05) / 0.35).clamp(0.0, 1.0);

    return RepaintBoundary(
      child: Opacity(
        opacity: fadeOpacity,
        child: CustomPaint(
          size: Size.infinite,
          painter: _CloudPainter(
            time: idleTime * speedMultiplier,
          ),
        ),
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  final double time;

  _CloudPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // We render 3 distinct depth planes of clouds:
    // 1. Far high altitude clouds (slow, soft, evening tinted)
    // 2. Mid tier clouds (medium speed, golden rim lit)
    // 3. Lower wispy clouds (faster drift)

    _drawCloudPlane(
      canvas: canvas,
      w: w,
      h: h,
      yPos: h * 0.10,
      driftSpeed: 0.015,
      cloudHeight: 65,
      cloudWidth: 260,
      count: 3,
      timeOffset: 0.0,
      color: const Color(0x38FFE0B2), // Golden peach tint
      blurRadius: 18.0,
    );

    _drawCloudPlane(
      canvas: canvas,
      w: w,
      h: h,
      yPos: h * 0.18,
      driftSpeed: 0.024,
      cloudHeight: 85,
      cloudWidth: 320,
      count: 3,
      timeOffset: 12.5,
      color: const Color(0x44FFFFFF), // Soft white golden
      blurRadius: 22.0,
    );

    _drawCloudPlane(
      canvas: canvas,
      w: w,
      h: h,
      yPos: h * 0.25,
      driftSpeed: 0.035,
      cloudHeight: 50,
      cloudWidth: 220,
      count: 4,
      timeOffset: 25.0,
      color: const Color(0x28FFF8E1), // Wispy warm amber
      blurRadius: 15.0,
    );
  }

  void _drawCloudPlane({
    required Canvas canvas,
    required double w,
    required double h,
    required double yPos,
    required double driftSpeed,
    required double cloudHeight,
    required double cloudWidth,
    required int count,
    required double timeOffset,
    required Color color,
    required double blurRadius,
  }) {
    final paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);

    final totalCycle = w + cloudWidth * 2;

    for (int i = 0; i < count; i++) {
      final initialOffset = (totalCycle / count) * i;
      final currentX = ((time + timeOffset) * driftSpeed * totalCycle + initialOffset) % totalCycle - cloudWidth;

      // Gentle vertical wave float
      final waveY = yPos + math.sin((time * 0.8) + i * 1.5) * 6.0;

      _drawPuffyCloud(canvas, currentX, waveY, cloudWidth, cloudHeight, paint);
    }
  }

  void _drawPuffyCloud(
    Canvas canvas,
    double x,
    double y,
    double width,
    double height,
    Paint paint,
  ) {
    // Cluster of overlapping soft ovals forming an organic cloud silhouette
    final rect1 = Rect.fromCenter(
      center: Offset(x + width * 0.5, y + height * 0.5),
      width: width * 0.75,
      height: height * 0.55,
    );
    final rect2 = Rect.fromCenter(
      center: Offset(x + width * 0.38, y + height * 0.42),
      width: width * 0.45,
      height: height * 0.65,
    );
    final rect3 = Rect.fromCenter(
      center: Offset(x + width * 0.62, y + height * 0.45),
      width: width * 0.42,
      height: height * 0.60,
    );
    final rect4 = Rect.fromCenter(
      center: Offset(x + width * 0.22, y + height * 0.55),
      width: width * 0.32,
      height: height * 0.42,
    );

    canvas.drawOval(rect1, paint);
    canvas.drawOval(rect2, paint);
    canvas.drawOval(rect3, paint);
    canvas.drawOval(rect4, paint);
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}
