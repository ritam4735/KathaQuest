import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../../core/sprite_sheet_manager.dart';
import '../../core/katha_flame_game.dart';

/// The playable Tortoise (Timo) component with physics, animations, hitboxes,
/// jump mechanics, and damage recovery.
class TortoisePlayer extends PositionComponent
    with CollisionCallbacks, HasGameReference<KathaFlameGame> {
  final SpriteSheetManager spriteSheets = SpriteSheetManager();

  CharacterAnimationState _animState = CharacterAnimationState.walk;
  SpriteAnimationComponent? _animComponent;

  Vector2 velocity = Vector2.zero();
  double speed = 250.0;
  bool isGrounded = true;
  double gravity = 700.0;
  double jumpVelocity = -360.0;
  double groundY = 0.0;

  bool isFacingRight = true;
  bool isInvulnerable = false;
  double invulnerabilityTimer = 0.0;
  static const double invulnerabilityDuration = 1.2;

  final Vector2 targetSize;

  TortoisePlayer({
    required Vector2 position,
    Vector2? size,
  })  : targetSize = size ?? Vector2(72, 72),
        super(
          position: position,
          size: size ?? Vector2(72, 72),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Setup hitbox (slightly inset for friendly, forgiving collisions for kids)
    final hitboxSize = Vector2(size.x * 0.68, size.y * 0.68);
    add(
      RectangleHitbox(
        size: hitboxSize,
        position: (size - hitboxSize) / 2,
      ),
    );

    groundY = position.y;
    _updateAnimation();
  }

  void setAnimationState(CharacterAnimationState state) {
    if (_animState == state) return;
    _animState = state;
    _updateAnimation();
  }

  void _updateAnimation() {
    _animComponent?.removeFromParent();

    final anim = spriteSheets.getTortoiseAnimation(_animState) ??
        spriteSheets.getTortoiseAnimation(CharacterAnimationState.idle);

    if (anim != null) {
      _animComponent = SpriteAnimationComponent(
        animation: anim,
        size: size,
        anchor: Anchor.center,
        position: size / 2,
      );
      add(_animComponent!);
    }

    _applyOrientation();
  }

  void setFacing(bool facingRight) {
    if (isFacingRight != facingRight) {
      isFacingRight = facingRight;
      _applyOrientation();
    }
  }

  void _applyOrientation() {
    // Master spritesheet turtle naturally faces LEFT.
    // When moving forward/facing right, scale.x must be negative to flip it horizontally!
    if (_animComponent != null) {
      _animComponent!.scale = Vector2(isFacingRight ? -1.0 : 1.0, 1.0);
    }
  }

  void jump() {
    if (isGrounded) {
      velocity.y = jumpVelocity;
      isGrounded = false;
      setAnimationState(CharacterAnimationState.jump);
    }
  }

  void triggerHit() {
    if (isInvulnerable) return;
    isInvulnerable = true;
    invulnerabilityTimer = invulnerabilityDuration;
    setAnimationState(CharacterAnimationState.hit);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Invulnerability blinking & recovery
    if (isInvulnerable) {
      invulnerabilityTimer -= dt;
      final blink = (invulnerabilityTimer * 12).toInt() % 2 == 0;
      _animComponent?.paint.color = blink
          ? const Color(0xFFFF5252).withOpacity(0.5)
          : const Color(0xFFFFFFFF);

      if (invulnerabilityTimer <= 0) {
        isInvulnerable = false;
        _animComponent?.paint.color = const Color(0xFFFFFFFF);
        if (isGrounded) setAnimationState(CharacterAnimationState.walk);
      }
    }

    // Apply gravity when airborne
    if (!isGrounded) {
      velocity.y += gravity * dt;
      position.y += velocity.y * dt;

      if (position.y >= groundY) {
        position.y = groundY;
        velocity.y = 0;
        isGrounded = true;
        if (_animState == CharacterAnimationState.jump) {
          setAnimationState(CharacterAnimationState.run);
        }
      }
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    game.handleCollision(other);
  }
}
