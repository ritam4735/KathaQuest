import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/story_model.dart';
import '../../core/audio_manager.dart';
import '../../core/app_theme.dart';
import '../../state/game_state.dart';
import '../../widgets/tactile_pill_button.dart';
import '../../widgets/rama_mascot_widget.dart';

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

class _QuizViewState extends State<QuizView> {
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _hasAnswered = false;
  int _correctCount = 0;

  QuizQuestion get currentQuestion =>
      widget.step.questions[_currentQuestionIndex];

  void _handleOptionSelect(int index) {
    if (_hasAnswered) return;

    final isCorrect = index == currentQuestion.correctOptionIndex;
    setState(() {
      _selectedOptionIndex = index;
      _hasAnswered = true;
      if (isCorrect) {
        _correctCount++;
        AudioManager().playCorrect();
      } else {
        AudioManager().playWrong();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.step.questions.length - 1) {
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

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7EEDB),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              // Top Chapter Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _currentQuestionIndex ? const Color(0xFF8D6E63) : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // MAIN PARCHMENT QUESTION CARD (Matching Screenshot 4)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                      // Header Plaque: "The Ramayana" with Mandala Filigree
                      Align(
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7EA),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE5D5B5), width: 1.5),
                              ),
                              child: const Text(
                                'The Ramayana',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                  fontFamily: 'serif',
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Ornate Mandala Flourish Divider
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(width: 40, height: 1, color: const Color(0xFFD4A310)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text('☸️', style: TextStyle(fontSize: 12)),
                                ),
                                Container(width: 40, height: 1, color: const Color(0xFFD4A310)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Question Prompt
                      Positioned(
                        top: 70,
                        left: 0,
                        right: 0,
                        child: Text(
                          questionText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF3E2723),
                            fontFamily: 'serif',
                            height: 1.3,
                          ),
                        ),
                      ),

                      // Four 3D Pill Options List
                      Positioned(
                        top: 155,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: options.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
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

                      // Young Lord Rama Mascot with Thumbs-up (Matching Screenshot 4)
                      if (_hasAnswered)
                        const Positioned(
                          bottom: -15,
                          right: -10,
                          child: RamaMascotWidget(
                            xpReward: 50,
                            coinsReward: 10,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Bottom Continue Action Button if answered
              if (_hasAnswered)
                TactilePillButton(
                  text: _currentQuestionIndex < totalQuestions - 1
                      ? 'Next Question ➡️'
                      : 'Claim Rewards! 🏆',
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
