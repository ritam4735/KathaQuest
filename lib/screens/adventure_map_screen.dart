import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../data/sample_stories.dart';
import '../state/game_state.dart';
import 'story_screen.dart';

class AdventureMapScreen extends StatefulWidget {
  const AdventureMapScreen({super.key});

  @override
  State<AdventureMapScreen> createState() => _AdventureMapScreenState();
}

class _AdventureMapScreenState extends State<AdventureMapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _launchChapter(BuildContext context, GameState gameState) {
    final story = gameState.selectedMapChapterId == 'ch_2'
        ? SampleStories.hareAndTortoise
        : SampleStories.ramasExile;
    gameState.startStory(story);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const StoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7EEDB),
      body: SafeArea(
        child: Stack(
          children: [
            // MAP BACKGROUND ARTWORK
            Positioned.fill(
              child: Image.asset(
                'assets/images/ancient_india_map.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),

            // Dotted Trail & Interactive Nodes
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;

                  return Stack(
                    children: [
                      // Top Progress Dots
                      Positioned(
                        top: 14,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            6,
                            (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i == 1 ? Colors.white : Colors.white54,
                                border: Border.all(color: Colors.black38),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // NODE 1: Ch. 1: The Wise Monkey (Unlocked / Complete)
                      Positioned(
                        left: w * 0.32,
                        top: h * 0.16,
                        child: _buildMapNode(
                          nodeIcon: Icons.check_rounded,
                          glowColor: const Color(0xFF00E676),
                          iconColor: Colors.white,
                          nodeColor: const Color(0xFF00C853),
                          chapterTitle: 'Ch. 1:\nThe Wise Monkey',
                          statusText: 'Unlocked',
                          statusColor: const Color(0xFF00C853),
                          onTap: () => _launchChapter(context, gameState),
                        ),
                      ),

                      // NODE 2: Ch. 2: The Demon's Lair (Current Pulsing)
                      Positioned(
                        left: w * 0.48,
                        top: h * 0.36,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final scale = 1.0 + (0.08 * _pulseController.value);
                            return Transform.scale(
                              scale: scale,
                              child: child,
                            );
                          },
                          child: _buildMapNode(
                            nodeIcon: Icons.play_arrow_rounded,
                            glowColor: const Color(0xFFFF9800),
                            iconColor: Colors.white,
                            nodeColor: const Color(0xFFFF9F1C),
                            chapterTitle: "Ch. 2:\nThe Demon's Lair",
                            statusText: 'Current',
                            statusColor: const Color(0xFFFF9F1C),
                            hasTreasureChest: true,
                            onTap: () => _launchChapter(context, gameState),
                          ),
                        ),
                      ),

                      // NODE 3: Ch. 3: The Golden Deer (Locked)
                      Positioned(
                        left: w * 0.42,
                        top: h * 0.58,
                        child: _buildMapNode(
                          nodeIcon: Icons.lock_rounded,
                          glowColor: const Color(0xFFAB47BC),
                          iconColor: Colors.white70,
                          nodeColor: const Color(0xFF7B1FA2),
                          chapterTitle: 'Ch. 3:\nThe Golden Deer',
                          statusText: 'Locked',
                          statusColor: const Color(0xFF7B1FA2),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Complete Chapter 2 to unlock The Golden Deer!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),

                      // BOTTOM FLOATING CHAPTER DOCK (Matching Screenshot 3)
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 16,
                        child: Row(
                          children: [
                            // Current Chapter Card
                            Expanded(
                              flex: 5,
                              child: GestureDetector(
                                onTap: () => _launchChapter(context, gameState),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: AppTheme.ornateParchmentDecoration(
                                    backgroundColor: const Color(0xFFFFFDF5),
                                    borderColor: const Color(0xFFEADBBE),
                                    radius: 22,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Current Chapter',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textDark,
                                          fontFamily: 'serif',
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.asset(
                                              'assets/images/story_rama_exile.jpg',
                                              width: 54,
                                              height: 54,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: const [
                                                Text(
                                                  "Ch. 2: The\nDemon's Lair",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w900,
                                                    color: AppTheme.textDark,
                                                    fontFamily: 'serif',
                                                    height: 1.15,
                                                  ),
                                                ),
                                                SizedBox(height: 3),
                                                Text(
                                                  'Difficulty: ⭐ Current',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.saffronDark,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Available Stories Card
                            Expanded(
                              flex: 5,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: AppTheme.ornateParchmentDecoration(
                                  backgroundColor: const Color(0xFFFFFDF5),
                                  borderColor: const Color(0xFFEADBBE),
                                  radius: 22,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Available Stories',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                        fontFamily: 'serif',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.asset(
                                            'assets/images/backgrounds_for_hare_tortoise_story/1.png',
                                            width: 50,
                                            height: 54,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.asset(
                                            'assets/images/story_panchatantra.jpg',
                                            width: 50,
                                            height: 54,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.asset(
                                            'assets/images/story_vikram_betaal.jpg',
                                            width: 50,
                                            height: 54,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapNode({
    required IconData nodeIcon,
    required Color glowColor,
    required Color iconColor,
    required Color nodeColor,
    required String chapterTitle,
    required String statusText,
    required Color statusColor,
    bool hasTreasureChest = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Speech Bubble Tag Above Node
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEADBBE), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  chapterTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                    fontFamily: 'serif',
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Glowing Node Circle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: nodeColor,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withOpacity(0.6),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(nodeIcon, color: iconColor, size: 26),
              ),
              if (hasTreasureChest) ...[
                const SizedBox(width: 8),
                const Text('🎁', style: TextStyle(fontSize: 22)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
