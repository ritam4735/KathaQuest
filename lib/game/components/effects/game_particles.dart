import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Single visual particle simulated on Canvas for zero GC overhead.
class _ParticleData {
  Vector2 position;
  Vector2 velocity;
  Color color;
  double size;
  double maxLife;
  double remainingLife;
  double rotation;
  double rotationSpeed;
  bool isSquare;

  _ParticleData({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.maxLife,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
    this.isSquare = false,
  }) : remainingLife = maxLife;

  double get progress => (1.0 - (remainingLife / maxLife)).clamp(0.0, 1.0);
  bool get isDead => remainingLife <= 0.0;
}

/// Lightweight, high-performance particle emitter component.
/// Draws directly to canvas, reusing paint to avoid garbage collection.
class GameParticleEmitter extends Component {
  final List<_ParticleData> _particles = [];
  final Paint _paint = Paint()..isAntiAlias = true;
  final Random _random = Random();

  /// Whether the emitter can be removed once all particles expire.
  final bool autoRemove;

  GameParticleEmitter({this.autoRemove = true});

  bool get hasActiveParticles => _particles.isNotEmpty;

  @override
  void update(double dt) {
    super.update(dt);
    if (_particles.isEmpty) {
      if (autoRemove && isMounted) {
        removeFromParent();
      }
      return;
    }

    for (int i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.remainingLife -= dt;
      if (p.isDead) {
        _particles.removeAt(i);
        continue;
      }

      // Physics update
      p.position += p.velocity * dt;
      p.rotation += p.rotationSpeed * dt;

      // Subtle air resistance
      p.velocity *= (1.0 - (dt * 1.5)).clamp(0.0, 1.0);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_particles.isEmpty) return;

    for (final p in _particles) {
      final alpha = (1.0 - p.progress).clamp(0.0, 1.0);
      _paint.color = p.color.withOpacity(alpha);

      final currentSize = p.size * (1.0 - (p.progress * 0.4));

      canvas.save();
      canvas.translate(p.position.x, p.position.y);
      if (p.rotation != 0.0) {
        canvas.rotate(p.rotation);
      }

      if (p.isSquare) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: currentSize, height: currentSize),
          _paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, currentSize / 2, _paint);
      }

      canvas.restore();
    }
  }

  // --- Particle Spawning Presets ---

  /// Emerald leaf sparkles when collecting clovers
  void emitCloverBurst(Vector2 position, {int count = 10}) {
    final colors = [
      const Color(0xFF00E676),
      const Color(0xFF69F0AE),
      const Color(0xFFB9F6CA),
      const Color(0xFF81C784),
    ];
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 70.0 + _random.nextDouble() * 120.0;
      _particles.add(
        _ParticleData(
          position: position.clone(),
          velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
          color: colors[_random.nextInt(colors.length)],
          size: 6.0 + _random.nextDouble() * 7.0,
          maxLife: 0.35 + _random.nextDouble() * 0.3,
          rotation: _random.nextDouble() * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 6.0,
        ),
      );
    }
  }

  /// Golden sparkle stars for star collection and Rhythm PERFECT
  void emitStarBurst(Vector2 position, {int count = 14}) {
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFFFEA00),
      const Color(0xFFFFB300),
      const Color(0xFFFFFFFF),
    ];
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi + (_random.nextDouble() * 0.3);
      final speed = 90.0 + _random.nextDouble() * 140.0;
      _particles.add(
        _ParticleData(
          position: position.clone(),
          velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
          color: colors[_random.nextInt(colors.length)],
          size: 7.0 + _random.nextDouble() * 8.0,
          maxLife: 0.45 + _random.nextDouble() * 0.35,
          rotation: _random.nextDouble() * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 8.0,
          isSquare: _random.nextBool(),
        ),
      );
    }
  }

  /// Dust puff cloud emitted on jump takeoff and landing
  void emitDustPuff(Vector2 position, {int count = 8}) {
    final colors = [
      const Color(0xFFBDBDBD),
      const Color(0xFFE0E0E0),
      const Color(0xFFEEEEEE),
    ];
    for (int i = 0; i < count; i++) {
      final angle = pi + (_random.nextDouble() * 0.8 - 0.4); // slightly spread backward
      final speed = 30.0 + _random.nextDouble() * 60.0;
      _particles.add(
        _ParticleData(
          position: position.clone() + Vector2((_random.nextDouble() - 0.5) * 16, 0),
          velocity: Vector2(cos(angle) * speed, -15.0 - (_random.nextDouble() * 30.0)),
          color: colors[_random.nextInt(colors.length)],
          size: 5.0 + _random.nextDouble() * 6.0,
          maxLife: 0.30 + _random.nextDouble() * 0.25,
        ),
      );
    }
  }

  /// Brown splatter droplets when hitting mud
  void emitMudSplash(Vector2 position, {int count = 12}) {
    final colors = [
      const Color(0xFF795548),
      const Color(0xFF5D4037),
      const Color(0xFF8D6E63),
    ];
    for (int i = 0; i < count; i++) {
      final angle = -pi * 0.8 + (_random.nextDouble() * pi * 0.6);
      final speed = 60.0 + _random.nextDouble() * 90.0;
      _particles.add(
        _ParticleData(
          position: position.clone(),
          velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
          color: colors[_random.nextInt(colors.length)],
          size: 5.0 + _random.nextDouble() * 6.0,
          maxLife: 0.40 + _random.nextDouble() * 0.25,
        ),
      );
    }
  }

  /// Wood debris chips when hitting thorny brambles or hurdles
  void emitWoodChips(Vector2 position, {int count = 10}) {
    final colors = [
      const Color(0xFF8D6E63),
      const Color(0xFFA1887F),
      const Color(0xFFFF7043),
      const Color(0xFFE64A19),
    ];
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 80.0 + _random.nextDouble() * 110.0;
      _particles.add(
        _ParticleData(
          position: position.clone(),
          velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
          color: colors[_random.nextInt(colors.length)],
          size: 5.0 + _random.nextDouble() * 5.0,
          maxLife: 0.35 + _random.nextDouble() * 0.25,
          rotation: _random.nextDouble() * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 10.0,
          isSquare: true,
        ),
      );
    }
  }

  /// Confetti explosion with vibrant colored streamers for sprint finish celebration
  void emitConfetti(Vector2 position, {int count = 30}) {
    final colors = [
      const Color(0xFFFF1744),
      const Color(0xFFFFEA00),
      const Color(0xFF00E676),
      const Color(0xFF2979FF),
      const Color(0xFFFF4081),
      const Color(0xFF00E5FF),
      const Color(0xFFFF9100),
    ];
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 80.0 + _random.nextDouble() * 220.0;
      _particles.add(
        _ParticleData(
          position: position.clone(),
          velocity: Vector2(cos(angle) * speed, sin(angle) * speed - 60.0), // upward boost
          color: colors[_random.nextInt(colors.length)],
          size: 6.0 + _random.nextDouble() * 7.0,
          maxLife: 0.70 + _random.nextDouble() * 0.60,
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 12.0,
          isSquare: true,
        ),
      );
    }
  }

  /// Expanding glowing ripple ring on rhythm tap
  void emitRhythmTap(Vector2 position, Color color) {
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8.0) * 2 * pi;
      const speed = 70.0;
      _particles.add(
        _ParticleData(
          position: position.clone(),
          velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
          color: color,
          size: 4.0,
          maxLife: 0.28,
        ),
      );
    }
  }
}
