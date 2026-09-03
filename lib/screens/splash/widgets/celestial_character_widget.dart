import 'dart:math' as math;
import 'package:flutter/material.dart';

class CelestialCharactersWidget extends StatelessWidget {
  final double charactersProgress; // 0.0 to 1.0 (phase 4: ~4.5s to 8.5s)
  final double hoverTime; // continuous animation time

  const CelestialCharactersWidget({
    super.key,
    required this.charactersProgress,
    required this.hoverTime,
  });

  @override
  Widget build(BuildContext context) {
    if (charactersProgress <= 0.01) return const SizedBox.shrink();

    // Staggered appearance intervals:
    // 1. Ram:         0.00 -> 0.35
    // 2. Sita:        0.20 -> 0.55
    // 3. Royal King:  0.40 -> 0.75
    // 4. Flying Lion: 0.60 -> 1.00

    final ramT = ((charactersProgress - 0.00) / 0.35).clamp(0.0, 1.0);
    final sitaT = ((charactersProgress - 0.20) / 0.35).clamp(0.0, 1.0);
    final kingT = ((charactersProgress - 0.40) / 0.35).clamp(0.0, 1.0);
    final lionT = ((charactersProgress - 0.60) / 0.40).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          children: [
            // 1. Lord Ram (Bow & Arrow Aura)
            if (ramT > 0)
              _buildRamAura(w, h, ramT, hoverTime),

            // 2. Sita (Radiant Golden Sari Aura)
            if (sitaT > 0)
              _buildSitaAura(w, h, sitaT, hoverTime),

            // 3. Royal King (Crowned Regal Presence)
            if (kingT > 0)
              _buildKingAura(w, h, kingT, hoverTime),

            // 4. Flying Winged Lion (Pouncing & Flapping Wings)
            if (lionT > 0)
              _buildLionAura(w, h, lionT, hoverTime),
          ],
        );
      },
    );
  }

  // 1. LORD RAM
  Widget _buildRamAura(double w, double h, double t, double time) {
    // Curved Bezier rise from book (0.52, 0.73) to target (0.27, 0.38)
    final targetX = 0.27 * w;
    final targetY = 0.38 * h;
    final originX = 0.52 * w;
    final originY = 0.73 * h;

    final easeT = Curves.easeOutBack.transform(t);
    final curX = originX + (targetX - originX) * easeT;
    final curY = originY + (targetY - originY) * easeT;

    // Gentle vertical hover
    final hoverOffset = math.sin((time * 2.2) + 0.5) * 5.0;

    return Positioned(
      left: curX - 70,
      top: curY - 90 + hoverOffset,
      child: Opacity(
        opacity: (t * 1.0).clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.3 + (0.7 * easeT),
          child: CustomPaint(
            size: const Size(140, 180),
            painter: _RamDivinePainter(pulse: math.sin(time * 3.5)),
          ),
        ),
      ),
    );
  }

  // 2. SITA
  Widget _buildSitaAura(double w, double h, double t, double time) {
    final targetX = 0.42 * w;
    final targetY = 0.41 * h;
    final originX = 0.52 * w;
    final originY = 0.73 * h;

    final easeT = Curves.easeOutBack.transform(t);
    final curX = originX + (targetX - originX) * easeT;
    final curY = originY + (targetY - originY) * easeT;

    final hoverOffset = math.sin((time * 2.2) + 1.2) * 5.0;

    return Positioned(
      left: curX - 60,
      top: curY - 80 + hoverOffset,
      child: Opacity(
        opacity: (t * 1.0).clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.3 + (0.7 * easeT),
          child: CustomPaint(
            size: const Size(120, 160),
            painter: _SitaRadiantPainter(pulse: math.sin((time * 3.0) + 1.0)),
          ),
        ),
      ),
    );
  }

  // 3. ROYAL KING
  Widget _buildKingAura(double w, double h, double t, double time) {
    final targetX = 0.64 * w;
    final targetY = 0.32 * h;
    final originX = 0.52 * w;
    final originY = 0.73 * h;

    final easeT = Curves.easeOutBack.transform(t);
    final curX = originX + (targetX - originX) * easeT;
    final curY = originY + (targetY - originY) * easeT;

    final hoverOffset = math.sin((time * 1.8) + 2.0) * 4.0;

    return Positioned(
      left: curX - 75,
      top: curY - 90 + hoverOffset,
      child: Opacity(
        opacity: (t * 1.0).clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.3 + (0.7 * easeT),
          child: CustomPaint(
            size: const Size(150, 180),
            painter: _KingRegalPainter(pulse: math.sin((time * 2.8) + 2.0)),
          ),
        ),
      ),
    );
  }

  // 4. FLYING WINGED LION (SIMHA / YALI)
  Widget _buildLionAura(double w, double h, double t, double time) {
    final targetX = 0.70 * w;
    final targetY = 0.44 * h;
    final originX = 0.52 * w;
    final originY = 0.73 * h;

    final easeT = Curves.easeOutBack.transform(t);
    final curX = originX + (targetX - originX) * easeT;
    final curY = originY + (targetY - originY) * easeT;

    final hoverOffset = math.sin((time * 2.8) + 3.0) * 6.0;

    return Positioned(
      left: curX - 90,
      top: curY - 80 + hoverOffset,
      child: Opacity(
        opacity: (t * 1.0).clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.3 + (0.7 * easeT),
          child: CustomPaint(
            size: const Size(180, 160),
            painter: _LionWingedPainter(
              wingFlapAngle: math.sin(time * 6.0) * 0.22, // Realistic gentle wing flap!
              pulse: math.sin((time * 4.0) + 1.5),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Aura Painters for each character
class _RamDivinePainter extends CustomPainter {
  final double pulse;
  _RamDivinePainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);

    // Divine halo around Lord Ram's head
    final haloCenter = Offset(size.width * 0.52, size.height * 0.22);
    final haloRadius = 24.0 + (3.0 * pulse);
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.9),
          const Color(0xFFFFD54F).withOpacity(0.6),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: haloCenter, radius: haloRadius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.drawCircle(haloCenter, haloRadius, haloPaint);

    // Glowing Kodanda (Divine Bow) contour on left
    final bowPaint = Paint()
      ..color = const Color(0xFFFFF59D).withOpacity(0.75 + (0.2 * pulse))
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    final bowPath = Path()
      ..moveTo(size.width * 0.20, size.height * 0.15)
      ..quadraticBezierTo(
        size.width * 0.05,
        size.height * 0.55,
        size.width * 0.28,
        size.height * 0.90,
      );
    canvas.drawPath(bowPath, bowPaint);

    // Sparkle glints
    _drawSparkle(canvas, Offset(size.width * 0.20, size.height * 0.15), 5.0);
    _drawSparkle(canvas, Offset(size.width * 0.28, size.height * 0.90), 4.0);
  }

  void _drawSparkle(Canvas canvas, Offset p, double r) {
    final paint = Paint()..color = Colors.white.withOpacity(0.9);
    canvas.drawLine(Offset(p.dx - r, p.dy), Offset(p.dx + r, p.dy), paint);
    canvas.drawLine(Offset(p.dx, p.dy - r), Offset(p.dx, p.dy + r), paint);
  }

  @override
  bool shouldRepaint(covariant _RamDivinePainter oldDelegate) => true;
}

class _SitaRadiantPainter extends CustomPainter {
  final double pulse;
  _SitaRadiantPainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    // Flowing golden aura around Sita
    final center = Offset(size.width * 0.5, size.height * 0.45);
    final auraRadius = 38.0 + (5.0 * pulse);

    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF59D).withOpacity(0.55),
          const Color(0xFFFFB300).withOpacity(0.25),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: auraRadius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    canvas.drawCircle(center, auraRadius, auraPaint);

    // Shimmering jewels glint
    final paint = Paint()..color = Colors.white.withOpacity(0.85);
    canvas.drawCircle(Offset(size.width * 0.52, size.height * 0.24), 2.2, paint);
  }

  @override
  bool shouldRepaint(covariant _SitaRadiantPainter oldDelegate) => true;
}

class _KingRegalPainter extends CustomPainter {
  final double pulse;
  _KingRegalPainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    // Turban & Crown jewel radiant star
    final crownCenter = Offset(size.width * 0.50, size.height * 0.18);
    final crownGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          const Color(0xFFFFD54F).withOpacity(0.7),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: crownCenter, radius: 25))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

    canvas.drawCircle(crownCenter, 22.0 + (4.0 * pulse), crownGlow);

    // Regal shoulder aura
    final shoulderPaint = Paint()
      ..color = const Color(0xFFFFB300).withOpacity(0.25 + (0.1 * pulse))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.50, size.height * 0.55),
        width: size.width * 0.75,
        height: size.height * 0.45,
      ),
      shoulderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _KingRegalPainter oldDelegate) => true;
}

class _LionWingedPainter extends CustomPainter {
  final double wingFlapAngle;
  final double pulse;

  _LionWingedPainter({
    required this.wingFlapAngle,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maneCenter = Offset(size.width * 0.62, size.height * 0.45);

    // Radiant Solar Mane Aura
    final manePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF9C4).withOpacity(0.65),
          const Color(0xFFFF8F00).withOpacity(0.30),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: maneCenter, radius: 45))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    canvas.drawCircle(maneCenter, 42.0 + (5.0 * pulse), manePaint);

    // Animated Flapping Golden Wing!
    final wingPivot = Offset(size.width * 0.42, size.height * 0.38);

    canvas.save();
    canvas.translate(wingPivot.dx, wingPivot.dy);
    canvas.rotate(wingFlapAngle); // Dynamic wing flap rotation
    canvas.translate(-wingPivot.dx, -wingPivot.dy);

    final wingPaint = Paint()
      ..color = const Color(0xFFFFE082).withOpacity(0.80)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    // Feathered Wing Path
    final wingPath = Path()
      ..moveTo(wingPivot.dx, wingPivot.dy)
      ..quadraticBezierTo(wingPivot.dx - 25, wingPivot.dy - 35, wingPivot.dx - 5, wingPivot.dy - 55)
      ..quadraticBezierTo(wingPivot.dx + 25, wingPivot.dy - 40, wingPivot.dx + 40, wingPivot.dy - 60)
      ..quadraticBezierTo(wingPivot.dx + 50, wingPivot.dy - 30, wingPivot.dx + 20, wingPivot.dy);

    canvas.drawPath(wingPath, wingPaint);

    final wingGlowPaint = Paint()
      ..color = const Color(0xFFFFD54F).withOpacity(0.35)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.drawPath(wingPath, wingGlowPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LionWingedPainter oldDelegate) => true;
}
