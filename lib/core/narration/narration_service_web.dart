import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import '../audio_manager.dart';
import 'narration_service.dart';

NarrationService createNarrationService() => WebNarrationService();

class WebNarrationService implements NarrationService {
  NarrationStatus _status = NarrationStatus.idle;
  final ValueNotifier<NarrationStatus> _statusNotifier =
      ValueNotifier<NarrationStatus>(NarrationStatus.idle);
  final ValueNotifier<int> _currentWordIndexNotifier = ValueNotifier<int>(-1);
  final ValueNotifier<int> _currentCharIndexNotifier = ValueNotifier<int>(-1);

  @override
  NarrationStatus get status => _status;

  @override
  ValueNotifier<NarrationStatus> get statusNotifier => _statusNotifier;

  @override
  ValueNotifier<int> get currentWordIndexNotifier => _currentWordIndexNotifier;

  @override
  ValueNotifier<int> get currentCharIndexNotifier => _currentCharIndexNotifier;

  html.SpeechSynthesisUtterance? _currentUtterance;
  String _lastText = '';
  String _lastLanguage = 'en';
  VoidCallback? _lastOnComplete;
  Function(int, String)? _lastOnWordBoundary;

  Timer? _simulatedTicker;
  List<String> _words = [];
  List<int> _wordCharStarts = [];

  void _setStatus(NarrationStatus newStatus) {
    _status = newStatus;
    _statusNotifier.value = newStatus;
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

    // Prepare word index map for boundary resolution
    _prepareWordIndexMap(text);

    final synth = html.window.speechSynthesis;
    if (synth == null) {
      _startSimulatedPlayback(
        text: text,
        onStart: onStart,
        onComplete: onComplete,
        onWordBoundary: onWordBoundary,
      );
      return;
    }

    try {
      final utterance = html.SpeechSynthesisUtterance(text);
      utterance.lang = language == 'hi' ? 'hi-IN' : 'en-US';
      utterance.rate = 0.88; // Gentle, child-friendly cadence
      utterance.pitch = 1.05; // Friendly, warm tone

      bool hasStarted = false;
      bool hasBoundaryFired = false;

      utterance.onStart.listen((_) {
        hasStarted = true;
        _setStatus(NarrationStatus.playing);
        AudioManager().startNarrationDucking();
        onStart?.call();

        // Safety watchdog: if speech starts but no boundary events fire after 400ms,
        // use smooth simulated word progression so visual highlighting always works
        Timer(const Duration(milliseconds: 400), () {
          if (_status == NarrationStatus.playing && !hasBoundaryFired) {
            _startSimulatedWordTicker(onWordBoundary);
          }
        });
      });

      utterance.addEventListener('boundary', (html.Event event) {
        hasBoundaryFired = true;
        try {
          final dyn = event as dynamic;
          final int charIndex = (dyn.charIndex as num?)?.toInt() ?? 0;
          _currentCharIndexNotifier.value = charIndex;

          final wordIndex = _findWordIndexForChar(charIndex);
          if (wordIndex >= 0 && wordIndex < _words.length) {
            _currentWordIndexNotifier.value = wordIndex;
            onWordBoundary?.call(charIndex, _words[wordIndex]);
          }
        } catch (_) {}
      });

      utterance.onEnd.listen((_) {
        _simulatedTicker?.cancel();
        AudioManager().stopNarrationDucking();
        _currentWordIndexNotifier.value = _words.length; // highlight completed
        _setStatus(NarrationStatus.idle);
        onComplete?.call();
      });

      utterance.onError.listen((_) {
        _simulatedTicker?.cancel();
        AudioManager().stopNarrationDucking();
        _setStatus(NarrationStatus.idle);
        onError?.call();
      });

      utterance.onPause.listen((_) {
        _setStatus(NarrationStatus.paused);
      });

      utterance.onResume.listen((_) {
        _setStatus(NarrationStatus.playing);
      });

      _currentUtterance = utterance;

      // Small delay to allow audio context readiness
      await Future.delayed(const Duration(milliseconds: 60));
      synth.speak(utterance);

      // Web fallback timeout in case browser never fires onStart
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
    } catch (_) {
      _startSimulatedPlayback(
        text: text,
        onStart: onStart,
        onComplete: onComplete,
        onWordBoundary: onWordBoundary,
      );
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
    final synth = html.window.speechSynthesis;
    if (synth != null && synth.speaking == true && synth.paused != true) {
      synth.pause();
    }
    _simulatedTicker?.cancel();
    _setStatus(NarrationStatus.paused);
  }

  @override
  void resume() {
    final synth = html.window.speechSynthesis;
    if (synth != null && synth.paused == true) {
      synth.resume();
      _setStatus(NarrationStatus.playing);
    } else if (_status == NarrationStatus.paused) {
      _setStatus(NarrationStatus.playing);
      _startSimulatedWordTicker(_lastOnWordBoundary);
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
    final synth = html.window.speechSynthesis;
    if (synth != null) {
      synth.cancel();
    }
    AudioManager().stopNarrationDucking();
    _currentUtterance = null;
    _currentWordIndexNotifier.value = -1;
    _currentCharIndexNotifier.value = -1;
    _setStatus(NarrationStatus.idle);
  }
}
