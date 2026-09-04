import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool isPlaying;

  const ConfettiOverlay({
    super.key,
    required this.child,
    this.isPlaying = true,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();
  bool _secondBurstTriggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        if (mounted) setState(() {});

        // Secondary burst at 30% for sustained celebration
        if (_controller.value > 0.3 && !_secondBurstTriggered) {
          _secondBurstTriggered = true;
          _addBurst(40);
        }
      });

    if (widget.isPlaying) {
      _startBurst();
    }
  }

  void _startBurst() {
    _particles.clear();
    _secondBurstTriggered = false;
    _addBurst(80);
    _controller.forward(from: 0.0);
  }

  void _addBurst(int count) {
    const colors = [
      Color(0xFFFF9F1C),
      Color(0xFF2EC4B6),
      Color(0xFFFF4081),
      Color(0xFFFFD166),
      Color(0xFF8338EC),
      Color(0xFF06D6A0),
      Color(0xFFE63946),
      Color(0xFF48BFE3),
    ];

    const shapes = [
      _ParticleShape.circle,
      _ParticleShape.rectangle,
      _ParticleShape.star,
      _ParticleShape.ribbon,
    ];

    for (int i = 0; i < count; i++) {
      _particles.add(
        _ConfettiParticle(
          x: _random.nextDouble(),
          y: -0.1 - _random.nextDouble() * 0.4,
          vx: (_random.nextDouble() - 0.5) * 0.01,
          vy: 0.003 + _random.nextDouble() * 0.007,
          size: 5 + _random.nextDouble() * 10,
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.15,
          color: colors[_random.nextInt(colors.length)],
          shape: shapes[_random.nextInt(shapes.length)],
          shimmerPhase: _random.nextDouble() * pi * 2,
          shimmerSpeed: 2.0 + _random.nextDouble() * 4.0,
          gravity: 0.0001 + _random.nextDouble() * 0.0002,
          windResistance: 0.9985 + _random.nextDouble() * 0.001,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _startBurst();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_controller.isAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _controller.value,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

enum _ParticleShape { circle, rectangle, star, ribbon }

class _ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double rotation;
  double rotationSpeed;
  Color color;
  _ParticleShape shape;
  double shimmerPhase;
  double shimmerSpeed;
  double gravity;
  double windResistance;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.shape,
    required this.shimmerPhase,
    required this.shimmerSpeed,
    required this.gravity,
    required this.windResistance,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      // Physics simulation
      p.vy += p.gravity; // Gravity
      p.vx *= p.windResistance; // Wind resistance
      p.vy *= p.windResistance;
      p.x += p.vx;
      p.y += p.vy;
      p.rotation += p.rotationSpeed;

      final posX = p.x * size.width;
      final posY = p.y * size.height;

      if (posY > size.height + 20) continue;

      canvas.save();
      canvas.translate(posX, posY);
      canvas.rotate(p.rotation);

      // Glitter shimmer effect
      final shimmer = sin(progress * p.shimmerSpeed * pi * 2 + p.shimmerPhase);
      final shimmerAlpha = (0.6 + 0.4 * shimmer).clamp(0.3, 1.0);
      final fadeAlpha = (1.0 - progress * 0.5).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = p.color.withOpacity(shimmerAlpha * fadeAlpha)
        ..style = PaintingStyle.fill;

      switch (p.shape) {
        case _ParticleShape.circle:
          canvas.drawCircle(Offset.zero, p.size / 2, paint);
          break;
        case _ParticleShape.rectangle:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.5,
            ),
            paint,
          );
          break;
        case _ParticleShape.star:
          _drawStar(canvas, p.size / 2, paint);
          break;
        case _ParticleShape.ribbon:
          _drawRibbon(canvas, p.size, paint);
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    const points = 5;
    for (int i = 0; i < points * 2; i++) {
      final r = (i % 2 == 0) ? radius : radius * 0.4;
      final angle = (i * pi / points) - pi / 2;
      final point = Offset(cos(angle) * r, sin(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawRibbon(Canvas canvas, double size, Paint paint) {
    final path = Path()
      ..moveTo(-size / 2, -size * 0.15)
      ..quadraticBezierTo(0, size * 0.3, size / 2, -size * 0.15)
      ..lineTo(size / 2, size * 0.15)
      ..quadraticBezierTo(0, -size * 0.3, -size / 2, size * 0.15)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
