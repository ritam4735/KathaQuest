enum StoryStepType {
  comic,
  miniGame,
  quiz,
  reward,
}

enum MiniGameType {
  forestWalk,
  raceBegins,
  rhythmSteps,
  finalSprint,
}

abstract class StoryStep {
  final String id;
  final StoryStepType type;
  final String title;

  const StoryStep({
    required this.id,
    required this.type,
    required this.title,
  });
}

class ComicDialogue {
  final String speaker;
  final String avatar;
  final String textEn;
  final String textRegional;
  final bool isLeftAligned;

  const ComicDialogue({
    required this.speaker,
    required this.avatar,
    required this.textEn,
    required this.textRegional,
    this.isLeftAligned = true,
  });
}

class ComicCharacterTarget {
  final String characterId;
  final String name;
  final String emoji;
  final double posX; // 0.0 - 1.0
  final double posY; // 0.0 - 1.0
  final String tapReactionType;
  final String soundEffect;
  final String speechBubbleOnTap;
  final String? spriteAnimation; // e.g. 'hare_idle', 'hare_run', 'tortoise_walk'

  const ComicCharacterTarget({
    required this.characterId,
    required this.name,
    required this.emoji,
    required this.posX,
    required this.posY,
    required this.tapReactionType,
    required this.soundEffect,
    required this.speechBubbleOnTap,
    this.spriteAnimation,
  });
}

class ComicPanel {
  final String panelId;
  final String backgroundTheme;
  final String narrationEn;
  final String narrationRegional;
  final List<ComicDialogue> dialogues;
  final List<ComicCharacterTarget> interactiveTargets;
  final String? backgroundImage; // e.g. 'assets/images/backgrounds_for_hare_tortoise_story/1.png'

  const ComicPanel({
    required this.panelId,
    required this.backgroundTheme,
    required this.narrationEn,
    required this.narrationRegional,
    this.dialogues = const [],
    this.interactiveTargets = const [],
    this.backgroundImage,
  });
}

class ComicStep extends StoryStep {
  final List<ComicPanel> panels;

  const ComicStep({
    required super.id,
    required super.title,
    required this.panels,
  }) : super(type: StoryStepType.comic);
}

class MiniGameStep extends StoryStep {
  final MiniGameType gameType;
  final String instructionsEn;
  final String instructionsRegional;
  final int targetScore;
  final int durationSeconds;

  const MiniGameStep({
    required super.id,
    required super.title,
    required this.gameType,
    required this.instructionsEn,
    required this.instructionsRegional,
    this.targetScore = 100,
    this.durationSeconds = 30,
  }) : super(type: StoryStepType.miniGame);
}

class QuizQuestion {
  final String id;
  final String questionEn;
  final String questionRegional;
  final List<String> optionsEn;
  final List<String> optionsRegional;
  final int correctOptionIndex;
  final String explanationEn;
  final String explanationRegional;

  const QuizQuestion({
    required this.id,
    required this.questionEn,
    required this.questionRegional,
    required this.optionsEn,
    required this.optionsRegional,
    required this.correctOptionIndex,
    required this.explanationEn,
    required this.explanationRegional,
  });
}

class QuizStep extends StoryStep {
  final List<QuizQuestion> questions;

  const QuizStep({
    required super.id,
    required super.title,
    required this.questions,
  }) : super(type: StoryStepType.quiz);
}

class RewardStep extends StoryStep {
  final String badgeName;
  final String badgeIcon;
  final String badgeDescriptionEn;
  final String badgeDescriptionRegional;
  final int baseStars;

  const RewardStep({
    required super.id,
    required super.title,
    required this.badgeName,
    required this.badgeIcon,
    required this.badgeDescriptionEn,
    required this.badgeDescriptionRegional,
    this.baseStars = 3,
  }) : super(type: StoryStepType.reward);
}

class Story {
  final String id;
  final String titleEn;
  final String titleRegional;
  final String synopsisEn;
  final String synopsisRegional;
  final String moralEn;
  final String moralRegional;
  final String coverEmoji;
  final String category;
  final int estimatedMinutes;
  final int targetAgeMin;
  final int targetAgeMax;
  final List<StoryStep> steps;

  const Story({
    required this.id,
    required this.titleEn,
    required this.titleRegional,
    required this.synopsisEn,
    required this.synopsisRegional,
    required this.moralEn,
    required this.moralRegional,
    required this.coverEmoji,
    required this.category,
    required this.estimatedMinutes,
    required this.targetAgeMin,
    required this.targetAgeMax,
    required this.steps,
  });
}
