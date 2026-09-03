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
      expect(story.steps.length, 11);

      // Verify sequence of comic scenes and minigames
      expect(story.steps[0].type, StoryStepType.comic);
      final c1 = story.steps[0] as ComicStep;
      expect(c1.panels[0].backgroundImage, 'assets/images/backgrounds_for_hare_tortoise_story/1.png');
      expect(c1.panels[0].interactiveTargets[0].spriteAnimation, 'hare_idle');
      expect(c1.panels[0].interactiveTargets[1].spriteAnimation, 'tortoise_idle');

      expect(story.steps[1].type, StoryStepType.miniGame);
      expect((story.steps[1] as MiniGameStep).gameType, MiniGameType.forestWalk);

      expect(story.steps[2].type, StoryStepType.comic);
      final c2 = story.steps[2] as ComicStep;
      expect(c2.panels[0].backgroundImage, 'assets/images/backgrounds_for_hare_tortoise_story/2.png');

      expect(story.steps[3].type, StoryStepType.miniGame);
      expect((story.steps[3] as MiniGameStep).gameType, MiniGameType.raceBegins);

      expect(story.steps[4].type, StoryStepType.comic);
      final c3 = story.steps[4] as ComicStep;
      expect(c3.panels[0].backgroundImage, 'assets/images/backgrounds_for_hare_tortoise_story/4.png');
      expect(c3.panels[0].interactiveTargets[0].spriteAnimation, 'hare_sleep');

      expect(story.steps[5].type, StoryStepType.miniGame);
      expect((story.steps[5] as MiniGameStep).gameType, MiniGameType.rhythmSteps);

      expect(story.steps[6].type, StoryStepType.comic);
      final c4 = story.steps[6] as ComicStep;
      expect(c4.panels[0].backgroundImage, 'assets/images/backgrounds_for_hare_tortoise_story/5.png');

      expect(story.steps[7].type, StoryStepType.miniGame);
      expect((story.steps[7] as MiniGameStep).gameType, MiniGameType.finalSprint);

      expect(story.steps[8].type, StoryStepType.comic);
      final c5 = story.steps[8] as ComicStep;
      expect(c5.panels[0].backgroundImage, 'assets/images/backgrounds_for_hare_tortoise_story/5.png');
      expect(c5.panels[0].interactiveTargets[0].spriteAnimation, 'tortoise_win');
      expect(c5.panels[0].interactiveTargets[1].spriteAnimation, 'hare_cheer');

      expect(story.steps[9].type, StoryStepType.quiz);
      final quiz = story.steps[9] as QuizStep;
      expect(quiz.questions.length, 3);

      expect(story.steps[10].type, StoryStepType.reward);
      final reward = story.steps[10] as RewardStep;
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
  });
}
