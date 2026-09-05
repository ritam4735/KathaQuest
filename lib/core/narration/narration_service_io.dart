import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../audio_manager.dart';
import 'narration_service.dart';

NarrationService createNarrationService() => IoNarrationService();

class IoNarrationService implements NarrationService {
  NarrationStatus _status = NarrationStatus.idle;
  final ValueNotifier<NarrationStatus> _statusNotifier =
      ValueNotifier<NarrationStatus>(NarrationStatus.idle);
  final ValueNotifier<int> _currentWordIndexNotifier = ValueNotifier<int>(-1);
  final ValueNotifier<int> _currentCharIndexNotifier = ValueNotifier<int>(-1);

  FlutterTts? _flutterTts;
  bool _isTtsInitialized = false;

  Timer? _simulatedTicker;
  String _lastText = '';
  String _lastLanguage = 'en';
  VoidCallback? _lastOnComplete;
  Function(int, String)? _lastOnWordBoundary;

  List<String> _words = [];
  List<int> _wordCharStarts = [];

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

  Future<void> _initTts() async {
    if (_isTtsInitialized) return;
    _isTtsInitialized = true;

    try {
      final tts = FlutterTts();
      _flutterTts = tts;

      tts.setStartHandler(() {
        _setStatus(NarrationStatus.playing);
        AudioManager().startNarrationDucking();
      });

      tts.setCompletionHandler(() {
        _simulatedTicker?.cancel();
        AudioManager().stopNarrationDucking();
        _currentWordIndexNotifier.value = _words.length;
        _setStatus(NarrationStatus.idle);
        _lastOnComplete?.call();
      });

      tts.setCancelHandler(() {
        _simulatedTicker?.cancel();
        AudioManager().stopNarrationDucking();
        _setStatus(NarrationStatus.idle);
      });

      tts.setErrorHandler((msg) {
        if (kDebugMode) {
          print('⚠️ [IoNarrationService] TTS Error: $msg');
        }
        _simulatedTicker?.cancel();
        AudioManager().stopNarrationDucking();
        _setStatus(NarrationStatus.idle);
      });
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [IoNarrationService] Failed to initialize FlutterTts: $e');
      }
    }
  }

  void _prepareWordIndexMap(String text) {
    _words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    _wordCharStarts = [];
    int searchIdx = 0;
    for (final w in _words) {
      final pos = text.indexOf(w, searchIdx);
      _wordCharStarts.add(pos >= 0 ? pos : searchIdx);
      searchIdx = (pos >= 0 ? pos + w.length : searchIdx + w.length);
    }
  }

  int _findWordIndexForChar(int charIndex) {
    for (int i = _wordCharStarts.length - 1; i >= 0; i--) {
      if (charIndex >= _wordCharStarts[i]) {
        return i;
      }
    }
    return 0;
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

    _setStatus(NarrationStatus.loading);
    _currentWordIndexNotifier.value = -1;
    _currentCharIndexNotifier.value = -1;

    _prepareWordIndexMap(text);

    await _initTts();

    final tts = _flutterTts;
    if (tts == null) {
      _startSimulatedPlayback(
        text: text,
        onStart: onStart,
        onComplete: onComplete,
        onWordBoundary: onWordBoundary,
      );
      return;
    }

    try {
      final langCode = language == 'hi' ? 'hi-IN' : 'en-IN';
      final isAvailable = await tts.isLanguageAvailable(langCode);
      if (isAvailable == true) {
        await tts.setLanguage(langCode);
      } else {
        await tts.setLanguage(language == 'hi' ? 'hi' : 'en-US');
      }

      // Child-friendly warm cadence
      await tts.setSpeechRate(0.48);
      await tts.setPitch(1.05);
      await tts.setVolume(1.0);

      bool hasStarted = false;
      bool hasProgressFired = false;

      tts.setStartHandler(() {
        hasStarted = true;
        _setStatus(NarrationStatus.playing);
        AudioManager().startNarrationDucking();
        onStart?.call();

        // Safety watchdog: if speech starts but device doesn't fire progress callbacks,
        // use simulated word progression so highlighting advances
        Timer(const Duration(milliseconds: 400), () {
          if (_status == NarrationStatus.playing && !hasProgressFired) {
            _startSimulatedWordTicker(onWordBoundary);
          }
        });
      });

      tts.setProgressHandler((String txt, int startOffset, int endOffset, String word) {
        hasProgressFired = true;
        _currentCharIndexNotifier.value = startOffset;
        final wordIdx = _findWordIndexForChar(startOffset);
        if (wordIdx >= 0 && wordIdx < _words.length) {
          _currentWordIndexNotifier.value = wordIdx;
          onWordBoundary?.call(startOffset, _words[wordIdx]);
        }
      });

      final result = await tts.speak(text);
      if (result != 1) {
        // Platform speak returned failure (e.g. in test or unsupported environment)
        _startSimulatedPlayback(
          text: text,
          onStart: onStart,
          onComplete: onComplete,
          onWordBoundary: onWordBoundary,
        );
        return;
      }

      // Watchdog timeout in case startHandler never fires
      Timer(const Duration(milliseconds: 600), () {
        if (!hasStarted && _status == NarrationStatus.loading) {
          _startSimulatedPlayback(
            text: text,
            onStart: onStart,
            onComplete: onComplete,
            onWordBoundary: onWordBoundary,
          );
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [IoNarrationService] Speak exception, falling back: $e');
      }
      _startSimulatedPlayback(
        text: text,
        onStart: onStart,
        onComplete: onComplete,
        onWordBoundary: onWordBoundary,
      );
    }
  }

  void _startSimulatedWordTicker(Function(int, String)? onWordBoundary) {
    _simulatedTicker?.cancel();
    if (_words.isEmpty) return;

    int currentIdx = _currentWordIndexNotifier.value < 0
        ? 0
        : _currentWordIndexNotifier.value;

    const interval = Duration(milliseconds: 360);
    _simulatedTicker = Timer.periodic(interval, (timer) {
      if (_status != NarrationStatus.playing) {
        timer.cancel();
        return;
      }
      if (currentIdx < _words.length) {
        _currentWordIndexNotifier.value = currentIdx;
        final charIndex = _wordCharStarts.isNotEmpty && currentIdx < _wordCharStarts.length
            ? _wordCharStarts[currentIdx]
            : 0;
        _currentCharIndexNotifier.value = charIndex;
        onWordBoundary?.call(charIndex, _words[currentIdx]);
        currentIdx++;
      } else {
        timer.cancel();
      }
    });
  }

  void _startSimulatedPlayback({
    required String text,
    VoidCallback? onStart,
    VoidCallback? onComplete,
    Function(int, String)? onWordBoundary,
  }) {
    _setStatus(NarrationStatus.playing);
    AudioManager().startNarrationDucking();
    onStart?.call();

    int currentIdx = 0;
    const interval = Duration(milliseconds: 360);
    _simulatedTicker?.cancel();
    _simulatedTicker = Timer.periodic(interval, (timer) {
      if (_status != NarrationStatus.playing) {
        timer.cancel();
        return;
      }
      if (currentIdx < _words.length) {
        _currentWordIndexNotifier.value = currentIdx;
        final charIndex = _wordCharStarts.isNotEmpty && currentIdx < _wordCharStarts.length
            ? _wordCharStarts[currentIdx]
            : 0;
        _currentCharIndexNotifier.value = charIndex;
        onWordBoundary?.call(charIndex, _words[currentIdx]);
        currentIdx++;
      } else {
        timer.cancel();
        AudioManager().stopNarrationDucking();
        _setStatus(NarrationStatus.idle);
        onComplete?.call();
      }
    });
  }

  @override
  void pause() {
    _simulatedTicker?.cancel();
    try {
      _flutterTts?.pause();
    } catch (_) {}
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
    _simulatedTicker?.cancel();
    try {
      _flutterTts?.stop();
    } catch (_) {}
    AudioManager().stopNarrationDucking();
    _currentWordIndexNotifier.value = -1;
    _currentCharIndexNotifier.value = -1;
    _setStatus(NarrationStatus.idle);
  }
}
