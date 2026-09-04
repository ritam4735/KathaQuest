import 'dart:async';
import 'package:flutter/foundation.dart';
import '../audio_manager.dart';
import 'narration_service.dart';

NarrationService createNarrationService() => IoNarrationService();

class IoNarrationService implements NarrationService {
  NarrationStatus _status = NarrationStatus.idle;
  final ValueNotifier<NarrationStatus> _statusNotifier =
      ValueNotifier<NarrationStatus>(NarrationStatus.idle);
  final ValueNotifier<int> _currentWordIndexNotifier = ValueNotifier<int>(-1);
  final ValueNotifier<int> _currentCharIndexNotifier = ValueNotifier<int>(-1);

  Timer? _ticker;
  String _lastText = '';
  String _lastLanguage = 'en';
  VoidCallback? _lastOnComplete;
  Function(int, String)? _lastOnWordBoundary;
  List<String> _words = [];

  @override
  NarrationStatus get status => _status;

  @override
  ValueNotifier<NarrationStatus> get statusNotifier => _statusNotifier;

  @override
  ValueNotifier<int> get currentWordIndexNotifier => _currentWordIndexNotifier;

  @override
  ValueNotifier<int> get currentCharIndexNotifier => _currentCharIndexNotifier;

  void _setStatus(NarrationStatus s) {
    _status = s;
    _statusNotifier.value = s;
  }

  @override
  Future<void> speak({
    required String text,
    required String language,
    String? audioAssetPath,
    VoidCallback? onStart,
    VoidCallback? onComplete,
    VoidCallback? onError,
    Function(int charIndex, String word)? onWordBoundary,
  }) async {
    stop();

    _lastText = text;
    _lastLanguage = language;
    _lastOnComplete = onComplete;
    _lastOnWordBoundary = onWordBoundary;

    _words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    _setStatus(NarrationStatus.playing);
    AudioManager().startNarrationDucking();
    onStart?.call();

    int idx = 0;
    const interval = Duration(milliseconds: 360);
    _ticker = Timer.periodic(interval, (t) {
      if (_status != NarrationStatus.playing) {
        t.cancel();
        return;
      }
      if (idx < _words.length) {
        _currentWordIndexNotifier.value = idx;
        onWordBoundary?.call(idx * 6, _words[idx]);
        idx++;
      } else {
        t.cancel();
        AudioManager().stopNarrationDucking();
        _setStatus(NarrationStatus.idle);
        onComplete?.call();
      }
    });
  }

  @override
  void pause() {
    _ticker?.cancel();
    _setStatus(NarrationStatus.paused);
  }

  @override
  void resume() {
    if (_status == NarrationStatus.paused) {
      _setStatus(NarrationStatus.playing);
      speak(
        text: _lastText,
        language: _lastLanguage,
        onComplete: _lastOnComplete,
        onWordBoundary: _lastOnWordBoundary,
      );
    }
  }

  @override
  void replay() {
    if (_lastText.isNotEmpty) {
      speak(
        text: _lastText,
        language: _lastLanguage,
        onComplete: _lastOnComplete,
        onWordBoundary: _lastOnWordBoundary,
      );
    }
  }

  @override
  void stop() {
    _ticker?.cancel();
    AudioManager().stopNarrationDucking();
    _currentWordIndexNotifier.value = -1;
    _currentCharIndexNotifier.value = -1;
    _setStatus(NarrationStatus.idle);
  }
}
