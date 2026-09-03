import 'dart:math' as math;
import 'package:flutter/material.dart';

class MagicalSkyVeilWidget extends StatelessWidget {
  final double revealProgress; // 0.0 to 1.0 (phase 4: ~4.2s to 8.0s)
  final double pulseTime;

  const MagicalSkyVeilWidget({
    super.key,
    required this.revealProgress,
    required this.pulseTime,
  });

  @override
  Widget build(BuildContext context) {
    // If characters have fully materialized (revealProgress >= 1.0), veil is completely gone
    if (revealProgress >= 1.0) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _SkyVeilPainter(
            revealProgress: revealProgress,
            pulseTime: pulseTime,
          ),
        ),
      ),
    );
  }
}

class _SkyVeilPainter extends CustomPainter {
  final double revealProgress;
  final double pulseTime;

  _SkyVeilPainter({
    required this.revealProgress,
    required this.pulseTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // The zone where the 4 celestial characters reside:
    // From y = 0.16 * h to 0.60 * h
    final topY = 0.16 * h;
    final bottomY = 0.60 * h;
    final veilRect = Rect.fromLTRB(0, topY, w, bottomY);

    // Staggered reveal progress for the 4 character apertures:
    final ramProg = ((revealProgress - 0.00) / 0.35).clamp(0.0, 1.0);
    final sitaProg = ((revealProgress - 0.20) / 0.35).clamp(0.0, 1.0);
    final kingProg = ((revealProgress - 0.40) / 0.35).clamp(0.0, 1.0);
    final lionProg = ((revealProgress - 0.60) / 0.40).clamp(0.0, 1.0);

    // Character center positions in splash_hero_art.jpg:
    final ramCenter = Offset(0.27 * w, 0.39 * h);
    final sitaCenter = Offset(0.42 * w, 0.42 * h);
    final kingCenter = Offset(0.63 * w, 0.33 * h);
    final lionCenter = Offset(0.70 * w, 0.45 * h);

    // Overall opacity of the veil (fades out as characters appear)
    final overallAlpha = (1.0 - (revealProgress * 1.1)).clamp(0.0, 0.88);
    if (overallAlpha <= 0.01) return;

    // Use saveLayer to allow transparent punch-out apertures (BlendMode.dstOut)
    canvas.saveLayer(veilRect, Paint());

    // 1. Base Twilight Night Veil matching the courtyard sky & palace palette
    final veilPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFF20132F).withOpacity(overallAlpha),
          const Color(0xFF2C193C).withOpacity(overallAlpha * 0.95),
          const Color(0xFF1E1026).withOpacity(overallAlpha * 0.90),
          Colors.transparent,
        ],
        stops: const [0.0, 0.15, 0.50, 0.85, 1.0],
      ).createShader(veilRect);

    canvas.drawRect(veilRect, veilPaint);

    // 2. Punch Out Character Apertures with BlendMode.dstOut as they materialize!
    final cutPaint = Paint()..blendMode = BlendMode.dstOut;

    // Ram Aperture
    if (ramProg > 0) {
      final r = (w * 0.22) * Curves.easeOutCubic.transform(ramProg);
      _drawAperture(canvas, ramCenter, r, cutPaint);
    }

    // Sita Aperture
    if (sitaProg > 0) {
      final r = (w * 0.18) * Curves.easeOutCubic.transform(sitaProg);
      _drawAperture(canvas, sitaCenter, r, cutPaint);
    }

    // King Aperture
    if (kingProg > 0) {
      final r = (w * 0.22) * Curves.easeOutCubic.transform(kingProg);
      _drawAperture(canvas, kingCenter, r, cutPaint);
    }

    // Flying Lion Aperture
    if (lionProg > 0) {
      final r = (w * 0.25) * Curves.easeOutCubic.transform(lionProg);
      _drawAperture(canvas, lionCenter, r, cutPaint);
    }

    canvas.restore();

    // 3. Golden Radiant Smoke & Burst Rings around each newly opening aperture
    _drawBurstRing(canvas, ramCenter, w * 0.22, ramProg, pulseTime);
    _drawBurstRing(canvas, sitaCenter, w * 0.18, sitaProg, pulseTime + 1);
    _drawBurstRing(canvas, kingCenter, w * 0.22, kingProg, pulseTime + 2);
    _drawBurstRing(canvas, lionCenter, w * 0.25, lionProg, pulseTime + 3);
  }

  void _drawAperture(Canvas canvas, Offset center, double radius, Paint cutPaint) {
    final gradient = RadialGradient(
      colors: [
        Colors.black,
        Colors.black.withOpacity(0.8),
        Colors.transparent,
      ],
      stops: const [0.0, 0.65, 1.0],
    );
    final paint = Paint()
      ..blendMode = BlendMode.dstOut
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  void _drawBurstRing(Canvas canvas, Offset center, double maxRadius, double prog, double time) {
    if (prog <= 0.05 || prog >= 0.95) return;

    // Burst ring expands from center
    final r = maxRadius * Curves.easeOutQuad.transform(prog);
    final alpha = (1.0 - prog) * 0.75;

    final ringPaint = Paint()
      ..color = const Color(0xFFFFD54F).withOpacity(alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(center, r, ringPaint);

    // Radiant sparkle rays
    final rayPaint = Paint()
      ..color = Colors.white.withOpacity(alpha * 0.8)
      ..strokeWidth = 1.2;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + (time * 2);
      final p1 = Offset(center.dx + math.cos(angle) * (r * 0.7), center.dy + math.sin(angle) * (r * 0.7));
      final p2 = Offset(center.dx + math.cos(angle) * (r * 1.15), center.dy + math.sin(angle) * (r * 1.15));
      canvas.drawLine(p1, p2, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SkyVeilPainter oldDelegate) => true;
}
