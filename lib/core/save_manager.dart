import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/save_data.dart';

class SaveManager {
  static const String _storageKey = 'katha_quest_user_profile_v1';
  static final SaveManager _instance = SaveManager._internal();
  factory SaveManager() => _instance;
  SaveManager._internal();

  UserProfile _cachedProfile = UserProfile();
  bool _isInitialized = false;

  UserProfile get profile => _cachedProfile;

  Future<UserProfile> loadProfile() async {
    if (_isInitialized) return _cachedProfile;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        _cachedProfile = UserProfile.fromMap(json.decode(jsonString));
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

  Future<void> saveProfile(UserProfile profile) async {
    _cachedProfile = profile;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, profile.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('SaveManager saveProfile fallback: $e');
      }
    }
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
  }
}
