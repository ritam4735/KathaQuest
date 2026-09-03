import 'dart:convert';

class UserProfile {
  String playerName;
  String avatarEmoji;
  String avatarAsset;
  int level;
  int currentXp;
  int targetXp;
  int coins;
  int dayStreak;
  int totalStars;
  int storiesCompleted;
  int screenTimeMinutesToday;
  int totalReadingMinutes;
  Map<String, int> storyStars;
  List<String> unlockedBadges;
  bool isBgmEnabled;
  bool isSfxEnabled;
  bool isNarrationEnabled;
  String selectedLanguage; // 'en' or 'hi'
  double narrationSpeed;

  UserProfile({
    this.playerName = 'Aarav',
    this.avatarEmoji = '👧',
    this.avatarAsset = 'assets/images/young_rama_mascot.jpg',
    this.level = 12,
    this.currentXp = 12500,
    this.targetXp = 15000,
    this.coins = 450,
    this.dayStreak = 7,
    this.totalStars = 48,
    this.storiesCompleted = 6,
    this.screenTimeMinutesToday = 15,
    this.totalReadingMinutes = 65,
    Map<String, int>? storyStars,
    List<String>? unlockedBadges,
    this.isBgmEnabled = true,
    this.isSfxEnabled = true,
    this.isNarrationEnabled = true,
    this.selectedLanguage = 'en',
    this.narrationSpeed = 1.0,
  })  : storyStars = storyStars ?? {'story_rama_exile': 3, 'story_hare_tortoise': 3},
        unlockedBadges = unlockedBadges ?? [
          'Story Explorer',
          'Emerald Green',
          'Mythology Master',
          'Saffron Master',
          'Puzzle Solved',
          'Daily Streak',
        ];

  Map<String, dynamic> toMap() {
    return {
      'playerName': playerName,
      'avatarEmoji': avatarEmoji,
      'avatarAsset': avatarAsset,
      'level': level,
      'currentXp': currentXp,
      'targetXp': targetXp,
      'coins': coins,
      'dayStreak': dayStreak,
      'totalStars': totalStars,
      'storiesCompleted': storiesCompleted,
      'screenTimeMinutesToday': screenTimeMinutesToday,
      'totalReadingMinutes': totalReadingMinutes,
      'storyStars': storyStars,
      'unlockedBadges': unlockedBadges,
      'isBgmEnabled': isBgmEnabled,
      'isSfxEnabled': isSfxEnabled,
      'isNarrationEnabled': isNarrationEnabled,
      'selectedLanguage': selectedLanguage,
      'narrationSpeed': narrationSpeed,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      playerName: map['playerName'] ?? 'Aarav',
      avatarEmoji: map['avatarEmoji'] ?? '👧',
      avatarAsset: map['avatarAsset'] ?? 'assets/images/young_rama_mascot.jpg',
      level: map['level'] ?? 12,
      currentXp: map['currentXp'] ?? 12500,
      targetXp: map['targetXp'] ?? 15000,
      coins: map['coins'] ?? 450,
      dayStreak: map['dayStreak'] ?? 7,
      totalStars: map['totalStars'] ?? 48,
      storiesCompleted: map['storiesCompleted'] ?? 6,
      screenTimeMinutesToday: map['screenTimeMinutesToday'] ?? 15,
      totalReadingMinutes: map['totalReadingMinutes'] ?? 65,
      storyStars: Map<String, int>.from(map['storyStars'] ?? {}),
      unlockedBadges: List<String>.from(map['unlockedBadges'] ?? []),
      isBgmEnabled: map['isBgmEnabled'] ?? true,
      isSfxEnabled: map['isSfxEnabled'] ?? true,
      isNarrationEnabled: map['isNarrationEnabled'] ?? true,
      selectedLanguage: map['selectedLanguage'] ?? 'en',
      narrationSpeed: (map['narrationSpeed'] as num?)?.toDouble() ?? 1.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source));
}
