import 'dart:async';
import 'package:flutter/material.dart';

class SpriteAnimationData {
  final String folder;
  final String prefix;
  final int frameCount;
  final int defaultFps;

  const SpriteAnimationData({
    required this.folder,
    required this.prefix,
    required this.frameCount,
    this.defaultFps = 8,
  });

  String getFramePath(int index) => '$folder/${prefix}_$index.png';
}

class AnimatedSpriteWidget extends StatefulWidget {
  final String animation;
  final double? width;
  final double? height;
  final bool flipX;
  final bool loop;
  final int? fps;
  final BoxFit fit;
  final VoidCallback? onComplete;

  const AnimatedSpriteWidget({
    super.key,
    required this.animation,
    this.width,
    this.height,
    this.flipX = false,
    this.loop = true,
    this.fps,
    this.fit = BoxFit.contain,
    this.onComplete,
  });

  static final Map<String, SpriteAnimationData> registry = {
    // Hare
    'hare_idle': const SpriteAnimationData(
      folder: 'assets/spritesheets/hare/idle',
      prefix: 'hare_idle',
      frameCount: 6,
      defaultFps: 6,
    ),
    'hare_walk': const SpriteAnimationData(
      folder: 'assets/spritesheets/hare/walk',
      prefix: 'hare_walk',
      frameCount: 8,
      defaultFps: 8,
    ),
    'hare_run': const SpriteAnimationData(
      folder: 'assets/spritesheets/hare/run',
      prefix: 'hare_run',
      frameCount: 8,
      defaultFps: 12,
    ),
    'hare_happy': const SpriteAnimationData(
      folder: 'assets/spritesheets/hare/happy',
      prefix: 'hare_happy',
      frameCount: 6,
      defaultFps: 8,
    ),
    'hare_sleep': const SpriteAnimationData(
      folder: 'assets/spritesheets/hare/sleep',
      prefix: 'hare_sleep',
      frameCount: 6,
      defaultFps: 4,
    ),
    'hare_surprised': const SpriteAnimationData(
      folder: 'assets/spritesheets/hare/surprised',
      prefix: 'hare_surprised',
      frameCount: 5,
      defaultFps: 6,
    ),
    'hare_cheer': const SpriteAnimationData(
      folder: 'assets/spritesheets/hare/cheer',
      prefix: 'hare_cheer',
      frameCount: 6,
      defaultFps: 8,
    ),

    // Tortoise
    'tortoise_idle': const SpriteAnimationData(
      folder: 'assets/spritesheets/tortoise/idle',
      prefix: 'tortoise_idle',
      frameCount: 8,
      defaultFps: 6,
    ),
    'tortoise_walk': const SpriteAnimationData(
      folder: 'assets/spritesheets/tortoise/walk',
      prefix: 'tortoise_walk',
      frameCount: 8,
      defaultFps: 6,
    ),
    'tortoise_run': const SpriteAnimationData(
      folder: 'assets/spritesheets/tortoise/run',
      prefix: 'tortoise_run',
      frameCount: 8,
      defaultFps: 10,
    ),
    'tortoise_sleep': const SpriteAnimationData(
      folder: 'assets/spritesheets/tortoise/sleep',
      prefix: 'tortoise_sleep',
      frameCount: 6,
      defaultFps: 4,
    ),
    'tortoise_climb': const SpriteAnimationData(
      folder: 'assets/spritesheets/tortoise/climb',
      prefix: 'tortoise_climb',
      frameCount: 6,
      defaultFps: 6,
    ),
    'tortoise_win': const SpriteAnimationData(
      folder: 'assets/spritesheets/tortoise/win',
      prefix: 'tortoise_win',
      frameCount: 5,
      defaultFps: 7,
    ),
  };

  @override
  State<AnimatedSpriteWidget> createState() => _AnimatedSpriteWidgetState();
}

class _AnimatedSpriteWidgetState extends State<AnimatedSpriteWidget> {
  int _currentFrame = 0;
  Timer? _timer;

  SpriteAnimationData? get _animData =>
      AnimatedSpriteWidget.registry[widget.animation];

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void didUpdateWidget(covariant AnimatedSpriteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation ||
        oldWidget.fps != widget.fps ||
        oldWidget.loop != widget.loop) {
      _currentFrame = 0;
      _startAnimation();
    }
  }

  void _startAnimation() {
    _timer?.cancel();
    final data = _animData;
    if (data == null || data.frameCount <= 1) return;

    final effectiveFps = widget.fps ?? data.defaultFps;
    final interval = Duration(milliseconds: (1000 / effectiveFps).round());

    _timer = Timer.periodic(interval, (timer) {
      if (!mounted) return;
      setState(() {
        if (_currentFrame < data.frameCount - 1) {
          _currentFrame++;
        } else {
          if (widget.loop) {
            _currentFrame = 0;
          } else {
            _timer?.cancel();
            widget.onComplete?.call();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _animData;
    if (data == null) {
      // Fallback
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: Icon(Icons.pets_rounded, color: Colors.orange, size: 36),
        ),
      );
    }

    final framePath = data.getFramePath(_currentFrame);

    Widget imageWidget = Image.asset(
      framePath,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: const Icon(Icons.broken_image_rounded, size: 32),
        );
      },
    );

    if (widget.flipX) {
      imageWidget = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
