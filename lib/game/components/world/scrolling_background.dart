import 'dart:ui' as ui;
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Scenic background layer that can scroll continuously or remain static.
class ScrollingBackground extends PositionComponent {
  final String imagePath;
  Vector2 scrollSpeed;
  ui.Image? _image;
  final Images _images = Images(prefix: '');

  Vector2 _offset = Vector2.zero();

  ScrollingBackground({
    required this.imagePath,
    required Vector2 size,
    Vector2? scrollSpeed,
  })  : scrollSpeed = scrollSpeed ?? Vector2.zero(),
        super(size: size, position: Vector2.zero());

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      _image = await _images.load(imagePath);
    } catch (e) {
      _image = null;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (scrollSpeed.length2 > 0) {
      _offset += scrollSpeed * dt;
      if (_offset.x >= size.x) _offset.x -= size.x;
      if (_offset.y >= size.y) _offset.y -= size.y;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (_image != null) {
      final src = Rect.fromLTWH(0, 0, _image!.width.toDouble(), _image!.height.toDouble());
      final dst = Rect.fromLTWH(0, 0, size.x, size.y);
      canvas.drawImageRect(_image!, src, dst, Paint());

      // Overlay slight contrast shade
      canvas.drawRect(
        dst,
        Paint()..color = Colors.black.withOpacity(0.08),
      );
    } else {
      // Fallback gradient
      final rect = Rect.fromLTWH(0, 0, size.x, size.y);
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.green.shade100, Colors.green.shade300],
      );
      canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
    }
  }
}
