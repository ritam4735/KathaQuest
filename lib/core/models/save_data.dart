import 'dart:convert';

class UserProfile {
  static const int currentSaveVersion = 4;

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

  // Mini-Game & Arcade Persistence (v4)
  Map<String, int> miniGameHighScores; // gameId -> high score
  Map<String, int> miniGameStars; // gameId -> stars earned (1-3)
  Map<String, bool> miniGameCompleted; // gameId -> true
  int totalMiniGamePoints;
  List<String> unlockedCollectibles;

  // Onboarding, Active Progress & Bazaar Economy
  bool hasCompletedOnboarding;
  Map<String, int> activeStorySteps; // storyId -> stepIndex
  Map<String, int> activeStoryPanels; // storyId -> panelIndex
  String? lastActiveStoryId; // ID of active in-progress story
  List<String> purchasedItemIds;
  String currentTitle;
  String currentBubbleTheme;

  // Timestamps & versioning
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
    Map<String, int>? miniGameHighScores,
    Map<String, int>? miniGameStars,
    Map<String, bool>? miniGameCompleted,
    this.totalMiniGamePoints = 0,
    List<String>? unlockedCollectibles,
    this.hasCompletedOnboarding = false,
    Map<String, int>? activeStorySteps,
    Map<String, int>? activeStoryPanels,
    this.lastActiveStoryId,
    List<String>? purchasedItemIds,
    this.currentTitle = 'Story Seeker',
    this.currentBubbleTheme = 'classic',
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
        miniGameHighScores = miniGameHighScores ?? {},
        miniGameStars = miniGameStars ?? {},
        miniGameCompleted = miniGameCompleted ?? {},
        unlockedCollectibles = unlockedCollectibles ?? ['golden_star', 'emerald_clover'],
        activeStorySteps = activeStorySteps ?? {},
        activeStoryPanels = activeStoryPanels ?? {},
        purchasedItemIds = purchasedItemIds ?? ['avatar_timo', 'title_seeker', 'bubble_parchment'],
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
      'miniGameHighScores': miniGameHighScores,
      'miniGameStars': miniGameStars,
      'miniGameCompleted': miniGameCompleted,
      'totalMiniGamePoints': totalMiniGamePoints,
      'unlockedCollectibles': unlockedCollectibles,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'activeStorySteps': activeStorySteps,
      'activeStoryPanels': activeStoryPanels,
      'lastActiveStoryId': lastActiveStoryId,
      'purchasedItemIds': purchasedItemIds,
      'currentTitle': currentTitle,
      'currentBubbleTheme': currentBubbleTheme,
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
      miniGameHighScores: Map<String, int>.from(map['miniGameHighScores'] ?? {}),
      miniGameStars: Map<String, int>.from(map['miniGameStars'] ?? {}),
      miniGameCompleted: Map<String, bool>.from(map['miniGameCompleted'] ?? {}),
      totalMiniGamePoints: map['totalMiniGamePoints'] ?? 0,
      unlockedCollectibles: List<String>.from(map['unlockedCollectibles'] ?? ['golden_star', 'emerald_clover']),
      hasCompletedOnboarding: map['hasCompletedOnboarding'] ?? false,
      activeStorySteps: Map<String, int>.from(map['activeStorySteps'] ?? {}),
      activeStoryPanels: Map<String, int>.from(map['activeStoryPanels'] ?? {}),
      lastActiveStoryId: map['lastActiveStoryId'] as String?,
      purchasedItemIds: List<String>.from(map['purchasedItemIds'] ?? ['avatar_timo', 'title_seeker', 'bubble_parchment']),
      currentTitle: map['currentTitle'] ?? 'Story Seeker',
      currentBubbleTheme: map['currentBubbleTheme'] ?? 'classic',
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

  /// Record a mini-game play session result.
  bool recordMiniGameResult({
    required String gameId,
    required int score,
    required int stars,
    int coinsReward = 0,
  }) {
    bool isNewHighScore = false;
    final currentHigh = miniGameHighScores[gameId] ?? 0;
    if (score > currentHigh) {
      miniGameHighScores[gameId] = score;
      isNewHighScore = true;
    }

    final currentStars = miniGameStars[gameId] ?? 0;
    if (stars > currentStars) {
      miniGameStars[gameId] = stars;
      totalStars += (stars - currentStars);
    }

    miniGameCompleted[gameId] = true;
    totalMiniGamePoints += score;
    coins += coinsReward;
    lastModifiedAt = DateTime.now().millisecondsSinceEpoch;
    return isNewHighScore;
  }
}
