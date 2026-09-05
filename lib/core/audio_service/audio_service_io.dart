import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'audio_service.dart';

AudioService createAudioService() => IoAudioService();

class IoAudioService implements AudioService {
  static const int _poolSize = 4;
  final List<AudioPlayer> _pool = [];
  int _currentIndex = 0;
  bool _initialized = false;
  final AudioCache _cache = AudioCache(prefix: 'assets/');

  static final AudioContext _audioContext = AudioContext(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: const {
        AVAudioSessionOptions.mixWithOthers,
        AVAudioSessionOptions.duckOthers,
      },
    ),
  );

  void _init() {
    if (_initialized) return;
    _initialized = true;

    try {
      AudioPlayer.global.setAudioContext(_audioContext).catchError((err) {
        if (kDebugMode) {
          print('⚠️ [IoAudioService] Global audio context warning: $err');
        }
      });

      for (int i = 0; i < _poolSize; i++) {
        final player = AudioPlayer();
        player.audioCache = _cache;
        player.setAudioContext(_audioContext).catchError((_) {});
        player.setReleaseMode(ReleaseMode.stop).catchError((_) {});
        _pool.add(player);
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [IoAudioService] Audio initialization warning: $e');
      }
    }
  }

  @override
  void playSound(String sfxName, {double? volume}) {
    if (!_initialized || _pool.isEmpty) {
      _init();
    }

    final targetVolume = (volume ?? 1.0).clamp(0.0, 1.0);

    if (_pool.isEmpty) {
      _playOnDemand(sfxName, targetVolume);
      return;
    }

    try {
      final player = _pool[_currentIndex];
      _currentIndex = (_currentIndex + 1) % _pool.length;

      final source = AssetSource('audio/$sfxName.wav');
      player.play(
        source,
        volume: targetVolume,
      ).catchError((err) {
        if (kDebugMode) {
          print('⚠️ [IoAudioService] Pool playback error for $sfxName: $err');
        }
        _playOnDemand(sfxName, targetVolume);
      });
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [IoAudioService] Error triggering sound $sfxName: $e');
      }
      _playOnDemand(sfxName, targetVolume);
    }
  }

  void _playOnDemand(String sfxName, double volume) {
    try {
      final player = AudioPlayer();
      player.audioCache = _cache;
      player.setAudioContext(_audioContext).catchError((_) {});
      player.setReleaseMode(ReleaseMode.release).catchError((_) {});

      player.play(
        AssetSource('audio/$sfxName.wav'),
        volume: volume,
      ).then((_) {
        player.onPlayerComplete.first.then((_) {
          player.dispose().catchError((_) {});
        }).catchError((_) {});
      }).catchError((err) {
        if (kDebugMode) {
          print('⚠️ [IoAudioService] On-demand play warning for $sfxName: $err');
        }
        player.dispose().catchError((_) {});
      });
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [IoAudioService] Failed to create on-demand player: $e');
      }
    }
  }

  @override
  Future<void> preloadAll(List<String> sfxNames) async {
    _init();
    try {
      for (final sfx in sfxNames) {
        try {
          await _cache.load('audio/$sfx.wav');
        } catch (err) {
          if (kDebugMode) {
            print('⚠️ [IoAudioService] Preload warning for $sfx: $err');
          }
        }
      }
      if (kDebugMode) {
        print('🎵 [IoAudioService] Preloaded ${sfxNames.length} sound assets.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [IoAudioService] Preload warning: $e');
      }
    }
  }
}
