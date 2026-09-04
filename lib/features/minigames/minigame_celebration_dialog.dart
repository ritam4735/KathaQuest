import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/haptic_feedback_helper.dart';

class MiniGameCelebrationDialog {
  static void show({
    required BuildContext context,
    required int score,
    required int targetScore,
    required String emoji,
    required VoidCallback onContinue,
    bool isHindi = false,
  }) {
    HapticHelper.success();

    final double ratio = targetScore > 0 ? (score / targetScore) : 1.0;
    String tierTitle;
    String tierMessage;
    String badgeEmoji;

    if (ratio >= 0.85 || score >= targetScore) {
      // Excellent Tier
      tierTitle = isHindi ? 'अद्भुत! 🌟' : 'Amazing! 🌟';
      tierMessage = isHindi
          ? 'आपने शांत रहकर कछुए की बहुत सुंदर सहायता की!'
          : 'You stayed calm and helped the tortoise beautifully!';
      badgeEmoji = '🏆';
    } else if (ratio >= 0.45) {
      // Good Tier
      tierTitle = isHindi ? 'बहुत बढ़िया! 🐢' : 'Great job! 🐢';
      tierMessage = isHindi
          ? 'आपने कछुए को मंज़िल तक पहुँचाने में मदद की!'
          : 'You helped the tortoise reach the finish!';
      badgeEmoji = '⭐';
    } else {
      // Needs Practice Tier (Always encouraging, never punishing)
      tierTitle = isHindi ? 'शानदार प्रयास! 🌸' : 'Wonderful effort! 🌸';
      tierMessage = isHindi
          ? 'चलो फिर से कोशिश करते हैं और और भी बेहतर करते हैं!'
          : 'Let\'s try again and do even better!';
      badgeEmoji = '🌱';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: const Color(0xFFFFFDF8),
        title: Column(
          children: [
            Text(badgeEmoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              tierTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tierMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD166), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    isHindi ? 'स्कोर: $score अंक' : 'Score: $score Points',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                HapticHelper.light();
                Navigator.of(ctx).pop();
                onContinue();
              },
              child: Text(
                isHindi ? 'आगे बढ़ें ➡️' : 'Continue Story! ➡️',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
