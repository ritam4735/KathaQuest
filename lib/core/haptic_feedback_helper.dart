import 'package:flutter/services.dart';

/// Centralized helper for subtle, child-friendly tactile feedback.
class HapticHelper {
  /// Light impact for general UI buttons, navigation, and panel flips.
  static void light() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Tactile feedback for quiz option selection.
  static void selection() {
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Medium impact when collecting items in minigames.
  static void collect() {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Celebratory vibration on completing steps, earning stars, or badges.
  static void success() {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }
}
