import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

enum QuizOptionState {
  defaultState,
  selectedCorrect,
  selectedIncorrect,
  revealedCorrect,
}

class QuizOptionCard extends StatelessWidget {
  final int index;
  final String text;
  final QuizOptionState state;
  final VoidCallback onTap;

  const QuizOptionCard({
    super.key,
    required this.index,
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    Color badgeColor = AppTheme.primary;
    IconData? trailingIcon;

    switch (state) {
      case QuizOptionState.selectedCorrect:
      case QuizOptionState.revealedCorrect:
        bgColor = const Color(0xFFE8F5E9);
        borderColor = const Color(0xFF2EC4B6);
        badgeColor = const Color(0xFF2EC4B6);
        trailingIcon = Icons.check_circle_rounded;
        break;
      case QuizOptionState.selectedIncorrect:
        bgColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFE76F51);
        badgeColor = const Color(0xFFE76F51);
        trailingIcon = Icons.cancel_rounded;
        break;
      case QuizOptionState.defaultState:
        bgColor = Colors.white;
        borderColor = Colors.grey.shade200;
        badgeColor = AppTheme.primary;
        trailingIcon = null;
        break;
    }

    final letter = String.fromCharCode(65 + index); // A, B, C...

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Option Letter Pill
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Option text
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ),

              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(trailingIcon, color: badgeColor, size: 28),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
