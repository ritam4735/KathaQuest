import 'audio_service.dart';

AudioService createAudioService() => StubAudioService();

class StubAudioService implements AudioService {
  @override
  void playSound(String sfxName, {double? volume}) {
    // No-op in test/stub environment
  }

  @override
  Future<void> preloadAll(List<String> soundNames) async {
    // No-op in test/stub environment
  }
}
