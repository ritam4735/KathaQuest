import 'package:flutter/foundation.dart';
import 'narration_service_stub.dart'
    if (dart.library.html) 'narration_service_web.dart'
    if (dart.library.io) 'narration_service_io.dart';

enum NarrationStatus {
  idle,
  loading,
  playing,
  paused,
}

abstract class NarrationService {
  static NarrationService? _instance;
  static NarrationService get instance => _instance ??= createNarrationService();

  NarrationStatus get status;
  ValueNotifier<NarrationStatus> get statusNotifier;
  ValueNotifier<int> get currentWordIndexNotifier;
  ValueNotifier<int> get currentCharIndexNotifier;

  /// Speaks the provided text in the target language ('en' or 'hi').
  /// Supports word-level callbacks and completion notifications.
  Future<void> speak({
    required String text,
    required String language,
    String? audioAssetPath,
    VoidCallback? onStart,
    VoidCallback? onComplete,
    VoidCallback? onError,
    Function(int charIndex, String word)? onWordBoundary,
  });

  /// Pauses active narration.
  void pause();

  /// Resumes paused narration.
  void resume();

  /// Replays the last spoken text.
  void replay();

  /// Completely stops any active narration.
  void stop();
}
