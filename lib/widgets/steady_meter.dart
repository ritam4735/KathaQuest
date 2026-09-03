import 'dart:math';
import 'package:flutter/material.dart';

class SteadyMeter extends StatelessWidget {
  final double value; // 0.0 (too slow) to 1.0 (too fast), 0.4 - 0.6 is steady
  final bool isInSteadyZone;

  const SteadyMeter({
    super.key,
    required this.value,
    required this.isInSteadyZone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isInSteadyZone ? const Color(0xFF2EC4B6) : const Color(0xFFFF9F1C),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: isInSteadyZone
                ? const Color(0x332EC4B6)
                : const Color(0x22FF9F1C),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              size: const Size(220, 100),
              painter: _MeterPainter(value: value.clamp(0.0, 1.0)),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🐢 Too Slow',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE76F51),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: isInSteadyZone
                      ? const Color(0xFF2EC4B6)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isInSteadyZone ? '🌟 STEADY!' : 'Keep Tapping!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isInSteadyZone ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
              const Text(
                '🐰 Rushing!',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE63946),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MeterPainter extends CustomPainter {
  final double value;

  _MeterPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 10);
    final radius = size.width / 2 - 15;
    const strokeWidth = 16.0;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Slow zone: pi to pi + pi * 0.35
    basePaint.color = const Color(0xFFFFD166);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * 0.35,
      false,
      basePaint,
    );

    // Steady zone (Green): pi + pi * 0.35 to pi + pi * 0.65
    basePaint.color = const Color(0xFF2EC4B6);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi + pi * 0.35,
      pi * 0.30,
      false,
      basePaint,
    );

    // Fast zone (Red): pi + pi * 0.65 to 2 * pi
    basePaint.color = const Color(0xFFFF6B6B);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi + pi * 0.65,
      pi * 0.35,
      false,
      basePaint,
    );

    // Needle angle
    final needleAngle = pi + (pi * value);
    final needleEnd = Offset(
      center.dx + (radius - 10) * cos(needleAngle),
      center.dy + (radius - 10) * sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = const Color(0xFF2B2D42)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    // Center pivot circle
    final pivotPaint = Paint()..color = const Color(0xFF2B2D42);
    canvas.drawCircle(center, 7, pivotPaint);

    final innerPivot = Paint()..color = Colors.white;
    canvas.drawCircle(center, 3, innerPivot);
  }

  @override
  bool shouldRepaint(covariant _MeterPainter oldDelegate) =>
      oldDelegate.value != value;
}
