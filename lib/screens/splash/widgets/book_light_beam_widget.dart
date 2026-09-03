import 'dart:math' as math;
import 'package:flutter/material.dart';

class BookLightBeamWidget extends StatelessWidget {
  final double awakeningProgress; // 0.0 to 1.0 (from 2.0s onwards)
  final double pulseTime; // continuous time for pulsing

  const BookLightBeamWidget({
    super.key,
    required this.awakeningProgress,
    required this.pulseTime,
  });

  @override
  Widget build(BuildContext context) {
    if (awakeningProgress <= 0.01) {
      // Dormant faint glow before awakening
      return Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: IgnorePointer(
          child: CustomPaint(
            painter: _DormantGlowPainter(),
          ),
        ),
      );
    }

    // Shaking vibration during initial awakening phase (0.0 to 0.4)
    double shakeOffset = 0.0;
    if (awakeningProgress < 0.45) {
      final shakeIntensity = (1.0 - (awakeningProgress / 0.45)) * 3.5;
      shakeOffset = math.sin(pulseTime * 50) * shakeIntensity;
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: CustomPaint(
            painter: _MagicalBeamPainter(
              progress: awakeningProgress,
              pulseTime: pulseTime,
            ),
          ),
        ),
      ),
    );
  }
}

class _DormantGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bookCenter = Offset(0.52 * w, 0.73 * h);

    // Subtle breathing dormant glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFE082).withOpacity(0.18),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: bookCenter, radius: 45))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);

    canvas.drawCircle(bookCenter, 45, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MagicalBeamPainter extends CustomPainter {
  final double progress;
  final double pulseTime;

  _MagicalBeamPainter({
    required this.progress,
    required this.pulseTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bookCenter = Offset(0.52 * w, 0.73 * h);
    final intensity = progress.clamp(0.0, 1.0);

    // 1. Radiant Upward Conical Light Beam (God-Rays)
    final beamHeight = h * 0.55 * intensity;
    final topWidth = w * (0.35 + 0.25 * intensity);
    final bottomWidth = w * 0.16;

    final beamPath = Path()
      ..moveTo(bookCenter.dx - (bottomWidth / 2), bookCenter.dy)
      ..lineTo(bookCenter.dx - (topWidth / 2), bookCenter.dy - beamHeight)
      ..lineTo(bookCenter.dx + (topWidth / 2), bookCenter.dy - beamHeight)
      ..lineTo(bookCenter.dx + (bottomWidth / 2), bookCenter.dy)
      ..close();

    final beamAlpha = (0.28 * intensity * (0.85 + 0.15 * math.sin(pulseTime * 4))).clamp(0.0, 0.45);

    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFFFFF9C4).withOpacity(beamAlpha * 1.5),
          const Color(0xFFFFD54F).withOpacity(beamAlpha),
          const Color(0xFFFFB300).withOpacity(beamAlpha * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.25, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(0, bookCenter.dy - beamHeight, w, beamHeight))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);

    canvas.drawPath(beamPath, beamPaint);

    // 2. Divine Golden Book Aura (Pulsing Circle)
    final auraRadius = (50.0 + (35.0 * intensity) + (8.0 * math.sin(pulseTime * 5)));
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.85 * intensity),
          const Color(0xFFFFE082).withOpacity(0.70 * intensity),
          const Color(0xFFFFB300).withOpacity(0.35 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.70, 1.0],
      ).createShader(Rect.fromCircle(center: bookCenter, radius: auraRadius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    canvas.drawCircle(bookCenter, auraRadius, auraPaint);

    // 3. Pages Flutter Shimmer
    if (progress > 0.2) {
      final flutterAngle = math.sin(pulseTime * 12) * 0.15;
      final shimmerPaint = Paint()
        ..color = const Color(0xFFFFF9C4).withOpacity(0.4 * intensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final shimmerRect = Rect.fromCenter(
        center: Offset(bookCenter.dx, bookCenter.dy - 6),
        width: 60,
        height: 35,
      );

      canvas.save();
      canvas.translate(bookCenter.dx, bookCenter.dy);
      canvas.rotate(flutterAngle);
      canvas.translate(-bookCenter.dx, -bookCenter.dy);
      canvas.drawRRect(RRect.fromRectAndRadius(shimmerRect, const Radius.circular(6)), shimmerPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _MagicalBeamPainter oldDelegate) => true;
}
