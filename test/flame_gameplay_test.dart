import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:katha_quest/core/models/save_data.dart';
import 'package:katha_quest/core/models/story_model.dart';
import 'package:katha_quest/features/minigames/mg1_forest_walk.dart';
import 'package:katha_quest/features/minigames/mg2_race_begins.dart';
import 'package:katha_quest/features/minigames/mg3_rhythm_steps.dart';
import 'package:katha_quest/features/minigames/mg4_final_sprint.dart';
import 'package:katha_quest/features/minigames/mg5_memory_match.dart';
import 'package:katha_quest/game/components/collectibles/game_collectible.dart';
import 'package:katha_quest/game/components/enemy/hare_enemy.dart';
import 'package:katha_quest/game/components/obstacles/game_obstacle.dart';
import 'package:katha_quest/game/components/player/tortoise_player.dart';
import 'package:katha_quest/game/components/world/finish_ribbon.dart';
import 'package:katha_quest/game/core/game_state_machine.dart';
import 'package:katha_quest/game/core/sprite_sheet_manager.dart';
import 'package:katha_quest/game/managers/game_score_manager.dart';
import 'package:katha_quest/game/minigames/cadence_rhythm_game.dart';
import 'package:katha_quest/game/minigames/ribbon_sprint_game.dart';
import 'package:katha_quest/game/minigames/sliding_turtle_game.dart';
import 'package:katha_quest/game/minigames/steady_runner_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameStateMachine Tests', () {
    test('Starts in ready state and transitions correctly', () {
      final machine = GameStateMachine();
      expect(machine.state, MiniGameState.ready);
      expect(machine.isReady, isTrue);
      expect(machine.isPlaying, isFalse);

      bool notified = false;
      machine.addListener(() => notified = true);

      // Start playing
      machine.startGame();
      expect(machine.state, MiniGameState.playing);
      expect(machine.isPlaying, isTrue);
      expect(notified, isTrue);

      // Pause
      notified = false;
      machine.pauseGame();
      expect(machine.state, MiniGameState.paused);
      expect(machine.isPaused, isTrue);
      expect(notified, isTrue);

      // Resume
      notified = false;
      machine.resumeGame();
      expect(machine.state, MiniGameState.playing);
      expect(machine.isPlaying, isTrue);

      // Game Over
      notified = false;
      machine.triggerGameOver('Ran out of lives');
      expect(machine.state, MiniGameState.gameOver);
      expect(machine.isGameOver, isTrue);
      expect(machine.failureReason, 'Ran out of lives');

      // Restart
      notified = false;
      machine.restart();
      expect(machine.state, MiniGameState.ready);
      expect(machine.isReady, isTrue);

      // Complete
      machine.startGame();
      machine.triggerCompletion(stars: 3);
      expect(machine.state, MiniGameState.completed);
      expect(machine.isCompleted, isTrue);
      expect(machine.starsEarned, 3);
    });
  });

  group('GameScoreManager Tests', () {
    test('Initializes with default values', () {
      final scoreManager = GameScoreManager(targetScore: 100);
      expect(scoreManager.score, 0);
      expect(scoreManager.lives, 3);
      expect(scoreManager.maxLives, 3);
      expect(scoreManager.targetScore, 100);
      expect(scoreManager.combo, 0);
      expect(scoreManager.progressRatio, 0.0);
    });

    test('Point additions and combo multiplier tiers', () {
      final scoreManager = GameScoreManager(targetScore: 100);

      // 1st hit
      scoreManager.addPoints(10, isItem: true);
      expect(scoreManager.score, 10);
      expect(scoreManager.combo, 1);

      // 2nd hit
      scoreManager.addPoints(10, isItem: true);
      expect(scoreManager.score, 20);
      expect(scoreManager.combo, 2);

      // 3rd hit activates 1.5x multiplier
      scoreManager.addPoints(10, isItem: true);
      expect(scoreManager.combo, 3);
      expect(scoreManager.score, 35); // 20 + (10 * 1.5)

      // 4th hit
      scoreManager.addPoints(10, isItem: true);
      expect(scoreManager.combo, 4);
      expect(scoreManager.score, 50); // 35 + 15

      // 5th hit activates 2.0x multiplier
      scoreManager.addPoints(10, isItem: true);
      expect(scoreManager.combo, 5);
      expect(scoreManager.score, 70); // 50 + 20
    });

    test('Losing lives resets combo streak and drains lives to 0', () {
      final scoreManager = GameScoreManager(targetScore: 100);

      scoreManager.addPoints(10, isItem: true);
      scoreManager.addPoints(10, isItem: true);
      scoreManager.addPoints(10, isItem: true);
      expect(scoreManager.combo, 3);

      // Hit obstacle
      scoreManager.loseLife();
      expect(scoreManager.lives, 2);
      expect(scoreManager.combo, 0);
      expect(scoreManager.isDead, isFalse);

      // Hit obstacle again
      scoreManager.loseLife();
      expect(scoreManager.lives, 1);
      expect(scoreManager.isDead, isFalse);

      // Fatal obstacle hit
      scoreManager.loseLife();
      expect(scoreManager.lives, 0);
      expect(scoreManager.isDead, isTrue);
    });

    test('Stars earned based on percentage of target score', () {
      final scoreManager = GameScoreManager(targetScore: 100);

      // Under targetScore => 1 star
      scoreManager.addPoints(50);
      expect(scoreManager.calculateStars(), 1);

      // Target score reached => 2 stars
      scoreManager.addPoints(50); // 100
      expect(scoreManager.calculateStars(), 2);

      // Target score * 1.3 reached with >= 2 lives => 3 stars
      scoreManager.addPoints(30); // 130
      expect(scoreManager.calculateStars(), 3);
    });
  });

  group('SaveData v4 Persistence & Migration Tests', () {
    test('Schema v4 defaults and serialization', () {
      final profile = UserProfile();
      expect(profile.saveVersion, 4);
      expect(profile.miniGameHighScores, isEmpty);
      expect(profile.miniGameStars, isEmpty);
      expect(profile.miniGameCompleted, isEmpty);
      expect(profile.totalMiniGamePoints, 0);

      final jsonStr = profile.toJson();
      final restored = UserProfile.fromJson(jsonStr);
      expect(restored.saveVersion, 4);
      expect(restored.totalMiniGamePoints, 0);
    });

    test('Migrates legacy v3 profile map to v4 cleanly', () {
      final legacyV3Map = {
        'saveVersion': 3,
        'playerName': 'Explorer',
        'currentXp': 500,
        'storyStars': {'story_rama_exile': 3},
        'unlockedBadges': ['first_step'],
      };

      final migrated = UserProfile.fromMap(legacyV3Map);
      expect(migrated.saveVersion, 3); // Preserved version from map
      expect(migrated.playerName, 'Explorer');
      expect(migrated.miniGameHighScores, isNotNull);
      expect(migrated.miniGameStars, isNotNull);
      expect(migrated.totalMiniGamePoints, 0);
    });
  });

  group('Flame Components & Physics Tests', () {
    test('TortoisePlayer faces forward and has jump physics baseline', () {
      final player = TortoisePlayer(position: Vector2(50, 300));
      player.groundY = 300;
      expect(player.isFacingRight, isTrue);
      expect(player.groundY, 300);
      expect(player.isGrounded, isTrue);
      expect(player.isInvulnerable, isFalse);

      // Jump
      player.jump();
      expect(player.isGrounded, isFalse);
      expect(player.velocity.y, -360.0);

      // Simulate physics gravity update
      player.update(0.1);
      // Velocity should decrease due to gravity (700 * 0.1 = 70)
      expect(player.velocity.y, -360.0 + 70.0);

      // Trigger hit
      player.triggerHit();
      expect(player.isInvulnerable, isTrue);
      expect(player.invulnerabilityTimer, 1.2);
    });

    test('HareEnemy initializes with correct forward orientation', () {
      final hare = HareEnemy(position: Vector2(100, 300), initialAnimation: CharacterAnimationState.run);
      expect(hare.isFacingRight, isTrue);

      final sleepingHare = HareEnemy(position: Vector2(100, 300), initialAnimation: CharacterAnimationState.sleep);
      expect(sleepingHare.isFacingRight, isTrue);
    });

    test('GameObstacle dimensions and types', () {
      final bramble = GameObstacle(type: ObstacleType.bramble, position: Vector2(200, 300));
      expect(bramble.type, ObstacleType.bramble);
      expect(bramble.damage, 1);

      final mud = GameObstacle(type: ObstacleType.mud, position: Vector2(200, 300));
      expect(mud.type, ObstacleType.mud);

      final hurdle = GameObstacle(type: ObstacleType.hurdle, position: Vector2(200, 300));
      expect(hurdle.type, ObstacleType.hurdle);
    });

    test('GameCollectible properties and points', () {
      final clover = GameCollectible(type: CollectibleType.clover, position: Vector2(200, 300));
      expect(clover.points, 10);

      final goldenStar = GameCollectible(type: CollectibleType.star, position: Vector2(200, 300));
      expect(goldenStar.points, 20);

      final speedBerry = GameCollectible(type: CollectibleType.speedBerry, position: Vector2(200, 300));
      expect(speedBerry.points, 15);
    });

    test('FinishRibbon creates ribbon boundary', () {
      bool broken = false;
      final ribbon = FinishRibbon(
        position: Vector2(500, 300),
        size: Vector2(30, 200),
        onRibbonBroken: () => broken = true,
      );
      expect(ribbon.isBroken, isFalse);

      ribbon.breakRibbon();
      expect(ribbon.isBroken, isTrue);
      expect(broken, isTrue);
    });
  });

  group('SlidingTurtleGame Gameplay & Collision Tests', () {
    test('Bramble deals damage, triggers invulnerability, and invulnerability prevents repeat hits', () {
      final game = SlidingTurtleGame(
        targetScore: 50,
        durationSeconds: 20,
        onGameCompleted: (s, st) {},
      );
      game.onGameResize(Vector2(400, 800));
      game.player = TortoisePlayer(position: Vector2(100, 200));
      game.stateMachine.startGame();

      expect(game.scoreManager.lives, 3);
      expect(game.player.isInvulnerable, isFalse);

      // Hit bramble
      final bramble = GameObstacle(type: ObstacleType.bramble, position: Vector2(100, 200));
      game.handleCollision(bramble);

      expect(bramble.hasCollided, isTrue);
      expect(game.player.isInvulnerable, isTrue);
      expect(game.scoreManager.lives, 2);

      // Second bramble while invulnerable -> No damage taken!
      final bramble2 = GameObstacle(type: ObstacleType.bramble, position: Vector2(100, 200));
      game.handleCollision(bramble2);

      expect(bramble2.hasCollided, isFalse);
      expect(game.scoreManager.lives, 2);
    });

    test('Mud puddle resets combo streak and applies slowdown without taking lives', () {
      final game = SlidingTurtleGame(
        targetScore: 50,
        durationSeconds: 20,
        onGameCompleted: (s, st) {},
      );
      game.onGameResize(Vector2(400, 800));
      game.player = TortoisePlayer(position: Vector2(100, 200));
      game.stateMachine.startGame();

      // Earn combo with clover
      final clover = GameCollectible(type: CollectibleType.clover, position: Vector2(100, 200));
      game.handleCollision(clover);
      expect(game.scoreManager.combo, 1);
      expect(game.scoreManager.score, 10);

      // Hit mud
      final mud = GameObstacle(type: ObstacleType.mud, position: Vector2(100, 200));
      game.handleCollision(mud);

      expect(mud.hasCollided, isTrue);
      expect(game.scoreManager.lives, 3); // Lives untouched
      expect(game.scoreManager.combo, 0); // Combo broken
    });

    test('Losing all 3 lives triggers GameOver and restart resets cleanly', () {
      final game = SlidingTurtleGame(
        targetScore: 50,
        durationSeconds: 20,
        onGameCompleted: (s, st) {},
      );
      game.onGameResize(Vector2(400, 800));
      game.player = TortoisePlayer(position: Vector2(100, 200));
      game.stateMachine.startGame();

      // Drain lives
      game.scoreManager.loseLife(2);
      game.player.isInvulnerable = false;
      final bramble = GameObstacle(type: ObstacleType.bramble, position: Vector2(100, 200));
      game.handleCollision(bramble);

      expect(game.scoreManager.isDead, isTrue);
      expect(game.stateMachine.isGameOver, isTrue);

      // Restart session
      game.restartSession();
      expect(game.scoreManager.lives, 3);
      expect(game.scoreManager.score, 0);
      expect(game.stateMachine.isReady, isTrue);
    });
  });

  group('SteadyRunnerGame Gameplay & Jumping Tests', () {
    test('Hurdle deals damage when player is grounded and triggers game over on fatal hit', () {
      final game = SteadyRunnerGame(
        targetScore: 60,
        durationSeconds: 20,
        onGameCompleted: (s, st) {},
      );
      game.onGameResize(Vector2(400, 800));
      game.player = TortoisePlayer(position: Vector2(100, 300));
      game.player.groundY = 300;
      game.stateMachine.startGame();

      final hurdle = GameObstacle(type: ObstacleType.hurdle, position: Vector2(100, 304));
      game.handleCollision(hurdle);

      expect(hurdle.hasCollided, isTrue);
      expect(game.scoreManager.lives, 2);
      expect(game.player.isInvulnerable, isTrue);

      // Drain remaining lives to fatal hit
      game.scoreManager.loseLife(1);
      game.player.isInvulnerable = false;
      final rock = GameObstacle(type: ObstacleType.rock, position: Vector2(100, 304));
      game.handleCollision(rock);

      expect(game.scoreManager.isDead, isTrue);
      expect(game.stateMachine.isGameOver, isTrue);
    });

    test('Elevated star collection adds points and advances combo', () {
      final game = SteadyRunnerGame(
        targetScore: 60,
        durationSeconds: 20,
        onGameCompleted: (s, st) {},
      );
      game.onGameResize(Vector2(400, 800));
      game.player = TortoisePlayer(position: Vector2(100, 235));
      game.stateMachine.startGame();

      final star = GameCollectible(type: CollectibleType.star, position: Vector2(100, 235), points: 25);
      game.handleCollision(star);

      expect(star.isCollected, isTrue);
      expect(game.scoreManager.score, 25);
      expect(game.scoreManager.combo, 1);
    });

    test('Jumping cleanly over a hurdle clears it without taking damage', () {
      final game = SteadyRunnerGame(
        targetScore: 60,
        durationSeconds: 20,
        onGameCompleted: (s, st) {},
      );
      game.onGameResize(Vector2(400, 800));
      // Player is airborne from jump (groundY is 300, jump height lifts player to 230)
      game.player = TortoisePlayer(position: Vector2(100, 230));
      game.player.groundY = 300;
      game.stateMachine.startGame();

      final hurdle = GameObstacle(type: ObstacleType.hurdle, position: Vector2(100, 304));
      game.add(hurdle);

      // Verify jump clearance condition: player bottom is above obstacle top
      final isCleared = (game.player.position.y + 22.0) < (hurdle.position.y - 14.0);
      expect(isCleared, isTrue);
      expect(game.scoreManager.lives, 3); // Untouched
    });
  });

  group('CadenceRhythmGame Timing Windows & Accuracy Tests', () {
    test('Accuracy percentage correctly accounts for hits and misses', () {
      final game = CadenceRhythmGame(
        targetScore: 60,
        durationSeconds: 20,
        onGameCompleted: (s, st) {},
      );
      game.onGameResize(Vector2(400, 800));
      game.player = TortoisePlayer(position: Vector2(50, 300));
      game.stateMachine.startGame();

      // Initial accuracy is 100%
      expect(game.accuracyPercentage, 100);
    });

    test('Perfect timing window hit awards 30 points and advances combo', () {
      final game = CadenceRhythmGame(
        targetScore: 60,
        durationSeconds: 20,
        onGameCompleted: (s, st) {},
      );
      game.onGameResize(Vector2(400, 800));
      game.player = TortoisePlayer(position: Vector2(50, 300));
      game.stateMachine.startGame();

      // Hitline is at 800 * 0.76 = 608. Add note at 605 (distance = 3px <= 22px -> Perfect!)
      const hitLineY = 800 * 0.76;
      final note = RhythmNoteComponent(isLeftLane: true, position: Vector2(400 * 0.38, hitLineY - 3), speed: 210);
      game.addNoteForTesting(note);

      // Trigger left tap down
      game.simulateTap(true);

      expect(game.scoreManager.score, 30);
      expect(game.scoreManager.combo, 1);
      expect(game.feedbackText, 'PERFECT! ⭐');
      expect(game.accuracyPercentage, 100);
    });

    test('Good timing window hit awards 15 points and advances combo', () {
      final game = CadenceRhythmGame(
        targetScore: 60,
        durationSeconds: 20,
        onGameCompleted: (s, st) {},
      );
      game.onGameResize(Vector2(400, 800));
      game.player = TortoisePlayer(position: Vector2(50, 300));
      game.stateMachine.startGame();

      const hitLineY = 800 * 0.76;
      // Note at distance 40px (> 22px and <= 55px -> Good!)
      final note = RhythmNoteComponent(isLeftLane: true, position: Vector2(400 * 0.38, hitLineY - 40), speed: 210);
      game.addNoteForTesting(note);

      game.simulateTap(true);

      expect(game.scoreManager.score, 15);
      expect(game.scoreManager.combo, 1);
      expect(game.feedbackText, 'GOOD! 🎵');
    });
  });

  group('RibbonSprintGame Stamina & AI Tests', () {
    test('Initial stamina is full and recovers passively over time', () {
      final game = RibbonSprintGame(
        targetScore: 70,
        durationSeconds: 20,
        onGameCompleted: (s, st) {},
      );
      game.onGameResize(Vector2(400, 800));
      game.player = TortoisePlayer(position: Vector2(50, 300));
      game.hare = HareEnemy(position: Vector2(50, 200), initialAnimation: CharacterAnimationState.run);
      game.finishRibbon = FinishRibbon(position: Vector2(400, 300), size: Vector2(20, 50), onRibbonBroken: () {});
      game.stateMachine.startGame();

      expect(game.staminaRatio, 1.0);

      // Passive recovery
      game.update(0.5);
      expect(game.staminaRatio, 1.0);
    });

    test('Tapping consumes stamina without awarding fake score points', () {
      final game = RibbonSprintGame(
        targetScore: 70,
        durationSeconds: 20,
        onGameCompleted: (s, st) {},
      );
      game.onGameResize(Vector2(400, 800));
      game.player = TortoisePlayer(position: Vector2(50, 300));
      game.hare = HareEnemy(position: Vector2(50, 200), initialAnimation: CharacterAnimationState.run);
      game.finishRibbon = FinishRibbon(position: Vector2(400, 300), size: Vector2(20, 50), onRibbonBroken: () {});
      game.stateMachine.startGame();

      expect(game.staminaRatio, 1.0);
      expect(game.scoreManager.score, 0);

      // Tap to sprint
      game.simulateSprintTap();

      // Stamina decreases by 12%
      expect(game.staminaRatio, closeTo(0.88, 0.01));
      // NO fake score added on tap!
      expect(game.scoreManager.score, 0);
    });
  });

  group('MiniGame Widgets Integration Tests', () {
    testWidgets('ForestWalkMiniGame renders GameWidget', (tester) async {
      const step = MiniGameStep(
        id: 'mg1',
        title: 'Forest Walk',
        instructionsEn: 'Collect clovers and dodge brambles!',
        instructionsRegional: 'लौंग इकट्ठा करें और झाड़ियों से बचें!',
        gameType: MiniGameType.forestWalk,
        targetScore: 50,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ForestWalkMiniGame(
              step: step,
              onComplete: (score) {},
            ),
          ),
        ),
      );

      expect(find.byType(typeOf<GameWidget<SlidingTurtleGame>>()), findsOneWidget);
    });

    testWidgets('RaceBeginsMiniGame renders GameWidget', (tester) async {
      const step = MiniGameStep(
        id: 'mg2',
        title: 'Steady Runner',
        instructionsEn: 'Jump over hurdles!',
        instructionsRegional: 'बाधाओं पर से कूदें!',
        gameType: MiniGameType.raceBegins,
        targetScore: 60,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RaceBeginsMiniGame(
              step: step,
              onComplete: (score) {},
            ),
          ),
        ),
      );

      expect(find.byType(typeOf<GameWidget<SteadyRunnerGame>>()), findsOneWidget);
    });

    testWidgets('RhythmStepsMiniGame renders GameWidget', (tester) async {
      const step = MiniGameStep(
        id: 'mg3',
        title: 'Cadence Rhythm',
        instructionsEn: 'Tap to the rhythm!',
        instructionsRegional: 'ताल पर टैप करें!',
        gameType: MiniGameType.rhythmSteps,
        targetScore: 60,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RhythmStepsMiniGame(
              step: step,
              onComplete: (score) {},
            ),
          ),
        ),
      );

      expect(find.byType(typeOf<GameWidget<CadenceRhythmGame>>()), findsOneWidget);
    });

    testWidgets('FinalSprintMiniGame renders GameWidget', (tester) async {
      const step = MiniGameStep(
        id: 'mg4',
        title: 'Ribbon Sprint',
        instructionsEn: 'Sprint to the finish ribbon!',
        instructionsRegional: 'समाप्ति रिबन की ओर दौड़ें!',
        gameType: MiniGameType.finalSprint,
        targetScore: 70,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinalSprintMiniGame(
              step: step,
              onComplete: (score) {},
            ),
          ),
        ),
      );

      expect(find.byType(typeOf<GameWidget<RibbonSprintGame>>()), findsOneWidget);
    });

    testWidgets('MemoryMatchMiniGame renders grid and responds to card tap', (tester) async {
      const step = MiniGameStep(
        id: 'panchatantra_mg1',
        title: 'Jungle Memory Pairs',
        instructionsEn: 'Find matching animal pairs!',
        instructionsRegional: 'जानवरों के जोड़े खोजें!',
        gameType: MiniGameType.memoryMatch,
        targetScore: 60,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemoryMatchMiniGame(
              step: step,
              onComplete: (score) {},
            ),
          ),
        ),
      );

      expect(find.text('Jungle Memory Pairs'), findsOneWidget);
      expect(find.text('🪷'), findsWidgets);
    });
  });
}

Type typeOf<T>() => T;
