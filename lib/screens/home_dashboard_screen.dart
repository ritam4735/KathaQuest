import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../data/sample_stories.dart';
import '../state/game_state.dart';
import '../widgets/katha_crest_header.dart';
import '../widgets/tactile_pill_button.dart';
import 'story_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  void _openStory(BuildContext context, GameState gameState, dynamic story) {
    gameState.startStory(story);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const StoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F0DF),
      body: SafeArea(
        child: Column(
          children: [
            // Top Crest Header with Player Avatar, Crest, and Stats
            const KathaCrestHeader(),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  // CONTINUE STORY: RAMA'S EXILE CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.ornateParchmentDecoration(
                      backgroundColor: const Color(0xFFFFFDF7),
                      borderColor: const Color(0xFFEADBBE),
                      radius: 28,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Story Artwork Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/backgrounds_for_hare_tortoise_story/1.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Story Metadata & Play Button
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Featured Quest:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textMedium,
                                  fontFamily: 'serif',
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Hare & Tortoise",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textDark,
                                  fontFamily: 'serif',
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Progress Bar
                              const Text(
                                'Ready to Play! 🐢⚡🐰',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textLight,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: const LinearProgressIndicator(
                                  value: 0.1,
                                  minHeight: 6,
                                  backgroundColor: Color(0xFFEADBBE),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF2EC4B6),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Play Now 3D Button
                              TactilePillButton(
                                text: 'Play Now',
                                height: 42,
                                fontSize: 15,
                                variant: TactilePillVariant.gold,
                                onTap: () => _openStory(
                                  context,
                                  gameState,
                                  SampleStories.hareAndTortoise,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // RECENTLY PLAYED SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recently Played',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                          fontFamily: 'serif',
                        ),
                      ),
                      TextButton(
                        onPressed: () => gameState.setTabIndex(1), // Go to Library
                        child: Row(
                          children: const [
                            Text(
                              'See All',
                              style: TextStyle(
                                color: Color(0xFF8D6E63),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF8D6E63)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Horizontal Story Thumbnails Carousel
                  SizedBox(
                    height: 175,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildStoryCard(
                          title: 'Hare &\nTortoise',
                          imageAsset: 'assets/images/backgrounds_for_hare_tortoise_story/1.png',
                          onTap: () => _openStory(context, gameState, SampleStories.hareAndTortoise),
                        ),
                        _buildStoryCard(
                          title: "Rama's\nExile",
                          imageAsset: 'assets/images/story_rama_exile.jpg',
                          onTap: () => _openStory(context, gameState, SampleStories.ramasExile),
                        ),
                        _buildStoryCard(
                          title: 'Panchatantra\nTales',
                          imageAsset: 'assets/images/story_panchatantra.jpg',
                          onTap: () => _openStory(context, gameState, SampleStories.panchatantraTales),
                        ),
                        _buildStoryCard(
                          title: 'Vikram\nBetaal',
                          imageAsset: 'assets/images/story_vikram_betaal.jpg',
                          onTap: () => _openStory(context, gameState, SampleStories.vikramBetaal),
                        ),
                        _buildStoryCard(
                          title: 'Vikram\nBetaal (Ch 2)',
                          imageAsset: 'assets/images/story_vikram_betaal.jpg',
                          onTap: () => _openStory(context, gameState, SampleStories.vikramBetaal),
                        ),
                        _buildStoryCard(
                          title: 'Panchatantra\nSangraha',
                          imageAsset: 'assets/images/story_panchatantra.jpg',
                          onTap: () => _openStory(context, gameState, SampleStories.panchatantraTales),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // FEATURED STORIES & DAILY QUEST SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Featured Stories',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                          fontFamily: 'serif',
                        ),
                      ),
                      TextButton(
                        onPressed: () => gameState.setTabIndex(1),
                        child: Row(
                          children: const [
                            Text(
                              'See All',
                              style: TextStyle(
                                color: Color(0xFF8D6E63),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF8D6E63)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Daily Quest Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.ornateParchmentDecoration(
                      backgroundColor: const Color(0xFFFFFDF7),
                      borderColor: const Color(0xFFEADBBE),
                      radius: 24,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Daily Quest',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textDark,
                                  fontFamily: 'serif',
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Complete 2 Quizzes',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Get rewards to win 300 coins & XP!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Reward Star Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFECC8),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.stars_rounded, color: Color(0xFFFFA000), size: 24),
                              SizedBox(width: 4),
                              Text(
                                'x30',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: Color(0xFF5D4037),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard({
    required String title,
    required String imageAsset,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 14.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 110,
          padding: const EdgeInsets.all(8),
          decoration: AppTheme.ornateParchmentDecoration(
            backgroundColor: const Color(0xFFFFFDF7),
            borderColor: const Color(0xFFEADBBE),
            radius: 20,
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  imageAsset,
                  width: 94,
                  height: 94,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                      fontFamily: 'serif',
                      height: 1.15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
