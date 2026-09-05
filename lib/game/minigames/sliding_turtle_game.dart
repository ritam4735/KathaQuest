import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../components/collectibles/game_collectible.dart';
import '../components/obstacles/game_obstacle.dart';
import '../components/player/tortoise_player.dart';
import '../components/world/scrolling_background.dart';
import '../core/katha_flame_game.dart';
import '../core/sprite_sheet_manager.dart';

/// Mini-Game 1: Forest Walk ("Sliding Turtle")
/// Real playable top-down obstacle dodging and clover/star collection game.
class SlidingTurtleGame extends KathaFlameGame with DragCallbacks {
  late final TortoisePlayer player;
  ScrollingBackground? background;

  final Random _random = Random();
  double _spawnTimer = 0.0;
  double _spawnInterval = 1.1; // Decreases with score
  final double _baseScrollSpeed = 160.0;

  SlidingTurtleGame({
    required super.targetScore,
    required super.durationSeconds,
    required super.onGameCompleted,
    super.onExitRequested,
  }) : super(
          gameId: 'mg_forest_walk',
          title: 'Forest Trail Warm-Up',
          instructions: 'Slide Timo left and right! Collect clovers 🍀 and stars ⭐ while dodging thorny logs 🪵 and mud 🟫!',
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Scenic Forest Background
    background = ScrollingBackground(
      imagePath: 'assets/images/backgrounds_for_hare_tortoise_story/2.png',
      size: size,
      scrollSpeed: Vector2(0, 40),
    );
    add(background!);

    // 2. Playable Tortoise Player Component
    player = TortoisePlayer(
      position: Vector2(size.x / 2, size.y * 0.78),
      size: Vector2(76, 76),
    );
    add(player);
  }

  double _speedModifier = 1.0;
  double _slowdownTimer = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    if (!stateMachine.isPlaying) return;

    // Handle mud slowdown recovery
    if (_slowdownTimer > 0) {
      _slowdownTimer -= dt;
      if (_slowdownTimer <= 0) {
        _speedModifier = 1.0;
      }
    }

    // Natural difficulty curve: speed and obstacle density scale with score progression
    final progress = (targetScore > 0) ? (scoreManager.score / targetScore).clamp(0.0, 1.2) : 0.0;
    final currentItemSpeed = (_baseScrollSpeed + (progress * 90.0)) * _speedModifier;
    _spawnInterval = (1.25 - (progress * 0.55)).clamp(0.65, 1.3);

    background?.scrollSpeed = Vector2(0, (40.0 + (progress * 30.0)) * _speedModifier);

    // Spawn obstacles and collectibles
    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0.0;
      _spawnEntity(progress, currentItemSpeed);
    }

    // High-frequency collision detection sweep against player hitbox
    final playerCenter = player.position;
    final playerRadius = player.size.x * 0.36;

    for (final child in children) {
      if (child is GameObstacle && !child.hasCollided) {
        final dist = (child.position - playerCenter).length;
        if (dist < playerRadius + (child.size.x * 0.38)) {
          handleCollision(child);
        }
      } else if (child is GameCollectible && !child.isCollected) {
        final dist = (child.position - playerCenter).length;
        if (dist < playerRadius + (child.size.x * 0.40)) {
          handleCollision(child);
        }
      }
    }

    // Clean up out-of-bounds components
    children.whereType<GameObstacle>().forEach((obs) {
      if (obs.position.y > size.y + 60) {
        obs.removeFromParent();
      }
    });

    children.whereType<GameCollectible>().forEach((col) {
      if (col.position.y > size.y + 60) {
        col.removeFromParent();
      }
    });
  }

  void _spawnEntity(double progress, double itemSpeed) {
    final roll = _random.nextDouble();
    final spawnX = 42.0 + _random.nextDouble() * (size.x - 84.0);
    const spawnY = -40.0;

    // Natural probability shift: starts with high collectible ratio, shifts gradually towards obstacles
    final obstacleChance = 0.32 + (progress * 0.26); // 32% -> 58%

    if (roll > obstacleChance) {
      // Collectibles
      final isStar = _random.nextDouble() < 0.35;
      if (isStar) {
        add(
          GameCollectible(
            type: CollectibleType.star,
            position: Vector2(spawnX, spawnY),
            velocity: Vector2(0, itemSpeed),
            points: 20,
          ),
        );
      } else {
        add(
          GameCollectible(
            type: CollectibleType.clover,
            position: Vector2(spawnX, spawnY),
            velocity: Vector2(0, itemSpeed),
            points: 10,
          ),
        );
      }
    } else {
      // Obstacles
      final isMud = _random.nextDouble() < 0.45;
      if (isMud) {
        add(
          GameObstacle(
            type: ObstacleType.mud,
            position: Vector2(spawnX, spawnY),
            velocity: Vector2(0, itemSpeed),
            causesSlowdown: true,
          ),
        );
      } else {
        add(
          GameObstacle(
            type: ObstacleType.bramble,
            position: Vector2(spawnX, spawnY),
            velocity: Vector2(0, itemSpeed),
            damage: 1,
          ),
        );
      }
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!stateMachine.isPlaying) return;

    // Smooth horizontal steering influenced by mud slowdown
    final deltaX = event.localDelta.x * _speedModifier;
    player.position.x = (player.position.x + deltaX).clamp(42.0, size.x - 42.0);

    // Face movement direction
    if (deltaX > 1.0) {
      player.setFacing(true);
      player.setAnimationState(CharacterAnimationState.run);
    } else if (deltaX < -1.0) {
      player.setFacing(false);
      player.setAnimationState(CharacterAnimationState.run);
    }
  }

  @override
  void resetWorldComponents() {
    // Remove active obstacles and collectibles
    children.whereType<GameObstacle>().forEach((e) => e.removeFromParent());
    children.whereType<GameCollectible>().forEach((e) => e.removeFromParent());

    // Reset player position and state
    final safeSize = hasLayout ? size : Vector2(400, 800);
    player.position = Vector2(safeSize.x / 2, safeSize.y * 0.78);
    player.isInvulnerable = false;
    player.setFacing(true);
    player.setAnimationState(CharacterAnimationState.walk);

    _speedModifier = 1.0;
    _slowdownTimer = 0.0;
    _spawnTimer = 0.0;
    background?.scrollSpeed = Vector2(0, 40);
  }

  @override
  void handleCollision(PositionComponent other) {
    if (!stateMachine.isPlaying) return;

    if (other is GameObstacle && !other.hasCollided) {
      if (other.type == ObstacleType.bramble) {
        // If player is currently invulnerable (flashing), ignore damage
        if (player.isInvulnerable) return;

        other.hasCollided = true;
        other.removeFromParent();

        player.triggerHit();
        scoreManager.loseLife(1);
        audio.playWrong();

        if (scoreManager.isDead) {
          stateMachine.triggerGameOver('Timo lost all energy! Dodge the thorny brambles!');
        }
      } else if (other.type == ObstacleType.mud) {
        other.hasCollided = true;
        other.removeFromParent();

        // Mud slows down steering and breaks combo
        _speedModifier = 0.55;
        _slowdownTimer = 1.2;
        scoreManager.resetCombo();
        audio.playTap();
      }
    } else if (other is GameCollectible && !other.isCollected) {
      other.isCollected = true;
      other.removeFromParent();

      scoreManager.addPoints(other.points, isItem: true);
      if (other.type == CollectibleType.star) {
        audio.playStar();
      } else {
        audio.playFootstep();
      }

      if (scoreManager.score >= targetScore) {
        stateMachine.triggerCompletion(stars: scoreManager.calculateStars());
      }
    }
  }
}
