import 'dart:ui' as ui;
import 'package:flame/cache.dart';
import 'package:flame/components.dart';

enum CharacterAnimationState {
  idle,
  walk,
  run,
  jump,
  sleep,
  hit,
  collect,
  win,
  lose,
  surprised,
  cheer,
}

/// Centralized manager that loads master sprite sheets and constructs Flame SpriteAnimations.
class SpriteSheetManager {
  static final SpriteSheetManager _instance = SpriteSheetManager._internal();
  factory SpriteSheetManager() => _instance;
  SpriteSheetManager._internal();

  final Images _spritesheetImages = Images(prefix: 'assets/spritesheets/');
  ui.Image? _rabbitSheet;
  ui.Image? _turtleSheet;

  final Map<CharacterAnimationState, SpriteAnimation> _tortoiseAnimations = {};
  final Map<CharacterAnimationState, SpriteAnimation> _hareAnimations = {};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> loadAll() async {
    if (_isLoaded) return;

    try {
      _rabbitSheet = await _spritesheetImages.load('rabbit_transparent.png');
      _turtleSheet = await _spritesheetImages.load('turtle_transparent.png');

      _buildTortoiseAnimations();
      _buildHareAnimations();
      _isLoaded = true;
    } catch (e) {
      // Fallback if needed
      _isLoaded = false;
    }
  }

  void _buildTortoiseAnimations() {
    if (_turtleSheet == null) return;
    final img = _turtleSheet!;

    // Tortoise Idle (8 frames)
    _tortoiseAnimations[CharacterAnimationState.idle] = _sliceStrip(
      image: img,
      x0: 15,
      y0: 25,
      x1: 1150,
      y1: 110,
      frameCount: 8,
      stepTime: 0.14,
    );

    // Tortoise Walk (8 frames)
    _tortoiseAnimations[CharacterAnimationState.walk] = _sliceStrip(
      image: img,
      x0: 15,
      y0: 135,
      x1: 1150,
      y1: 220,
      frameCount: 8,
      stepTime: 0.12,
    );

    // Tortoise Run (8 frames)
    final runAnim = _sliceStrip(
      image: img,
      x0: 15,
      y0: 250,
      x1: 1150,
      y1: 335,
      frameCount: 8,
      stepTime: 0.09,
    );
    _tortoiseAnimations[CharacterAnimationState.run] = runAnim;

    // Tortoise Jump (uses dynamic run airborne frame)
    _tortoiseAnimations[CharacterAnimationState.jump] = SpriteAnimation.spriteList(
      [runAnim.frames[2].sprite, runAnim.frames[3].sprite],
      stepTime: 0.25,
      loop: true,
    );

    // Tortoise Sleep (6 frames)
    _tortoiseAnimations[CharacterAnimationState.sleep] = _sliceStrip(
      image: img,
      x0: 15,
      y0: 475,
      x1: 580,
      y1: 555,
      frameCount: 6,
      stepTime: 0.25,
    );

    // Tortoise Climb / Hill Walk (6 frames)
    _tortoiseAnimations[CharacterAnimationState.collect] = _sliceStrip(
      image: img,
      x0: 530,
      y0: 585,
      x1: 1150,
      y1: 665,
      frameCount: 6,
      stepTime: 0.12,
    );

    // Tortoise Win (5 frames with victory ribbon)
    final winRanges = [(560.0, 675.0), (675.0, 780.0), (780.0, 885.0), (885.0, 990.0), (990.0, 1135.0)];
    final winSprites = <Sprite>[];
    for (final r in winRanges) {
      winSprites.add(Sprite(
        img,
        srcPosition: Vector2(r.$1, 675),
        srcSize: Vector2(r.$2 - r.$1, 90),
      ));
    }
    _tortoiseAnimations[CharacterAnimationState.win] = SpriteAnimation.spriteList(
      winSprites,
      stepTime: 0.14,
      loop: true,
    );

    // Tortoise Hit (Knockback flash frame from walk)
    _tortoiseAnimations[CharacterAnimationState.hit] = SpriteAnimation.spriteList(
      [runAnim.frames[0].sprite],
      stepTime: 0.3,
      loop: false,
    );

    _tortoiseAnimations[CharacterAnimationState.lose] = _tortoiseAnimations[CharacterAnimationState.idle]!;
  }

  void _buildHareAnimations() {
    if (_rabbitSheet == null) return;
    final img = _rabbitSheet!;

    // Hare Idle (6 frames)
    _hareAnimations[CharacterAnimationState.idle] = _sliceStrip(
      image: img,
      x0: 5,
      y0: 20,
      x1: 480,
      y1: 120,
      frameCount: 6,
      stepTime: 0.15,
    );

    // Hare Run (8 frames)
    final runAnim = _sliceStrip(
      image: img,
      x0: 5,
      y0: 156,
      x1: 480,
      y1: 240,
      frameCount: 8,
      stepTime: 0.08,
    );
    _hareAnimations[CharacterAnimationState.run] = runAnim;

    // Hare Walk (8 frames)
    _hareAnimations[CharacterAnimationState.walk] = _sliceStrip(
      image: img,
      x0: 505,
      y0: 20,
      x1: 1010,
      y1: 115,
      frameCount: 8,
      stepTime: 0.12,
    );

    // Hare Happy (6 frames)
    _hareAnimations[CharacterAnimationState.collect] = _sliceStrip(
      image: img,
      x0: 5,
      y0: 270,
      x1: 480,
      y1: 360,
      frameCount: 6,
      stepTime: 0.12,
    );

    // Hare Sleep (6 frames)
    _hareAnimations[CharacterAnimationState.sleep] = _sliceStrip(
      image: img,
      x0: 0,
      y0: 390,
      x1: 480,
      y1: 455,
      frameCount: 6,
      stepTime: 0.28,
    );

    // Hare Surprised (5 frames)
    _hareAnimations[CharacterAnimationState.surprised] = _sliceStrip(
      image: img,
      x0: 520,
      y0: 380,
      x1: 1000,
      y1: 460,
      frameCount: 5,
      stepTime: 0.14,
    );

    // Hare Cheer (6 frames)
    _hareAnimations[CharacterAnimationState.cheer] = _sliceStrip(
      image: img,
      x0: 505,
      y0: 480,
      x1: 1010,
      y1: 568,
      frameCount: 6,
      stepTime: 0.12,
    );

    _hareAnimations[CharacterAnimationState.win] = _hareAnimations[CharacterAnimationState.cheer]!;
    _hareAnimations[CharacterAnimationState.lose] = _hareAnimations[CharacterAnimationState.surprised]!;
    _hareAnimations[CharacterAnimationState.hit] = _hareAnimations[CharacterAnimationState.surprised]!;
    _hareAnimations[CharacterAnimationState.jump] = runAnim;
  }

  SpriteAnimation _sliceStrip({
    required ui.Image image,
    required double x0,
    required double y0,
    required double x1,
    required double y1,
    required int frameCount,
    required double stepTime,
    bool loop = true,
  }) {
    final totalW = x1 - x0;
    final totalH = y1 - y0;
    final frameW = totalW / frameCount;

    final sprites = <Sprite>[];
    for (int i = 0; i < frameCount; i++) {
      sprites.add(Sprite(
        image,
        srcPosition: Vector2(x0 + (i * frameW), y0),
        srcSize: Vector2(frameW, totalH),
      ));
    }

    return SpriteAnimation.spriteList(
      sprites,
      stepTime: stepTime,
      loop: loop,
    );
  }

  SpriteAnimation? getTortoiseAnimation(CharacterAnimationState state) =>
      _tortoiseAnimations[state];

  SpriteAnimation? getHareAnimation(CharacterAnimationState state) =>
      _hareAnimations[state];
}
