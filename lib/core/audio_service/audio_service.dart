import 'audio_service_stub.dart'
    if (dart.library.html) 'audio_service_web.dart'
    if (dart.library.io) 'audio_service_io.dart';

abstract class AudioService {
  static AudioService? _instance;
  static AudioService get instance => _instance ??= createAudioService();

  void playSound(String sfxName, {double? volume});

  /// Preload all sound files into memory for instant playback.
  Future<void> preloadAll(List<String> sfxNames) async {}
}
