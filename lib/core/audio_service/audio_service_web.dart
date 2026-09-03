import 'dart:html' as html;
import 'audio_service.dart';

AudioService createAudioService() => WebAudioService();

class WebAudioService implements AudioService {
  final Map<String, html.AudioElement> _cache = {};

  @override
  void playSound(String sfxName) {
    try {
      final filename = '$sfxName.wav';
      final candidatePaths = [
        'assets/assets/audio/$filename',
        'assets/audio/$filename',
      ];

      _playCandidate(candidatePaths, 0);
    } catch (_) {}
  }

  void _playCandidate(List<String> paths, int index) {
    if (index >= paths.length) return;

    try {
      final path = paths[index];
      // Clone audio or reset currentTime so rapid taps trigger every time
      var audio = _cache[path];
      if (audio == null) {
        audio = html.AudioElement(path);
        audio.volume = 0.85;
        _cache[path] = audio;
      } else {
        audio.currentTime = 0;
      }

      final playPromise = audio.play();
      playPromise.catchError((_) {
        // Fall back to alternate asset path if first path 404s
        _playCandidate(paths, index + 1);
      });
    } catch (_) {
      _playCandidate(paths, index + 1);
    }
  }
}
