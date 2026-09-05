import 'package:flame/components.dart';
import '../../core/sprite_sheet_manager.dart';

/// The Hare competitor component used in races, sprints, and resting scenes.
class HareEnemy extends PositionComponent {
  final SpriteSheetManager spriteSheets = SpriteSheetManager();

  CharacterAnimationState _animState = CharacterAnimationState.run;
  SpriteAnimationComponent? _animComponent;
  bool isFacingRight = true;

  double speed = 260.0;
  Vector2 velocity = Vector2.zero();

  HareEnemy({
    required Vector2 position,
    Vector2? size,
    CharacterAnimationState initialAnimation = CharacterAnimationState.run,
    this.isFacingRight = true,
  })  : _animState = initialAnimation,
        super(
          position: position,
          size: size ?? Vector2(74, 74),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updateAnimation();
  }

  void setAnimationState(CharacterAnimationState state) {
    if (_animState == state) return;
    _animState = state;
    _updateAnimation();
  }

  void setFacing(bool facingRight) {
    if (isFacingRight != facingRight) {
      isFacingRight = facingRight;
      _applyOrientation();
    }
  }

  void _updateAnimation() {
    _animComponent?.removeFromParent();

    final anim = spriteSheets.getHareAnimation(_animState) ??
        spriteSheets.getHareAnimation(CharacterAnimationState.idle);

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

  void _applyOrientation() {
    // Master rabbit spritesheet naturally faces LEFT.
    // When facing/running right forward, flip scale.x to negative!
    if (_animComponent != null) {
      _animComponent!.scale = Vector2(isFacingRight ? -1.0 : 1.0, 1.0);
    }
  }
}
