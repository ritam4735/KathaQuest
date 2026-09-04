import 'dart:convert';

class UserProfile {
  static const int currentSaveVersion = 3;

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
  int screenTimeLimitMinutes;
  Map<String, int> storyStars;
  List<String> unlockedBadges;
  List<String> claimedAchievementIds;
  String? lastDailyQuestClaimedDate;
  bool isBgmEnabled;
  bool isSfxEnabled;
  bool isNarrationEnabled;
  String selectedLanguage; // 'en' or 'hi'
  double narrationSpeed;

  // New fields for enhanced data handling
  int saveVersion;
  Map<String, int> lastPlayedAt; // storyId -> epoch milliseconds
  int createdAt; // epoch milliseconds
  int lastModifiedAt; // epoch milliseconds

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
    this.screenTimeLimitMinutes = 30,
    Map<String, int>? storyStars,
    List<String>? unlockedBadges,
    List<String>? claimedAchievementIds,
    this.lastDailyQuestClaimedDate,
    this.isBgmEnabled = true,
    this.isSfxEnabled = true,
    this.isNarrationEnabled = true,
    this.selectedLanguage = 'en',
    this.narrationSpeed = 1.0,
    this.saveVersion = currentSaveVersion,
    Map<String, int>? lastPlayedAt,
    int? createdAt,
    int? lastModifiedAt,
  })  : storyStars = storyStars ?? {'story_rama_exile': 3, 'story_hare_tortoise': 3},
        unlockedBadges = unlockedBadges ?? [
          'Story Explorer',
          'Emerald Green',
          'Mythology Master',
          'Saffron Master',
          'Puzzle Solved',
          'Daily Streak',
        ],
        claimedAchievementIds = claimedAchievementIds ?? [],
        lastPlayedAt = lastPlayedAt ?? {},
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        lastModifiedAt = lastModifiedAt ?? DateTime.now().millisecondsSinceEpoch;

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
      'screenTimeLimitMinutes': screenTimeLimitMinutes,
      'storyStars': storyStars,
      'unlockedBadges': unlockedBadges,
      'claimedAchievementIds': claimedAchievementIds,
      'lastDailyQuestClaimedDate': lastDailyQuestClaimedDate,
      'isBgmEnabled': isBgmEnabled,
      'isSfxEnabled': isSfxEnabled,
      'isNarrationEnabled': isNarrationEnabled,
      'selectedLanguage': selectedLanguage,
      'narrationSpeed': narrationSpeed,
      'saveVersion': saveVersion,
      'lastPlayedAt': lastPlayedAt,
      'createdAt': createdAt,
      'lastModifiedAt': lastModifiedAt,
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
      screenTimeLimitMinutes: map['screenTimeLimitMinutes'] ?? 30,
      storyStars: Map<String, int>.from(map['storyStars'] ?? {}),
      unlockedBadges: List<String>.from(map['unlockedBadges'] ?? []),
      claimedAchievementIds: List<String>.from(map['claimedAchievementIds'] ?? []),
      lastDailyQuestClaimedDate: map['lastDailyQuestClaimedDate'] as String?,
      isBgmEnabled: map['isBgmEnabled'] ?? true,
      isSfxEnabled: map['isSfxEnabled'] ?? true,
      isNarrationEnabled: map['isNarrationEnabled'] ?? true,
      selectedLanguage: map['selectedLanguage'] ?? 'en',
      narrationSpeed: (map['narrationSpeed'] as num?)?.toDouble() ?? 1.0,
      saveVersion: map['saveVersion'] ?? 1,
      lastPlayedAt: Map<String, int>.from(map['lastPlayedAt'] ?? {}),
      createdAt: map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      lastModifiedAt: map['lastModifiedAt'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source));

  /// Record that a story was played right now.
  void recordStoryPlayed(String storyId) {
    lastPlayedAt[storyId] = DateTime.now().millisecondsSinceEpoch;
    lastModifiedAt = DateTime.now().millisecondsSinceEpoch;
  }

  /// Get story IDs sorted by most recently played.
  List<String> getRecentlyPlayedIds() {
    final entries = lastPlayedAt.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.map((e) => e.key).toList();
  }
}
