import 'package:flutter_test/flutter_test.dart';
import 'package:katha_quest/core/models/story_model.dart';
import 'package:katha_quest/data/sample_stories.dart';
import 'package:katha_quest/state/game_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KathaQuest Story Engine & Gamification Tests', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
    });

    test("The Ramayana (Rama's Exile) structure has interactive steps", () {
      final story = SampleStories.ramasExile;
      expect(story.id, 'story_rama_exile');
      expect(story.steps.length, 6);

      // Verify sequence: Comic -> MiniGame -> Comic -> MiniGame -> Quiz -> Reward
      expect(story.steps[0].type, StoryStepType.comic);
      expect(story.steps[1].type, StoryStepType.miniGame);
      expect(story.steps[2].type, StoryStepType.comic);
      expect(story.steps[3].type, StoryStepType.miniGame);
      expect(story.steps[4].type, StoryStepType.quiz);
      expect(story.steps[5].type, StoryStepType.reward);
    });

    test('MiniGames in Ramayana match design specifications', () {
      final story = SampleStories.ramasExile;

      final mg1 = story.steps[1] as MiniGameStep;
      expect(mg1.gameType, MiniGameType.forestWalk);
      expect(mg1.targetScore, 50);

      final mg2 = story.steps[3] as MiniGameStep;
      expect(mg2.gameType, MiniGameType.raceBegins);
      expect(mg2.targetScore, 60);
    });

    test('GameState starts and steps through the story correctly', () {
      final story = SampleStories.ramasExile;

      gameState.startStory(story);
      expect(gameState.currentStory?.id, story.id);
      expect(gameState.currentStepIndex, 0);
      expect(gameState.currentStep?.type, StoryStepType.comic);

      // Next step
      gameState.nextStep();
      expect(gameState.currentStepIndex, 1);
      expect(gameState.currentStep?.type, StoryStepType.miniGame);

      // Complete minigame
      final initialXp = gameState.profile.currentXp;
      gameState.completeMiniGame(50);
      expect(gameState.currentStepIndex, 2);
      expect(gameState.currentMiniGameScore, 50);
      expect(gameState.profile.currentXp, initialXp + 100);
    });

    test('Comprehension quiz scoring awards stars accurately', () {
      final story = SampleStories.ramasExile;
      gameState.startStory(story);

      // Perfect score -> 3 stars
      gameState.recordQuizResult(correctAnswers: 2, totalQuestions: 2);
      expect(gameState.sessionStarsEarned, 3);
      expect(gameState.quizCorrectCount, 2);

      // 1/2 score -> 2 stars
      gameState.recordQuizResult(correctAnswers: 1, totalQuestions: 2);
      expect(gameState.sessionStarsEarned, 2);

      // 0/2 score -> 1 star
      gameState.recordQuizResult(correctAnswers: 0, totalQuestions: 2);
      expect(gameState.sessionStarsEarned, 1);
    });

    test('Tab navigation and map chapter selection works', () {
      expect(gameState.currentTabIndex, 0);
      gameState.setTabIndex(2);
      expect(gameState.currentTabIndex, 2);

      expect(gameState.selectedMapChapterId, 'ch_2');
      gameState.selectMapChapter('ch_1');
      expect(gameState.selectedMapChapterId, 'ch_1');
    });

    test('Bilingual language toggle switches between English and Hindi', () {
      expect(gameState.selectedLanguage, 'en');
      expect(gameState.isHindi, false);

      gameState.toggleLanguage();
      expect(gameState.selectedLanguage, 'hi');
      expect(gameState.isHindi, true);

      gameState.toggleLanguage();
      expect(gameState.selectedLanguage, 'en');
      expect(gameState.isHindi, false);
    });

    test('The Hare and the Tortoise story branch structure and assets', () {
      final story = SampleStories.hareAndTortoise;
      expect(story.id, 'story_hare_tortoise');
      expect(story.titleEn, 'The Hare and the Tortoise');
      expect(story.titleRegional, 'कछुआ और खरगोश');
      expect(story.steps.length, 6);

      // Verify canonical 6-stage loop: Comic -> MiniGame -> Comic -> MiniGame -> Quiz -> Reward
      // Step 0: Comic 1 (2 Panels)
      expect(story.steps[0].type, StoryStepType.comic);
      final c1 = story.steps[0] as ComicStep;
      expect(c1.panels.length, 2);
      expect(c1.panels[0].backgroundImage, 'assets/images/backgrounds_for_hare_tortoise_story/1.png');
      expect(c1.panels[0].interactiveTargets[0].spriteAnimation, 'hare_idle');
      expect(c1.panels[0].interactiveTargets[1].spriteAnimation, 'tortoise_idle');
      expect(c1.panels[1].backgroundImage, 'assets/images/backgrounds_for_hare_tortoise_story/2.png');

      // Step 1: MiniGame 1
      expect(story.steps[1].type, StoryStepType.miniGame);
      expect((story.steps[1] as MiniGameStep).gameType, MiniGameType.forestWalk);

      // Step 2: Comic 2 (2 Panels)
      expect(story.steps[2].type, StoryStepType.comic);
      final c2 = story.steps[2] as ComicStep;
      expect(c2.panels.length, 2);
      expect(c2.panels[0].backgroundImage, 'assets/images/backgrounds_for_hare_tortoise_story/4.png');
      expect(c2.panels[0].interactiveTargets[0].spriteAnimation, 'hare_sleep');
      expect(c2.panels[1].backgroundImage, 'assets/images/backgrounds_for_hare_tortoise_story/5.png');

      // Step 3: MiniGame 2
      expect(story.steps[3].type, StoryStepType.miniGame);
      expect((story.steps[3] as MiniGameStep).gameType, MiniGameType.finalSprint);

      // Step 4: Quiz
      expect(story.steps[4].type, StoryStepType.quiz);
      final quiz = story.steps[4] as QuizStep;
      expect(quiz.questions.length, 3);

      // Step 5: Reward
      expect(story.steps[5].type, StoryStepType.reward);
      final reward = story.steps[5] as RewardStep;
      expect(reward.badgeName, 'Emerald Green Badge');
    });

    test('Audio settings toggle correctly', () {
      expect(gameState.profile.isBgmEnabled, true);
      gameState.toggleBgm();
      expect(gameState.profile.isBgmEnabled, false);

      expect(gameState.profile.isSfxEnabled, true);
      gameState.toggleSfx();
      expect(gameState.profile.isSfxEnabled, false);
    });

    test('Pause and restart step mechanics function correctly', () {
      expect(gameState.isPaused, false);
      expect(gameState.stepRevision, 0);

      // Pause
      gameState.setPaused(true);
      expect(gameState.isPaused, true);

      // Restart step resets pause and increments stepRevision
      gameState.restartCurrentStep();
      expect(gameState.isPaused, false);
      expect(gameState.stepRevision, 1);

      // Subsequent restart increments further
      gameState.restartCurrentStep();
      expect(gameState.stepRevision, 2);
    });

    test('Quiz questions include comprehensive bilingual educational explanations', () {
      final story = SampleStories.hareAndTortoise;
      final quiz = story.steps[4] as QuizStep;

      for (final q in quiz.questions) {
        expect(q.explanationEn.isNotEmpty, true, reason: 'explanationEn must not be empty');
        expect(q.explanationRegional.isNotEmpty, true, reason: 'explanationRegional must not be empty');
      }
    });

    test('Achievement claiming awards XP/Coins and prevents duplicate claims in database', () {
      expect(gameState.profile.claimedAchievementIds.contains('story_explorer'), false);
      final initialXp = gameState.profile.currentXp;
      final initialCoins = gameState.profile.coins;

      // First claim succeeds
      final success = gameState.claimAchievement('story_explorer', 500, 50);
      expect(success, true);
      expect(gameState.profile.claimedAchievementIds.contains('story_explorer'), true);
      expect(gameState.profile.currentXp, initialXp + 500);
      expect(gameState.profile.coins, initialCoins + 50);

      // Duplicate claim fails
      final duplicate = gameState.claimAchievement('story_explorer', 500, 50);
      expect(duplicate, false);
      expect(gameState.profile.coins, initialCoins + 50);
    });

    test('Daily Quest claiming awards 300 XP and Coins and records claim date', () {
      final initialXp = gameState.profile.currentXp;
      final initialCoins = gameState.profile.coins;

      // First claim succeeds
      final success = gameState.claimDailyQuest();
      expect(success, true);
      expect(gameState.profile.lastDailyQuestClaimedDate, isNotNull);
      expect(gameState.profile.currentXp, initialXp + 300);
      expect(gameState.profile.coins, initialCoins + 300);

      // Subsequent claim today fails
      final duplicate = gameState.claimDailyQuest();
      expect(duplicate, false);
      expect(gameState.profile.coins, initialCoins + 300);
    });

    test('Player avatar customization updates profile and database state', () {
      gameState.updateAvatar(emoji: '👑', asset: 'assets/images/story_vikram_betaal.jpg');
      expect(gameState.profile.avatarEmoji, '👑');
      expect(gameState.profile.avatarAsset, 'assets/images/story_vikram_betaal.jpg');
    });

    test('Parent screen time limit updates profile and database state', () {
      gameState.setScreenTimeLimit(45);
      expect(gameState.profile.screenTimeLimitMinutes, 45);
    });

    test('Database reset restores defaults cleanly', () async {
      gameState.claimAchievement('ruby_red', 1000, 150);
      expect(gameState.profile.claimedAchievementIds.contains('ruby_red'), true);

      await gameState.resetAllProgress();
      expect(gameState.profile.claimedAchievementIds.contains('ruby_red'), false);
      expect(gameState.currentStory, isNull);
    });

    test('Panchatantra Tales has full 6-step saga with Memory Match and Quiz', () {
      final story = SampleStories.panchatantraTales;
      expect(story.steps.length, 6);
      expect(story.coverImage, isNotNull);

      // Step 1: Comic Intro
      expect(story.steps[0].type, StoryStepType.comic);
      final step1 = story.steps[0] as ComicStep;
      expect(step1.panels.isNotEmpty, true);
      expect(step1.panels[0].interactiveTargets.isNotEmpty, true);

      // Step 2: Forest Walk minigame
      expect(story.steps[1].type, StoryStepType.miniGame);
      final step2 = story.steps[1] as MiniGameStep;
      expect(step2.gameType, MiniGameType.forestWalk);

      // Step 3: Comic Scene 2
      expect(story.steps[2].type, StoryStepType.comic);

      // Step 4: Memory Match minigame
      expect(story.steps[3].type, StoryStepType.miniGame);
      final step4 = story.steps[3] as MiniGameStep;
      expect(step4.gameType, MiniGameType.memoryMatch);
      expect(step4.targetScore, 120);

      // Step 5: Bilingual Quiz
      expect(story.steps[4].type, StoryStepType.quiz);
      final step5 = story.steps[4] as QuizStep;
      expect(step5.questions.length, 3);

      // Step 6: Reward
      expect(story.steps[5].type, StoryStepType.reward);
      final step6 = story.steps[5] as RewardStep;
      expect(step6.badgeName, 'Emerald Green');
    });

    test('Mid-story progress saves step index and resumes correctly', () {
      final story = SampleStories.panchatantraTales;
      gameState.startStory(story);
      expect(gameState.currentStepIndex, 0);

      gameState.nextStep();
      expect(gameState.currentStepIndex, 1);
      expect(gameState.profile.activeStorySteps[story.id], 1);

      // Starting another session resumes from step 1
      gameState.startStory(story, resume: true);
      expect(gameState.currentStepIndex, 1);

      // Starting fresh resets to 0
      gameState.startStory(story, resume: false);
      expect(gameState.currentStepIndex, 0);

      // Finishing story cleans up activeStorySteps
      gameState.finishStory(badge: 'Emerald Green');
      expect(gameState.profile.activeStorySteps.containsKey(story.id), false);
    });

    test('Onboarding completion updates profile and marks completed', () {
      gameState.completeOnboarding(
        playerName: 'Kavya',
        avatarEmoji: '🦚',
        avatarAsset: 'assets/spritesheets/turtle.png',
      );
      expect(gameState.profile.playerName, 'Kavya');
      expect(gameState.profile.avatarEmoji, '🦚');
      expect(gameState.profile.hasCompletedOnboarding, true);
    });

    test('Bazaar economy purchases and equips titles and bubble skins', () {
      gameState.profile.coins = 500;

      // Purchase title
      final bought = gameState.purchaseItem(itemId: 'title_champion', cost: 250);
      expect(bought, true);
      expect(gameState.profile.coins, 250);
      expect(gameState.profile.purchasedItemIds.contains('title_champion'), true);

      // Equip title
      gameState.equipTitle('Mythic Champion');
      expect(gameState.profile.currentTitle, 'Mythic Champion');

      // Equip bubble theme
      gameState.equipBubbleTheme('bubble_gold');
      expect(gameState.profile.currentBubbleTheme, 'bubble_gold');

      // Cannot buy without enough coins
      final failBuy = gameState.purchaseItem(itemId: 'avatar_tiger', cost: 500);
      expect(failBuy, false);
      expect(gameState.profile.coins, 250);
    });

    test('Panel-level persistence saves exact panel index and resumes without restarting', () {
      final story = SampleStories.hareAndTortoise;
      gameState.startStory(story);
      expect(gameState.currentStepIndex, 0);
      expect(gameState.currentPanelIndex, 0);

      // User swipes to panel 1 (index 1) in comic reader
      gameState.setPanelIndex(1);
      expect(gameState.currentPanelIndex, 1);
      expect(gameState.profile.activeStoryPanels[story.id], 1);
      expect(gameState.profile.lastActiveStoryId, story.id);
      expect(gameState.hasActiveStoryInProgress, true);

      // Simulate app close & reopen with resumeActiveStory
      final resumed = gameState.resumeActiveStory(SampleStories.getAllStories());
      expect(resumed, true);
      expect(gameState.currentStory?.id, story.id);
      expect(gameState.currentStepIndex, 0);
      expect(gameState.currentPanelIndex, 1); // Continues from last panel, never restarts from 0!

      // Moving to next step (step 1 is MiniGame)
      gameState.nextStep();
      expect(gameState.currentStepIndex, 1);
      expect(gameState.currentPanelIndex, 0);

      // Move to step 2 (Comic Scene 2)
      gameState.nextStep();
      expect(gameState.currentStepIndex, 2);
      expect(gameState.currentPanelIndex, 0);

      // User swipes to panel 1 in Comic Scene 2
      gameState.setPanelIndex(1);
      expect(gameState.currentPanelIndex, 1);
      expect(gameState.profile.activeStoryPanels[story.id], 1);

      // Reopening resumes right at step 2, panel 1
      gameState.startStory(story, resume: true);
      expect(gameState.currentStepIndex, 2);
      expect(gameState.currentPanelIndex, 1);

      // Replay explicitly with resume: false restarts from 0
      gameState.startStory(story, resume: false);
      expect(gameState.currentStepIndex, 0);
      expect(gameState.currentPanelIndex, 0);
    });

    test('Canonical 6-stage loop structure Comic -> MiniGame -> Comic -> MiniGame -> Quiz -> Reward', () {
      final stories = [SampleStories.hareAndTortoise, SampleStories.ramasExile];

      for (final story in stories) {
        expect(story.steps.length, 6);
        expect(story.steps[0].type, StoryStepType.comic);
        expect(story.steps[1].type, StoryStepType.miniGame);
        expect(story.steps[2].type, StoryStepType.comic);
        expect(story.steps[3].type, StoryStepType.miniGame);
        expect(story.steps[4].type, StoryStepType.quiz);
        expect(story.steps[5].type, StoryStepType.reward);

        // Both comic steps have multi-panel scene support
        final comicStep1 = story.steps[0] as ComicStep;
        final comicStep2 = story.steps[2] as ComicStep;
        expect(comicStep1.panels.length >= 2, true);
        expect(comicStep2.panels.length >= 2, true);
      }
    });
  });
}
