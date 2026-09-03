import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConstellationPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0 (phase progress of constellation revelation)

  ConstellationPainter({required this.progress});

  // Constellation 1: Sky northern constellation (top center)
  static final List<Offset> _constellationSky = [
    const Offset(0.46, 0.12),
    const Offset(0.53, 0.14),
    const Offset(0.61, 0.18),
    const Offset(0.72, 0.15),
    const Offset(0.76, 0.11),
    const Offset(0.71, 0.10),
    const Offset(0.61, 0.18), // loop back
  ];

  // Constellation 2: Lion / Simha celestial lines (mid sky right)
  static final List<Offset> _constellationRight = [
    const Offset(0.75, 0.22),
    const Offset(0.79, 0.25),
    const Offset(0.74, 0.27),
    const Offset(0.77, 0.30),
  ];

  // Constellation 3: Spiral constellation lines ascending from holy scripture book
  static final List<Offset> _spiralNodes = [
    const Offset(0.52, 0.72), // Book origin
    const Offset(0.53, 0.67),
    const Offset(0.55, 0.63),
    const Offset(0.53, 0.58),
    const Offset(0.48, 0.54),
    const Offset(0.45, 0.49),
    const Offset(0.50, 0.44),
    const Offset(0.56, 0.40),
    const Offset(0.52, 0.35),
    const Offset(0.42, 0.31),
    const Offset(0.35, 0.29),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final w = size.width;
    final h = size.height;

    final linePaint = Paint()
      ..color = const Color(0xFFFFE082).withOpacity((progress * 0.75).clamp(0.0, 0.75))
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);

    final nodePaint = Paint()
      ..color = const Color(0xFFFFF9C4).withOpacity((progress * 0.95).clamp(0.0, 0.95))
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    final nodeGlowPaint = Paint()
      ..color = const Color(0xFFFFD54F).withOpacity((progress * 0.4).clamp(0.0, 0.4))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    // 1. Draw Sky Constellation
    _drawPathSegment(canvas, _constellationSky, progress, w, h, linePaint, nodePaint, nodeGlowPaint);

    // 2. Draw Right Sky Pattern
    if (progress > 0.2) {
      final subProg = ((progress - 0.2) / 0.8).clamp(0.0, 1.0);
      _drawPathSegment(canvas, _constellationRight, subProg, w, h, linePaint, nodePaint, nodeGlowPaint);
    }

    // 3. Draw Ascending Spiral Trail from Book
    if (progress > 0.1) {
      final spiralProg = ((progress - 0.1) / 0.9).clamp(0.0, 1.0);
      _drawSpiralTrail(canvas, _spiralNodes, spiralProg, w, h, linePaint, nodePaint, nodeGlowPaint);
    }
  }

  void _drawPathSegment(
    Canvas canvas,
    List<Offset> points,
    double prog,
    double w,
    double h,
    Paint linePaint,
    Paint nodePaint,
    Paint glowPaint,
  ) {
    if (points.isEmpty) return;

    final maxIdx = ((points.length - 1) * prog).clamp(0.0, (points.length - 1).toDouble());
    final fullSegments = maxIdx.floor();
    final partial = maxIdx - fullSegments;

    // Draw completed segments
    for (int i = 0; i < fullSegments; i++) {
      final p1 = Offset(points[i].dx * w, points[i].dy * h);
      final p2 = Offset(points[i + 1].dx * w, points[i + 1].dy * h);
      canvas.drawLine(p1, p2, linePaint);
    }

    // Draw partial segment
    if (fullSegments < points.length - 1 && partial > 0) {
      final p1 = Offset(points[fullSegments].dx * w, points[fullSegments].dy * h);
      final p2 = Offset(points[fullSegments + 1].dx * w, points[fullSegments + 1].dy * h);
      final currentEnd = Offset(
        p1.dx + (p2.dx - p1.dx) * partial,
        p1.dy + (p2.dy - p1.dy) * partial,
      );
      canvas.drawLine(p1, currentEnd, linePaint);
    }

    // Draw glowing star nodes
    final visibleNodes = (fullSegments + 1).clamp(0, points.length);
    for (int i = 0; i < visibleNodes; i++) {
      final node = Offset(points[i].dx * w, points[i].dy * h);
      canvas.drawCircle(node, 5.0, glowPaint);
      canvas.drawCircle(node, 2.2, nodePaint);
    }
  }

  void _drawSpiralTrail(
    Canvas canvas,
    List<Offset> nodes,
    double prog,
    double w,
    double h,
    Paint linePaint,
    Paint nodePaint,
    Paint glowPaint,
  ) {
    // Dotted curve connecting the holy book to the sky
    final dashedPaint = Paint()
      ..color = const Color(0xFFFFD54F).withOpacity((prog * 0.7).clamp(0.0, 0.7))
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (nodes.isNotEmpty) {
      path.moveTo(nodes[0].dx * w, nodes[0].dy * h);
      for (int i = 1; i < nodes.length; i++) {
        final prev = nodes[i - 1];
        final curr = nodes[i];
        final midX = (prev.dx + curr.dx) / 2 * w;
        final midY = (prev.dy + curr.dy) / 2 * h;
        path.quadraticBezierTo(prev.dx * w, prev.dy * h, midX, midY);
      }
    }

    // Measure animated length
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final extractLength = metric.length * prog;
      final extractedPath = metric.extractPath(0.0, extractLength);
      canvas.drawPath(extractedPath, dashedPaint);
    }

    // Nodes along spiral
    final nodeCount = (nodes.length * prog).floor();
    for (int i = 0; i < nodeCount; i++) {
      final pos = Offset(nodes[i].dx * w, nodes[i].dy * h);
      canvas.drawCircle(pos, 4.0, glowPaint);
      canvas.drawCircle(pos, 1.8, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ConstellationPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
