import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../components/collectibles/game_collectible.dart';
import '../components/enemy/hare_enemy.dart';
import '../components/obstacles/game_obstacle.dart';
import '../components/player/tortoise_player.dart';
import '../components/world/scrolling_background.dart';
import '../core/katha_flame_game.dart';
import '../core/sprite_sheet_manager.dart';

/// Mini-Game 2: Steady Pace Challenge ("Steady Runner")
/// Side-scrolling runner where Timo jumps over track hurdles and maintains steady momentum.
class SteadyRunnerGame extends KathaFlameGame with TapCallbacks {
  late final TortoisePlayer player;
  HareEnemy? hare;
  ScrollingBackground? background;

  final Random _random = Random();
  double _spawnTimer = 0.0;
  double _spawnInterval = 1.6;
  double _scrollSpeed = 190.0;
  double _groundY = 0.0;

  SteadyRunnerGame({
    required super.targetScore,
    required super.durationSeconds,
    required super.onGameCompleted,
    super.onExitRequested,
  }) : super(
          gameId: 'mg_race_begins',
          title: 'Steady Pace Challenge',
          instructions: 'Tap to jump over hurdles 🚧 and rocks 🪨! Collect energy clovers 🍀 and maintain a steady pace!',
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _groundY = size.y * 0.72;

    // 1. Scenic Track Background
    background = ScrollingBackground(
      imagePath: 'assets/images/backgrounds_for_hare_tortoise_story/3.png',
      size: size,
      scrollSpeed: Vector2(30, 0),
    );
    add(background!);

    // 2. Hare Sprinting Ahead in Background Lane
    hare = HareEnemy(
      position: Vector2(size.x * 0.75, _groundY - 60),
      size: Vector2(64, 64),
      initialAnimation: CharacterAnimationState.run,
      isFacingRight: true,
    );
    add(hare!);

    // 3. Tortoise Player in Foreground Lane
    player = TortoisePlayer(
      position: Vector2(size.x * 0.25, _groundY),
      size: Vector2(74, 74),
    );
    player.groundY = _groundY;
    player.setFacing(true); // Facing right forward
    player.setAnimationState(CharacterAnimationState.run);
    add(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!stateMachine.isPlaying) return;

    // Difficulty curve: speed ramps naturally as score approaches target
    final progress = (targetScore > 0) ? (scoreManager.score / targetScore).clamp(0.0, 1.2) : 0.0;
    _scrollSpeed = 190.0 + (progress * 80.0);
    _spawnInterval = (1.65 - (progress * 0.65)).clamp(0.95, 1.7);
    background?.scrollSpeed = Vector2(25.0 + (progress * 25.0), 0);

    // Subtle bobbing of the distant hare sprinting ahead
    if (hare != null) {
      hare!.position.y = (_groundY - 60) + (sin(remainingTime * 6) * 3);
    }

    // Spawning hurdles, rocks, and collectibles from the right
    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0.0;
      _spawnTrackItem(progress);
    }

    // High-frequency collision & jump clearance sweep
    final playerCenter = player.position;

    for (final child in children) {
      if (child is GameObstacle && !child.hasCollided) {
        final dx = (child.position.x - playerCenter.x).abs();

        // Check horizontal overlap
        if (dx < 38.0) {
          // Check vertical clearance: player bottom vs obstacle top
          final isCleared = (player.position.y + 22.0) < (child.position.y - 14.0);
          if (!isCleared) {
            handleCollision(child);
          }
        }
      } else if (child is GameCollectible && !child.isCollected) {
        final dist = (child.position - playerCenter).length;
        if (dist < 42.0) {
          handleCollision(child);
        }
      }
    }

    // Clean up passed items
    children.whereType<GameObstacle>().forEach((obs) {
      if (obs.position.x < -60) obs.removeFromParent();
    });

    children.whereType<GameCollectible>().forEach((col) {
      if (col.position.x < -60) col.removeFromParent();
    });
  }

  void _spawnTrackItem(double progress) {
    final roll = _random.nextDouble();
    final spawnX = size.x + 40.0;

    // Shift obstacle ratio as player advances
    final obstacleChance = 0.42 + (progress * 0.18); // 42% -> 60%

    if (roll < obstacleChance) {
      final isRock = _random.nextDouble() < 0.45;
      if (isRock) {
        // Low rock obstacle
        add(
          GameObstacle(
            type: ObstacleType.rock,
            position: Vector2(spawnX, _groundY + 8),
            velocity: Vector2(-_scrollSpeed, 0),
            size: Vector2(42, 42),
            damage: 1,
          ),
        );
      } else {
        // Track hurdle to jump over
        add(
          GameObstacle(
            type: ObstacleType.hurdle,
            position: Vector2(spawnX, _groundY + 4),
            velocity: Vector2(-_scrollSpeed, 0),
            size: Vector2(46, 46),
            damage: 1,
          ),
        );
      }
    } else {
      final isHighStar = _random.nextDouble() < 0.40;
      if (isHighStar) {
        // High golden star requiring mid-air jump to reach!
        add(
          GameCollectible(
            type: CollectibleType.star,
            position: Vector2(spawnX, _groundY - 65),
            velocity: Vector2(-_scrollSpeed, 0),
            points: 25,
          ),
        );
      } else {
        // Running height energy clover
        add(
          GameCollectible(
            type: CollectibleType.clover,
            position: Vector2(spawnX, _groundY - 12),
            velocity: Vector2(-_scrollSpeed, 0),
            points: 10,
          ),
        );
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!stateMachine.isPlaying) return;
    if (player.isGrounded) {
      player.jump();
      audio.playFootstep();
    }
  }

  @override
  void resetWorldComponents() {
    children.whereType<GameObstacle>().forEach((e) => e.removeFromParent());
    children.whereType<GameCollectible>().forEach((e) => e.removeFromParent());

    _spawnTimer = 0.0;
    _scrollSpeed = 190.0;
    player.position = Vector2(size.x * 0.25, _groundY);
    player.velocity = Vector2.zero();
    player.isGrounded = true;
    player.isInvulnerable = false;
    player.setFacing(true);
    player.setAnimationState(CharacterAnimationState.run);
  }

  @override
  void handleCollision(PositionComponent other) {
    if (!stateMachine.isPlaying) return;

    if (other is GameObstacle && !other.hasCollided) {
      if (player.isInvulnerable) return;

      other.hasCollided = true;
      other.removeFromParent();

      player.triggerHit();
      scoreManager.loseLife(1);
      audio.playWrong();

      if (scoreManager.isDead) {
        stateMachine.triggerGameOver('Timo stumbled on the track hurdles! Jump with good timing next time!');
      }
    } else if (other is GameCollectible && !other.isCollected) {
      other.isCollected = true;
      other.removeFromParent();

      scoreManager.addPoints(other.points, isItem: true);
      audio.playStar();

      if (scoreManager.score >= targetScore) {
        stateMachine.triggerCompletion(stars: scoreManager.calculateStars());
      }
    }
  }
}
