import 'audio_service.dart';

AudioService createAudioService() => IoAudioService();

class IoAudioService implements AudioService {
  @override
  void playSound(String sfxName) {
    // Non-web fallback
  }

  @override
  Future<void> preloadAll(List<String> sfxNames) async {}
}
