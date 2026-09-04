import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/story_model.dart';
import '../../core/audio_manager.dart';
import '../../core/app_theme.dart';
import '../../core/haptic_feedback_helper.dart';
import '../../state/game_state.dart';
import '../../widgets/tactile_pill_button.dart';

class QuizView extends StatefulWidget {
  final QuizStep step;
  final Function(int correct, int total) onComplete;

  const QuizView({
    super.key,
    required this.step,
    required this.onComplete,
  });

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _hasAnswered = false;
  int _correctCount = 0;

  late AnimationController _explanationAnimController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  QuizQuestion get currentQuestion =>
      widget.step.questions[_currentQuestionIndex];

  @override
  void initState() {
    super.initState();
    _explanationAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _explanationAnimController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _explanationAnimController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _explanationAnimController.dispose();
    super.dispose();
  }

  void _handleOptionSelect(int index) {
    if (_hasAnswered) return;

    HapticHelper.selection();
    final isCorrect = index == currentQuestion.correctOptionIndex;

    setState(() {
      _selectedOptionIndex = index;
      _hasAnswered = true;
      if (isCorrect) {
        _correctCount++;
        HapticHelper.success();
        AudioManager().playCorrect();
      } else {
        AudioManager().playWrong();
      }
    });

    _explanationAnimController.forward(from: 0.0);
  }

  void _nextQuestion() {
    HapticHelper.light();
    if (_currentQuestionIndex < widget.step.questions.length - 1) {
      _explanationAnimController.reset();
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _hasAnswered = false;
      });
      AudioManager().playTap();
    } else {
      widget.onComplete(_correctCount, widget.step.questions.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final isHindi = gameState.isHindi;
    final question = currentQuestion;
    final totalQuestions = widget.step.questions.length;

    final options = isHindi ? question.optionsRegional : question.optionsEn;
    final questionText =
        isHindi ? question.questionRegional : question.questionEn;
    final explanationText =
        isHindi ? question.explanationRegional : question.explanationEn;

    final storyTitle = isHindi
        ? (gameState.currentStory?.titleRegional ?? 'ज्ञान प्रश्नोत्तरी')
        : (gameState.currentStory?.titleEn ?? 'Story Wisdom Quiz');

    final isCorrectAnswer =
        _selectedOptionIndex == question.correctOptionIndex;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7EEDB),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              // Dynamic Question Progress Indicators (questions.length)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  totalQuestions,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _currentQuestionIndex ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: i == _currentQuestionIndex
                          ? const Color(0xFF8D6E63)
                          : (i < _currentQuestionIndex
                              ? const Color(0xFF2EC4B6)
                              : Colors.grey.shade400),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Main Parchment Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDF5),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFE5D5B5), width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Header Plaque: Dynamic Active Story Title with Filigree
                      Align(
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7EA),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE5D5B5), width: 1.5),
                              ),
                              child: Text(
                                storyTitle,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                  fontFamily: 'serif',
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Ornate Flourish Divider
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(width: 32, height: 1, color: const Color(0xFFD4A310)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                                  child: Text('☸️', style: TextStyle(fontSize: 11)),
                                ),
                                Container(width: 32, height: 1, color: const Color(0xFFD4A310)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Question Prompt
                      Positioned(
                        top: 54,
                        left: 0,
                        right: 0,
                        child: Text(
                          questionText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF3E2723),
                            fontFamily: 'serif',
                            height: 1.3,
                          ),
                        ),
                      ),

                      // Options List (Dimmed/compacted when answered to give room for explanation)
                      Positioned(
                        top: 135,
                        left: 0,
                        right: 0,
                        bottom: _hasAnswered ? 180 : 0,
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: options.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, idx) {
                            final isSelected = _selectedOptionIndex == idx;
                            final isCorrect = idx == question.correctOptionIndex;

                            TactilePillVariant variant = TactilePillVariant.parchment;
                            bool showCheck = false;

                            if (_hasAnswered) {
                              if (isCorrect) {
                                variant = TactilePillVariant.emerald;
                                showCheck = true;
                              } else if (isSelected) {
                                variant = TactilePillVariant.saffron;
                              }
                            }

                            return TactilePillButton(
                              text: options[idx],
                              variant: variant,
                              hasCheckmark: showCheck,
                              onTap: () => _handleOptionSelect(idx),
                            );
                          },
                        ),
                      ),

                      // Slide-Up + Fade Animated Explanation Card
                      if (_hasAnswered)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isCorrectAnswer
                                      ? const Color(0xFFE8F5E9)
                                      : const Color(0xFFFFF8E1),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: isCorrectAnswer
                                        ? const Color(0xFF81C784)
                                        : const Color(0xFFFFD54F),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, -4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          isCorrectAnswer ? '💡' : '🌱',
                                          style: const TextStyle(fontSize: 22),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isHindi ? 'यह सही क्यों है?' : 'Why is this correct?',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isCorrectAnswer
                                                ? const Color(0xFF2EC4B6)
                                                : const Color(0xFFFF9F1C),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            isCorrectAnswer
                                                ? (isHindi ? 'सही उत्तर ✔' : 'Correct! ✔')
                                                : (isHindi ? 'सीखें 💡' : 'Good Try! 💡'),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      explanationText,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Bottom Continue Action Button
              if (_hasAnswered)
                TactilePillButton(
                  text: _currentQuestionIndex < totalQuestions - 1
                      ? (isHindi ? 'अगला प्रश्न ➡️' : 'Next Question ➡️')
                      : (isHindi ? 'इनाम प्राप्त करें! 🏆' : 'Claim Rewards! 🏆'),
                  variant: TactilePillVariant.gold,
                  onTap: _nextQuestion,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
