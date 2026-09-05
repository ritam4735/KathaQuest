import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database/local_database.dart';
import 'models/save_data.dart';

class SaveManager {
  static const String _storageKey = 'katha_quest_user_profile_v1';
  static const String _backupKey = 'katha_quest_user_profile_backup';
  static final SaveManager _instance = SaveManager._internal();
  factory SaveManager() => _instance;
  SaveManager._internal();

  final LocalDatabase _database = LocalDatabase();
  UserProfile _cachedProfile = UserProfile();
  bool _isInitialized = false;

  // Debounce timer for batching rapid saves
  Timer? _saveDebounceTimer;
  bool _hasPendingSave = false;

  UserProfile get profile => _cachedProfile;
  LocalDatabase get database => _database;

  Future<UserProfile> loadProfile() async {
    if (_isInitialized) return _cachedProfile;

    // Initialize structured local database collections
    await _database.init();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        try {
          _cachedProfile = UserProfile.fromMap(json.decode(jsonString));
          // Migrate if needed
          _migrateIfNeeded(prefs);
        } catch (parseError) {
          // JSON corrupt — back it up and reset
          if (kDebugMode) {
            print('SaveManager: Corrupt save data, backing up and resetting: $parseError');
          }
          await prefs.setString(_backupKey, jsonString);
          _cachedProfile = UserProfile();
          await _writeToPrefs(prefs);
        }
      } else {
        _cachedProfile = UserProfile();
      }
    } catch (e) {
      if (kDebugMode) {
        print('SaveManager: Running in fallback mode without SharedPreferences: $e');
      }
      _cachedProfile = UserProfile();
    }
    _isInitialized = true;
    return _cachedProfile;
  }

  /// Migrate save data from older schema versions.
  void _migrateIfNeeded(SharedPreferences prefs) {
    final version = _cachedProfile.saveVersion;
    if (version < UserProfile.currentSaveVersion) {
      // Migration from v1 → v2: add timestamps
      if (version < 2) {
        _cachedProfile.createdAt = DateTime.now().millisecondsSinceEpoch;
        _cachedProfile.lastModifiedAt = DateTime.now().millisecondsSinceEpoch;
      }
      // Migration from v2 → v3: add claimed achievements and screen time limit
      if (version < 3) {
        _cachedProfile.claimedAchievementIds = [];
        _cachedProfile.screenTimeLimitMinutes = 30;
      }
      // Migration from v3 → v4: add mini-game high scores, stars, and collectibles
      if (version < 4) {
        _cachedProfile.miniGameHighScores = {};
        _cachedProfile.miniGameStars = {};
        _cachedProfile.miniGameCompleted = {};
        _cachedProfile.totalMiniGamePoints = 0;
        _cachedProfile.unlockedCollectibles = ['golden_star', 'emerald_clover'];
      }
      _cachedProfile.saveVersion = UserProfile.currentSaveVersion;
      _writeToPrefs(prefs);
      if (kDebugMode) {
        print('SaveManager: Migrated save data from v$version to v${UserProfile.currentSaveVersion}');
      }
    }
  }

  /// Record mini-game result persistently.
  Future<bool> recordMiniGameScore({
    required String gameId,
    required int score,
    required int stars,
    int coinsReward = 0,
  }) async {
    final isNewHighScore = _cachedProfile.recordMiniGameResult(
      gameId: gameId,
      score: score,
      stars: stars,
      coinsReward: coinsReward,
    );
    await saveProfile(_cachedProfile);
    return isNewHighScore;
  }

  /// Save profile with debouncing — batches rapid calls within 500ms.
  Future<void> saveProfile(UserProfile profile) async {
    _cachedProfile = profile;
    _cachedProfile.lastModifiedAt = DateTime.now().millisecondsSinceEpoch;
    _hasPendingSave = true;

    // Cancel previous debounce timer
    _saveDebounceTimer?.cancel();

    // Schedule a write after 500ms of inactivity
    _saveDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _flushSave();
    });
  }

  /// Force an immediate write, bypassing the debounce.
  Future<void> forceSave() async {
    _saveDebounceTimer?.cancel();
    await _flushSave();
  }

  Future<void> _flushSave() async {
    if (!_hasPendingSave) return;
    _hasPendingSave = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await _writeToPrefs(prefs);
    } catch (e) {
      if (kDebugMode) {
        print('SaveManager saveProfile fallback: $e');
      }
    }
  }

  Future<void> _writeToPrefs(SharedPreferences prefs) async {
    await prefs.setString(_storageKey, _cachedProfile.toJson());
  }

  Future<void> recordStoryCompletion({
    required String storyId,
    required int stars,
    required String badge,
  }) async {
    final currentStars = _cachedProfile.storyStars[storyId] ?? 0;
    if (stars > currentStars) {
      _cachedProfile.storyStars[storyId] = stars;
      _cachedProfile.totalStars += (stars - currentStars);
    }

    if (!_cachedProfile.unlockedBadges.contains(badge)) {
      _cachedProfile.unlockedBadges.add(badge);
    }

    _cachedProfile.storiesCompleted += 1;
    _cachedProfile.totalReadingMinutes += 5;
    _cachedProfile.screenTimeMinutesToday += 5;

    await saveProfile(_cachedProfile);
    await _database.saveStoryProgress(
      storyId: storyId,
      stars: stars,
      badge: badge,
    );
    await _database.recordReadingTime(5);
  }

  /// Record that a story was just played (for "Recently Played").
  void recordStoryPlayed(String storyId) {
    _cachedProfile.recordStoryPlayed(storyId);
    saveProfile(_cachedProfile);
  }

  /// Reset all stored profile and database collections.
  Future<void> resetAll() async {
    _saveDebounceTimer?.cancel();
    _hasPendingSave = false;
    _cachedProfile = UserProfile();
    await _database.resetDatabase();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      await prefs.remove(_backupKey);
    } catch (e) {
      if (kDebugMode) print('SaveManager resetAll error: $e');
    }
  }
}
