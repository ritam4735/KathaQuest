import 'package:flutter/foundation.dart';
import '../core/models/story_model.dart';
import '../core/models/save_data.dart';
import '../core/database/local_database.dart';
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
  SaveManager get saveManager => _saveManager;
  LocalDatabase get database => _saveManager.database;

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

  /// Get recently played story IDs sorted by most recent.
  List<String> get recentlyPlayedStoryIds => _profile.getRecentlyPlayedIds();

  /// Time-of-day greeting for the dashboard.
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return isHindi ? 'सुप्रभात' : 'Good morning';
    if (hour < 17) return isHindi ? 'नमस्ते' : 'Good afternoon';
    return isHindi ? 'शुभ संध्या' : 'Good evening';
  }

  GameState() {
    _init();
  }

  Future<void> _init() async {
    _profile = await _saveManager.loadProfile();
    _audio.setBgmEnabled(_profile.isBgmEnabled);
    _audio.setSfxEnabled(_profile.isSfxEnabled);
    _audio.setNarrationEnabled(_profile.isNarrationEnabled);
    _audio.setNarrationSpeed(_profile.narrationSpeed);

    // Preload sounds for instant playback
    _audio.preloadAllSounds();

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

  bool _hasFinishedCurrentSession = false;

  void setPlayerName(String name) {
    _profile.playerName = name;
    _saveManager.saveProfile(_profile);
    notifyListeners();
  }

  void updateAvatar({required String emoji, required String asset}) {
    _profile.avatarEmoji = emoji;
    _profile.avatarAsset = asset;
    _saveManager.saveProfile(_profile);
    _audio.playTap();
    notifyListeners();
  }

  void setScreenTimeLimit(int minutes) {
    _profile.screenTimeLimitMinutes = minutes;
    _saveManager.saveProfile(_profile);
    notifyListeners();
  }

  bool claimAchievement(String achievementId, int xpReward, int coinReward) {
    if (_profile.claimedAchievementIds.contains(achievementId)) {
      return false; // Already claimed
    }
    _profile.claimedAchievementIds.add(achievementId);
    _profile.currentXp += xpReward;
    _profile.coins += coinReward;
    if (_profile.currentXp >= _profile.targetXp) {
      _profile.level += 1;
      _profile.currentXp -= _profile.targetXp;
      _profile.targetXp = (_profile.targetXp * 1.25).round();
    }
    _saveManager.saveProfile(_profile);
    _audio.playFanfare();
    notifyListeners();
    return true;
  }

  bool claimDailyQuest() {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (_profile.lastDailyQuestClaimedDate == todayStr) {
      return false; // Already claimed today
    }
    _profile.lastDailyQuestClaimedDate = todayStr;
    _profile.coins += 300;
    _profile.currentXp += 300;
    if (_profile.currentXp >= _profile.targetXp) {
      _profile.level += 1;
      _profile.currentXp -= _profile.targetXp;
      _profile.targetXp = (_profile.targetXp * 1.25).round();
    }
    _saveManager.saveProfile(_profile);
    _audio.playFanfare();
    notifyListeners();
    return true;
  }

  Future<void> resetAllProgress() async {
    await _saveManager.resetAll();
    _profile = _saveManager.profile;
    _currentStory = null;
    _currentStepIndex = 0;
    _isPaused = false;
    _stepRevision = 0;
    _hasFinishedCurrentSession = false;
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
    _hasFinishedCurrentSession = false;

    // Track recently played
    _saveManager.recordStoryPlayed(story.id);

    _audio.playTap();
    notifyListeners();
  }

  void nextStep() {
    if (_currentStory == null) return;
    if (_currentStepIndex < _currentStory!.steps.length - 1) {
      _currentStepIndex++;
      _audio.playPageTurn();
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
    // Persist educational quiz statistics to database
    _saveManager.database.recordQuizStats(
      correct: correctAnswers,
      total: totalQuestions,
    );
    _audio.playFanfare();
    nextStep();
  }

  Future<void> finishStory({required String badge}) async {
    if (_currentStory == null || _hasFinishedCurrentSession) return;
    _hasFinishedCurrentSession = true;
    await _saveManager.recordStoryCompletion(
      storyId: _currentStory!.id,
      stars: _sessionStarsEarned,
      badge: badge,
    );
    _profile = _saveManager.profile;
    notifyListeners();
  }

  int _stepRevision = 0;
  int get stepRevision => _stepRevision;

  void setPaused(bool paused) {
    if (_isPaused != paused) {
      _isPaused = paused;
      notifyListeners();
    }
  }

  void restartCurrentStep() {
    _isPaused = false;
    _stepRevision++;
    _audio.playTap();
    notifyListeners();
  }

  void exitStoryToLibrary() {
    _currentStory = null;
    _currentStepIndex = 0;
    _isPaused = false;
    _stepRevision = 0;
    _hasFinishedCurrentSession = false;
    _audio.playTap();
    notifyListeners();
  }
}
