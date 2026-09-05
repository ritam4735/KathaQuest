import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Physical Red Victory Ribbon across the race finish line.
class FinishRibbon extends PositionComponent with CollisionCallbacks {
  bool isBroken = false;
  double _tearProgress = 0.0;
  final VoidCallback onRibbonBroken;

  FinishRibbon({
    required Vector2 position,
    required Vector2 size,
    required this.onRibbonBroken,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      RectangleHitbox(
        size: Vector2(16, size.y),
        position: Vector2((size.x - 16) / 2, 0),
      ),
    );
  }

  void breakRibbon() {
    if (isBroken) return;
    isBroken = true;
    onRibbonBroken();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isBroken && _tearProgress < 1.0) {
      _tearProgress = (_tearProgress + dt * 3.0).clamp(0.0, 1.0);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Left and right posts
    final postPaint = Paint()..color = const Color(0xFFD4AF37); // Gold posts
    canvas.drawRect(Rect.fromLTWH(0, 0, 6, size.y), postPaint);
    canvas.drawRect(Rect.fromLTWH(size.x - 6, 0, 6, size.y), postPaint);

    final ribbonPaint = Paint()
      ..color = const Color(0xFFE53935)
      ..style = PaintingStyle.fill;

    if (!isBroken) {
      // Unbroken taut red ribbon
      final rect = Rect.fromLTWH(0, size.y * 0.4, size.x, 14);
      canvas.drawRect(rect, ribbonPaint);

      // Gold text on ribbon
      final textPainter = TextPainter(
        text: const TextSpan(
          text: '🏁 FINISH 🏁',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset((size.x - textPainter.width) / 2, (size.y * 0.4) + 1),
      );
    } else {
      // Torn ribbon flutter animation
      final splitOffset = _tearProgress * (size.x * 0.35);
      final leftRect = Rect.fromLTWH(0, size.y * 0.4 + (sin(_tearProgress * 3) * 6), size.x * 0.5 - splitOffset, 12);
      final rightRect = Rect.fromLTWH(size.x * 0.5 + splitOffset, size.y * 0.4 - (sin(_tearProgress * 3) * 6), size.x * 0.5 - splitOffset, 12);

      canvas.drawRect(leftRect, ribbonPaint);
      canvas.drawRect(rightRect, ribbonPaint);
    }
  }
}
