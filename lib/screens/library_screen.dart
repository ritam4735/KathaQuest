import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/models/story_model.dart';
import '../data/sample_stories.dart';
import '../state/game_state.dart';
import 'story_screen.dart';
import 'parent_corner_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  void _openStory(BuildContext context, GameState gameState, Story story) {
    gameState.startStory(story);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const StoryScreen()),
    );
  }

  void _openParentCorner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ParentCornerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final isHindi = gameState.isHindi;
    final stories = SampleStories.getAllStories();
    final profile = gameState.profile;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF9),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Player Avatar & Name
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(profile.avatarEmoji, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.playerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        isHindi ? 'कहानी खोजी' : 'Story Explorer',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Total Stars Pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9E6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFD166), width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB703),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${profile.totalStars}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Language Toggle Button
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.translate_rounded,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                    onPressed: () => gameState.toggleLanguage(),
                  ),

                  // Parent Corner Icon
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Text('👨‍👩‍👧', style: TextStyle(fontSize: 18)),
                    ),
                    onPressed: () => _openParentCorner(context),
                  ),
                ],
              ),
            ),

            // Welcome Section Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppTheme.peacockGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2EC4B6).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isHindi
                                ? 'जादुई कहानियों का संसार! ✨'
                                : 'Magical Katha Library! ✨',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isHindi
                                ? 'अपनी पसंदीदा कहानी चुनें और खेलें!'
                                : 'Choose a story quest to read, play, and learn!',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text('📚🌟', style: TextStyle(fontSize: 38)),
                  ],
                ),
              ),
            ),

            // Story Shelf List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  final story = stories[index];
                  final isUnlocked = index <= 1; // Hare & Tortoise and Rama's Exile are unlocked!
                  final starsEarned = profile.storyStars[story.id] ?? 0;
                  final title =
                      isHindi ? story.titleRegional : story.titleEn;
                  final synopsis =
                      isHindi ? story.synopsisRegional : story.synopsisEn;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      decoration: AppTheme.kidCardDecoration(
                        color: Colors.white,
                        borderColor: isUnlocked
                            ? AppTheme.primary
                            : Colors.grey.shade300,
                        radius: 24,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cover Image Box
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                width: 85,
                                height: 95,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF9E6),
                                  border: Border.all(
                                    color: isUnlocked
                                        ? AppTheme.saffron
                                        : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                child: Image.asset(
                                  story.id == 'story_hare_tortoise'
                                      ? 'assets/images/backgrounds_for_hare_tortoise_story/1.png'
                                      : story.id == 'story_rama_exile'
                                          ? 'assets/images/story_rama_exile.jpg'
                                          : story.id == 'story_panchatantra'
                                              ? 'assets/images/story_panchatantra.jpg'
                                              : 'assets/images/story_vikram_betaal.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Story Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                      ),
                                      if (isUnlocked && starsEarned > 0)
                                        Row(
                                          children: List.generate(
                                            3,
                                            (i) => Icon(
                                              i < starsEarned
                                                  ? Icons.star_rounded
                                                  : Icons.star_outline_rounded,
                                              size: 16,
                                              color: const Color(0xFFFFB703),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    synopsis,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textLight,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Action Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '⏱️ ${story.estimatedMinutes} mins  •  Age ${story.targetAgeMin}-${story.targetAgeMax}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textLight,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (isUnlocked)
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primary,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed: () => _openStory(
                                              context, gameState, story),
                                          child: Text(
                                            starsEarned > 0
                                                ? (isHindi ? 'फिर खेलें' : 'Replay')
                                                : (isHindi ? 'शुरू करें!' : 'Play!'),
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: Text(
                                            isHindi ? 'जल्द आ रहा है' : 'Coming Soon',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
