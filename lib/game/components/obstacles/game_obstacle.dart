import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum ObstacleType {
  bramble,   // Thorns (damages health)
  mud,       // Mud puddle (slows down)
  rock,      // Low stone (requires jumping)
  hurdle,    // Track hurdle
}

/// Collidable obstacles with physics, movement velocity, and damage effects.
class GameObstacle extends PositionComponent with CollisionCallbacks {
  final ObstacleType type;
  Vector2 velocity = Vector2.zero();

  final int damage;
  final bool causesSlowdown;
  bool hasCollided = false;

  GameObstacle({
    required this.type,
    required Vector2 position,
    Vector2? size,
    Vector2? velocity,
    this.damage = 1,
    this.causesSlowdown = false,
  }) : super(
          position: position,
          size: size ?? Vector2(48, 48),
          anchor: Anchor.center,
        ) {
    if (velocity != null) this.velocity = velocity;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add collision hitbox
    final hitboxSize = Vector2(size.x * 0.75, size.y * 0.75);
    add(
      RectangleHitbox(
        size: hitboxSize,
        position: (size - hitboxSize) / 2,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y * 0.88),
        width: size.x * 0.7,
        height: size.y * 0.25,
      ),
      shadowPaint,
    );

    // Draw obstacle graphic
    final textPainter = TextPainter(
      text: TextSpan(
        text: _emojiForType(),
        style: TextStyle(fontSize: size.x * 0.72),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2 - 2),
    );
  }

  String _emojiForType() {
    switch (type) {
      case ObstacleType.bramble:
        return '🪵';
      case ObstacleType.mud:
        return '🟫';
      case ObstacleType.rock:
        return '🪨';
      case ObstacleType.hurdle:
        return '🚧';
    }
  }
}
