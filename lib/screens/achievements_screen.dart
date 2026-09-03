import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../state/game_state.dart';
import '../widgets/achievement_medallion.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final List<AchievementItem> _achievements = [
    const AchievementItem(
      id: 'story_explorer',
      title: 'Story Explorer',
      iconEmoji: '🦚',
      primaryColor: Color(0xFF0288D1),
      secondaryColor: Color(0xFF29B6F6),
      currentProgress: 20,
      targetProgress: 10,
      xpReward: 500,
      coinReward: 50,
      unlockedSkinName: 'Ancient Scroll Skin',
    ),
    const AchievementItem(
      id: 'emerald_green',
      title: 'Emerald Green',
      iconEmoji: '🦚',
      primaryColor: Color(0xFF00897B),
      secondaryColor: Color(0xFF4DB6AC),
      currentProgress: 50,
      targetProgress: 10,
      xpReward: 600,
      coinReward: 60,
      unlockedSkinName: 'Peacock Feather Banner',
    ),
    const AchievementItem(
      id: 'mythology_master',
      title: 'Mythology Master',
      iconEmoji: '🏹',
      primaryColor: Color(0xFFD84315),
      secondaryColor: Color(0xFFFF8A65),
      currentProgress: 20,
      targetProgress: 10,
      xpReward: 750,
      coinReward: 75,
      unlockedSkinName: 'Golden Bow Emblem',
    ),
    const AchievementItem(
      id: 'saffron_master',
      title: 'Saffron Master',
      iconEmoji: '🕉️',
      primaryColor: Color(0xFFE65100),
      secondaryColor: Color(0xFFFFB74D),
      currentProgress: 20,
      targetProgress: 10,
      xpReward: 800,
      coinReward: 80,
      unlockedSkinName: 'Royal Saffron Robe',
    ),
    const AchievementItem(
      id: 'puzzle_solved_gold',
      title: 'Puzzle Solved',
      iconEmoji: '❓',
      primaryColor: Color(0xFFF57F17),
      secondaryColor: Color(0xFFFFF176),
      currentProgress: 30,
      targetProgress: 10,
      xpReward: 400,
      coinReward: 40,
      unlockedSkinName: 'Riddle Master Avatar',
    ),
    const AchievementItem(
      id: 'puzzle_solved_cyan',
      title: 'Puzzle Solved',
      iconEmoji: '🧩',
      primaryColor: Color(0xFF0097A7),
      secondaryColor: Color(0xFF80DEEA),
      currentProgress: 30,
      targetProgress: 10,
      xpReward: 450,
      coinReward: 45,
      unlockedSkinName: 'Mandala Solver Skin',
    ),
    const AchievementItem(
      id: 'daily_streak',
      title: 'Daily Streak',
      iconEmoji: '🪷',
      primaryColor: Color(0xFFC2185B),
      secondaryColor: Color(0xFFF48FB1),
      currentProgress: 30,
      targetProgress: 10,
      xpReward: 900,
      coinReward: 100,
      unlockedSkinName: 'Sacred Lotus Frame',
    ),
    const AchievementItem(
      id: 'ruby_red',
      title: 'Ruby Red',
      iconEmoji: '🔥',
      primaryColor: Color(0xFFB71C1C),
      secondaryColor: Color(0xFFEF5350),
      currentProgress: 0,
      targetProgress: 8,
      xpReward: 1000,
      coinReward: 150,
      unlockedSkinName: 'Agni Fire Aura',
    ),
  ];

  late AchievementItem _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = _achievements[0];
  }

  void _claimReward(GameState gameState) {
    gameState.addXp(_selectedItem.xpReward);
    gameState.addCoins(_selectedItem.coinReward);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🎉 Claimed +${_selectedItem.xpReward} XP & +${_selectedItem.coinReward} Coins!',
        ),
        backgroundColor: AppTheme.emerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Temple Pillars Artwork
          Image.asset(
            'assets/images/temple_pillars_bg.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),

          // Dark Temple Atmosphere Overlay
          Container(
            color: Colors.black.withOpacity(0.65),
          ),

          // Main Screen Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Top Header Title (Matching Screenshot 5)
                const Text(
                  'Achievements\nUnlocked',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFE082),
                    fontFamily: 'serif',
                    height: 1.15,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Ornate Gold Divider Flourish
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 50, height: 1.5, color: const Color(0xFFFFD54F)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('✦', style: TextStyle(color: Color(0xFFFFD54F), fontSize: 14)),
                    ),
                    Container(width: 50, height: 1.5, color: const Color(0xFFFFD54F)),
                  ],
                ),

                const SizedBox(height: 16),

                // Grid of 8 Ornate Medallions
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: _achievements.length,
                    itemBuilder: (context, idx) {
                      final item = _achievements[idx];
                      return AchievementMedallionWidget(
                        item: item,
                        isSelected: item.id == _selectedItem.id,
                        onTap: () {
                          setState(() {
                            _selectedItem = item;
                          });
                        },
                      );
                    },
                  ),
                ),

                // SELECTED BADGE REWARD POPOVER CARD (Matching Screenshot 5)
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDF5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5D5B5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Description for ${_selectedItem.title}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                          fontFamily: 'serif',
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Divider Flourish
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 40, height: 1, color: const Color(0xFFD4A310)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.0),
                            child: Text('☸', style: TextStyle(fontSize: 10, color: Color(0xFFD4A310))),
                          ),
                          Container(width: 40, height: 1, color: const Color(0xFFD4A310)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Rewards List
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFF00C853), size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '+${_selectedItem.xpReward} XP',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(
                                '+${_selectedItem.coinReward} Coins',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: Color(0xFFB78103),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Unlocked Skin
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('📜', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            'Unlocked: ${_selectedItem.unlockedSkinName}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Claim Reward Button
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9F1C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () => _claimReward(gameState),
                          child: const Text(
                            'Claim Reward! 🌟',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
