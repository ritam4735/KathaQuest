import 'audio_service.dart';

AudioService createAudioService() => IoAudioService();

class IoAudioService implements AudioService {
  @override
  void playSound(String sfxName) {
    // Non-web fallback
  }
}
