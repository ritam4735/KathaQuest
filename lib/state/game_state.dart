import 'package:flutter/foundation.dart';
import '../core/models/story_model.dart';
import '../core/models/save_data.dart';
import '../core/audio_manager.dart';
import '../core/save_manager.dart';

class GameState extends ChangeNotifier {
  final SaveManager _saveManager = SaveManager();
  final AudioManager _audio = AudioManager();

  UserProfile _profile = UserProfile();
  bool _isLoading = true;

  // Active Bottom Navigation Tab (0: Home, 1: Library, 2: Map, 3: Shop, 4: Profile)
  int _currentTabIndex = 0;

  // Active Map Node
  String _selectedMapChapterId = 'ch_2';

  // Active Story Session
  Story? _currentStory;
  int _currentStepIndex = 0;
  int _currentMiniGameScore = 0;
  int _sessionStarsEarned = 3;
  int _quizCorrectCount = 0;
  bool _isPaused = false;

  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;
  int get currentTabIndex => _currentTabIndex;
  String get selectedMapChapterId => _selectedMapChapterId;
  Story? get currentStory => _currentStory;
  int get currentStepIndex => _currentStepIndex;
  int get currentMiniGameScore => _currentMiniGameScore;
  int get sessionStarsEarned => _sessionStarsEarned;
  int get quizCorrectCount => _quizCorrectCount;
  bool get isPaused => _isPaused;

  StoryStep? get currentStep {
    if (_currentStory == null) return null;
    if (_currentStepIndex >= _currentStory!.steps.length) return null;
    return _currentStory!.steps[_currentStepIndex];
  }

  double get storyProgress {
    if (_currentStory == null || _currentStory!.steps.isEmpty) return 0.0;
    return (_currentStepIndex + 1) / _currentStory!.steps.length;
  }

  String get selectedLanguage => _profile.selectedLanguage;
  bool get isHindi => _profile.selectedLanguage == 'hi';

  GameState() {
    _init();
  }

  Future<void> _init() async {
    _profile = await _saveManager.loadProfile();
    _audio.setBgmEnabled(_profile.isBgmEnabled);
    _audio.setSfxEnabled(_profile.isSfxEnabled);
    _audio.setNarrationEnabled(_profile.isNarrationEnabled);
    _audio.setNarrationSpeed(_profile.narrationSpeed);
    _isLoading = false;
    notifyListeners();
  }

  void setTabIndex(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      _audio.playTap();
      notifyListeners();
    }
  }

  void selectMapChapter(String chapterId) {
    _selectedMapChapterId = chapterId;
    _audio.playTap();
    notifyListeners();
  }

  void addXp(int amount) {
    _profile.currentXp += amount;
    if (_profile.currentXp >= _profile.targetXp) {
      _profile.level += 1;
      _profile.currentXp -= _profile.targetXp;
      _profile.targetXp = (_profile.targetXp * 1.25).round();
      _audio.playFanfare();
    }
    _saveManager.saveProfile(_profile);
    notifyListeners();
  }

  void addCoins(int amount) {
    _profile.coins += amount;
    _audio.playStar();
    _saveManager.saveProfile(_profile);
    notifyListeners();
  }

  void toggleLanguage() {
    _profile.selectedLanguage = _profile.selectedLanguage == 'en' ? 'hi' : 'en';
    _saveManager.saveProfile(_profile);
    _audio.playTap();
    notifyListeners();
  }

  void toggleBgm() {
    _profile.isBgmEnabled = !_profile.isBgmEnabled;
    _audio.setBgmEnabled(_profile.isBgmEnabled);
    _saveManager.saveProfile(_profile);
    notifyListeners();
  }

  void toggleSfx() {
    _profile.isSfxEnabled = !_profile.isSfxEnabled;
    _audio.setSfxEnabled(_profile.isSfxEnabled);
    _saveManager.saveProfile(_profile);
    notifyListeners();
  }

  void toggleNarration() {
    _profile.isNarrationEnabled = !_profile.isNarrationEnabled;
    _audio.setNarrationEnabled(_profile.isNarrationEnabled);
    _saveManager.saveProfile(_profile);
    notifyListeners();
  }

  void setNarrationSpeed(double speed) {
    _profile.narrationSpeed = speed;
    _audio.setNarrationSpeed(speed);
    _saveManager.saveProfile(_profile);
    notifyListeners();
  }

  void setPlayerName(String name) {
    _profile.playerName = name;
    _saveManager.saveProfile(_profile);
    notifyListeners();
  }

  // --- Story Session Flow ---
  void startStory(Story story) {
    _currentStory = story;
    _currentStepIndex = 0;
    _currentMiniGameScore = 0;
    _sessionStarsEarned = 3;
    _quizCorrectCount = 0;
    _isPaused = false;
    _audio.playTap();
    notifyListeners();
  }

  void nextStep() {
    if (_currentStory == null) return;
    if (_currentStepIndex < _currentStory!.steps.length - 1) {
      _currentStepIndex++;
      _audio.playTap();
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStepIndex > 0) {
      _currentStepIndex--;
      _audio.playTap();
      notifyListeners();
    }
  }

  void completeMiniGame(int score) {
    _currentMiniGameScore += score;
    addXp(score * 2);
    addCoins((score / 5).round());
    _audio.playCheer();
    nextStep();
  }

  void recordQuizResult({required int correctAnswers, required int totalQuestions}) {
    _quizCorrectCount = correctAnswers;
    if (correctAnswers == totalQuestions) {
      _sessionStarsEarned = 3;
      addXp(150);
      addCoins(30);
    } else if (correctAnswers >= (totalQuestions / 2).ceil()) {
      _sessionStarsEarned = 2;
      addXp(100);
      addCoins(20);
    } else {
      _sessionStarsEarned = 1;
      addXp(50);
      addCoins(10);
    }
    _audio.playFanfare();
    nextStep();
  }

  Future<void> finishStory({required String badge}) async {
    if (_currentStory == null) return;
    await _saveManager.recordStoryCompletion(
      storyId: _currentStory!.id,
      stars: _sessionStarsEarned,
      badge: badge,
    );
    _profile = _saveManager.profile;
    notifyListeners();
  }

  void setPaused(bool paused) {
    _isPaused = paused;
    notifyListeners();
  }

  void exitStoryToLibrary() {
    _currentStory = null;
    _currentStepIndex = 0;
    _isPaused = false;
    _audio.playTap();
    notifyListeners();
  }
}
