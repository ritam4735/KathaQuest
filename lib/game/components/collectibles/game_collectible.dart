import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum CollectibleType {
  clover,      // +10 points (leaf)
  star,        // +20 points (golden star)
  speedBerry,  // +15 points + speed boost
}

/// Collectible item with hitboxes, bobbing animation, and score values.
class GameCollectible extends PositionComponent with CollisionCallbacks {
  final CollectibleType type;
  final int points;
  Vector2 velocity = Vector2.zero();

  bool isCollected = false;
  double _bobbingTime = 0.0;
  final double _initialY;

  GameCollectible({
    required this.type,
    required Vector2 position,
    Vector2? size,
    Vector2? velocity,
    int? points,
  })  : _initialY = position.y,
        points = points ?? _defaultPointsFor(type),
        super(
          position: position,
          size: size ?? Vector2(44, 44),
          anchor: Anchor.center,
        ) {
    if (velocity != null) this.velocity = velocity;
  }

  static int _defaultPointsFor(CollectibleType type) {
    switch (type) {
      case CollectibleType.clover:
        return 10;
      case CollectibleType.star:
        return 20;
      case CollectibleType.speedBerry:
        return 15;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Circular hitbox for forgiving pickups
    add(
      CircleHitbox(
        radius: size.x * 0.42,
        position: Vector2(size.x * 0.08, size.y * 0.08),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isCollected) return;

    position += velocity * dt;

    // Bobbing animation
    _bobbingTime += dt * 4.0;
    if (velocity.y.abs() < 0.1) {
      position.y = _initialY + (sin(_bobbingTime) * 4.0);
    }
  }

  @override
  void render(Canvas canvas) {
    if (isCollected) return;
    super.render(canvas);

    // Glowing background aura
    final auraColor = type == CollectibleType.star
        ? const Color(0xFFFFD54F)
        : (type == CollectibleType.clover
            ? const Color(0xFF81C784)
            : const Color(0xFFFF8A65));

    final auraPaint = Paint()
      ..color = auraColor.withOpacity(0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x * 0.45, auraPaint);

    // Draw Emoji icon
    final textPainter = TextPainter(
      text: TextSpan(
        text: _emojiForType(),
        style: TextStyle(fontSize: size.x * 0.70),
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
      case CollectibleType.clover:
        return '🍀';
      case CollectibleType.star:
        return '⭐';
      case CollectibleType.speedBerry:
        return '🍓';
    }
  }
}
