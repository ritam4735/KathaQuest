import 'package:flutter/foundation.dart';
import 'audio_service/audio_service.dart';

class AudioManager extends ChangeNotifier {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _isBgmEnabled = true;
  bool _isSfxEnabled = true;
  bool _isNarrationEnabled = true;
  double _narrationSpeed = 1.0;

  bool get isBgmEnabled => _isBgmEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  bool get isNarrationEnabled => _isNarrationEnabled;
  double get narrationSpeed => _narrationSpeed;

  void setBgmEnabled(bool value) {
    _isBgmEnabled = value;
    notifyListeners();
  }

  void setSfxEnabled(bool value) {
    _isSfxEnabled = value;
    notifyListeners();
  }

  void setNarrationEnabled(bool value) {
    _isNarrationEnabled = value;
    notifyListeners();
  }

  void setNarrationSpeed(double speed) {
    _narrationSpeed = speed.clamp(0.5, 2.0);
    notifyListeners();
  }

  // Play named SFX with real Web Audio / AudioElement playback
  void playSfx(String sfxName) {
    if (!_isSfxEnabled) return;

    if (kDebugMode) {
      print('🎵 [SFX] Playing sound effect: $sfxName');
    }

    try {
      AudioService.instance.playSound(sfxName);
    } catch (_) {}
  }

  void playTap() => playSfx('tap_pop');
  void playStar() => playSfx('star_twinkle');
  void playCheer() => playSfx('kids_cheer');
  void playCorrect() => playSfx('quiz_correct');
  void playWrong() => playSfx('quiz_try_again');
  void playFootstep() => playSfx('tortoise_step');
  void playZoom() => playSfx('hare_whoosh');
  void playSnore() => playSfx('hare_snore');
  void playFanfare() => playSfx('victory_fanfare');
}
