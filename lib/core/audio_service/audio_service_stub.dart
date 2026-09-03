import 'audio_service.dart';

AudioService createAudioService() => StubAudioService();

class StubAudioService implements AudioService {
  @override
  void playSound(String sfxName) {
    // No-op in test/stub environment
  }
}
