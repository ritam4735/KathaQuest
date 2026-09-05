import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/page_transitions.dart';
import '../core/models/story_model.dart';
import '../data/sample_stories.dart';
import '../state/game_state.dart';
import 'story_screen.dart';
import 'parent_corner_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  void _openStory(BuildContext context, GameState gameState, Story story, {bool? resume}) {
    final shouldResume = resume ?? gameState.profile.activeStorySteps.containsKey(story.id);
    gameState.startStory(story, resume: shouldResume);
    Navigator.of(context).push(
      StoryLaunchPageRoute(page: const StoryScreen()),
    );
  }

  void _openParentCorner(BuildContext context) {
    Navigator.of(context).push(
      MagicalPageRoute(page: const ParentCornerScreen()),
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
            _buildHeaderBar(gameState, isHindi, profile),

            // Welcome Section Banner with shimmer
            _buildWelcomeBanner(isHindi),

            // Story Shelf List with staggered fade-in
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  final story = stories[index];
                  final bool isUnlocked;
                  if (index <= 1) {
                    isUnlocked = true;
                  } else if (index == 2) {
                    isUnlocked = profile.storyStars.containsKey('story_hare_tortoise') ||
                        profile.storyStars.containsKey('story_rama_exile') ||
                        profile.storiesCompleted >= 1;
                  } else {
                    isUnlocked = profile.storyStars.containsKey('story_panchatantra') ||
                        profile.storiesCompleted >= 2;
                  }
                  final starsEarned = profile.storyStars[story.id] ?? 0;
                  final title = isHindi ? story.titleRegional : story.titleEn;
                  final synopsis = isHindi ? story.synopsisRegional : story.synopsisEn;

                  // Staggered animation per card
                  final start = (index * 0.08).clamp(0.0, 0.7);
                  final end = (start + 0.25).clamp(0.0, 1.0);
                  final animation = CurvedAnimation(
                    parent: _staggerController,
                    curve: Interval(start, end, curve: Curves.easeOutCubic),
                  );

                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: animation.value,
                        child: Transform.translate(
                          offset: Offset(0, 24 * (1.0 - animation.value)),
                          child: child,
                        ),
                      );
                    },
                    child: _buildStoryCard(
                      context: context,
                      gameState: gameState,
                      story: story,
                      isUnlocked: isUnlocked,
                      starsEarned: starsEarned,
                      title: title,
                      synopsis: synopsis,
                      isHindi: isHindi,
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

  Widget _buildHeaderBar(GameState gameState, bool isHindi, dynamic profile) {
    return Padding(
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    );
  }

  Widget _buildWelcomeBanner(bool isHindi) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: _ShimmerContainer(
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
    );
  }

  Widget _buildStoryCard({
    required BuildContext context,
    required GameState gameState,
    required Story story,
    required bool isUnlocked,
    required int starsEarned,
    required String title,
    required String synopsis,
    required bool isHindi,
  }) {
    final hasProgress = gameState.profile.activeStorySteps.containsKey(story.id);
    final currentStep = gameState.profile.activeStorySteps[story.id] ?? 0;
    final currentPanel = gameState.profile.activeStoryPanels[story.id] ?? 0;
    final totalSteps = story.steps.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: AppTheme.kidCardDecoration(
          color: Colors.white,
          borderColor: isUnlocked
              ? (hasProgress ? const Color(0xFF2EC4B6) : AppTheme.primary)
              : Colors.grey.shade300,
          radius: 24,
        ),
        child: Stack(
          children: [
            Padding(
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
                              ? (hasProgress ? const Color(0xFF2EC4B6) : AppTheme.saffron)
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            story.coverImage ?? 'assets/images/splash_hero_art.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFFFFF4E0),
                              child: Center(
                                child: Text(
                                  story.coverEmoji,
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                            ),
                          ),
                          if (hasProgress && isUnlocked)
                            Positioned(
                              bottom: 4,
                              left: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2EC4B6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'RESUME',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        if (hasProgress && isUnlocked) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2F1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF80CBC4), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.play_circle_filled_rounded, size: 12, color: Color(0xFF00796B)),
                                const SizedBox(width: 4),
                                Text(
                                  isHindi
                                      ? 'चरण ${currentStep + 1}/$totalSteps (पैनल ${currentPanel + 1})'
                                      : 'Step ${currentStep + 1}/$totalSteps (Panel ${currentPanel + 1})',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF004D40),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),

                        // Action Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  backgroundColor: hasProgress ? const Color(0xFF2EC4B6) : AppTheme.primary,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => _openStory(context, gameState, story),
                                child: Text(
                                  hasProgress
                                      ? (isHindi ? 'जारी रखें' : 'Resume')
                                      : (starsEarned > 0
                                          ? (isHindi ? 'फिर खेलें' : 'Replay')
                                          : (isHindi ? 'शुरू करें!' : 'Play!')),
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
                                  borderRadius: BorderRadius.circular(14),
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

            // Frosted glass overlay for locked stories
            if (!isUnlocked)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isHindi
                              ? 'इस कहानी को अनलॉक करने के लिए पिछली कहानी पूरी करें!'
                              : 'Complete earlier stories with at least 1 star to unlock this quest!',
                        ),
                        backgroundColor: const Color(0xFF5D4037),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                      child: Container(
                        color: Colors.white.withOpacity(0.35),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_rounded,
                                    color: Colors.grey.shade600, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  isHindi ? 'कहानी लॉक है' : 'Locked Quest',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A shimmer effect that sweeps across the welcome banner periodically
class _ShimmerContainer extends StatefulWidget {
  final Widget child;
  const _ShimmerContainer({required this.child});

  @override
  State<_ShimmerContainer> createState() => _ShimmerContainerState();
}

class _ShimmerContainerState extends State<_ShimmerContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        return ShaderMask(
          shaderCallback: (rect) {
            final pos = _shimmerController.value;
            return LinearGradient(
              begin: Alignment(-1.0 + 3.0 * pos, 0),
              end: Alignment(-0.5 + 3.0 * pos, 0),
              colors: const [
                Colors.white,
                Color(0x44FFFFFF),
                Colors.white,
              ],
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}
