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
  double _masterVolume = 1.0;
  double _sfxVolume = 1.0;
  double _bgmVolume = 0.6;
  double _narrationVolume = 1.0;
  bool _isNarrationPlaying = false;
  bool _isPreloaded = false;

  bool get isBgmEnabled => _isBgmEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  bool get isNarrationEnabled => _isNarrationEnabled;
  double get narrationSpeed => _narrationSpeed;
  double get masterVolume => _masterVolume;
  double get sfxVolume => _sfxVolume;
  double get bgmVolume => _bgmVolume;
  double get narrationVolume => _narrationVolume;
  bool get isPreloaded => _isPreloaded;

  /// All sound file basenames used in the app.
  static const List<String> allSoundFiles = [
    'hare_snore',
    'hare_whoosh',
    'kids_cheer',
    'quiz_correct',
    'quiz_try_again',
    'star_twinkle',
    'tap_pop',
    'tortoise_step',
    'victory_fanfare',
  ];

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

  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setBgmVolume(double volume) {
    _bgmVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setNarrationVolume(double volume) {
    _narrationVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Preload all sound files into memory for instant playback.
  Future<void> preloadAllSounds() async {
    if (_isPreloaded) return;
    try {
      await AudioService.instance.preloadAll(allSoundFiles);
      _isPreloaded = true;
      if (kDebugMode) {
        print('🎵 [AudioManager] All ${allSoundFiles.length} sounds preloaded.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🎵 [AudioManager] Preload failed: $e');
      }
    }
  }

  /// Audio ducking: reduce BGM when narration starts, restore when done.
  void _applyDucking(bool narrationPlaying) {
    _isNarrationPlaying = narrationPlaying;
    // In a full implementation, this would adjust live BGM audio element volume.
    // For now, it tracks state so BGM playback can check it.
  }

  void startNarrationDucking() => _applyDucking(true);
  void stopNarrationDucking() => _applyDucking(false);

  double get effectiveBgmVolume =>
      _masterVolume * _bgmVolume * (_isNarrationPlaying ? 0.3 : 1.0);

  double get effectiveSfxVolume => _masterVolume * _sfxVolume;

  // Play named SFX with real Web Audio / AudioElement / native Mobile playback
  void playSfx(String sfxName) {
    if (!_isSfxEnabled) return;

    if (kDebugMode) {
      print('🎵 [SFX] Playing sound effect: $sfxName (vol: $effectiveSfxVolume)');
    }

    try {
      AudioService.instance.playSound(sfxName, volume: effectiveSfxVolume);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [AudioManager] Failed to play $sfxName: $e');
      }
    }
  }

  // --- Existing convenience methods ---
  void playTap() => playSfx('tap_pop');
  void playStar() => playSfx('star_twinkle');
  void playCheer() => playSfx('kids_cheer');
  void playCorrect() => playSfx('quiz_correct');
  void playWrong() => playSfx('quiz_try_again');
  void playFootstep() => playSfx('tortoise_step');
  void playZoom() => playSfx('hare_whoosh');
  void playSnore() => playSfx('hare_snore');
  void playFanfare() => playSfx('victory_fanfare');

  // --- New convenience methods for enhanced game juice ---
  void playComboHit() => playSfx('star_twinkle'); // reuse star for now
  void playMiss() => playSfx('quiz_try_again');
  void playPageTurn() => playSfx('tap_pop');
  void playCountdown() => playSfx('tap_pop');
  void playBadgeUnlock() => playSfx('victory_fanfare');
}
