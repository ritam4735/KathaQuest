import 'package:flutter/material.dart';

/// Reusable multi-plane Parallax Layer for depth-based animation and positioning.
class ParallaxLayer extends StatelessWidget {
  final Widget child;
  final double depth;
  final Offset baseOffset;
  final double idleTime;
  final double scale;
  final double rotation;
  final Alignment alignment;
  final bool enableRepaintBoundary;

  const ParallaxLayer({
    super.key,
    required this.child,
    this.depth = 1.0,
    this.baseOffset = Offset.zero,
    this.idleTime = 0.0,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.alignment = Alignment.center,
    this.enableRepaintBoundary = true,
  });

  @override
  Widget build(BuildContext context) {
    // Subtle natural floating drift based on depth plane
    final driftX = baseOffset.dx * depth;
    final driftY = baseOffset.dy * depth;

    Widget content = Transform(
      alignment: alignment,
      transform: Matrix4.identity()
        ..translate(driftX, driftY)
        ..scale(scale)
        ..rotateZ(rotation),
      child: child,
    );

    if (enableRepaintBoundary) {
      content = RepaintBoundary(child: content);
    }

    return content;
  }
}
