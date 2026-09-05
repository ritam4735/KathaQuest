import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/models/story_model.dart';
import '../core/page_transitions.dart';
import '../data/sample_stories.dart';
import '../state/game_state.dart';
import '../widgets/katha_crest_header.dart';
import '../widgets/tactile_pill_button.dart';
import 'story_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  late List<Animation<double>> _staggerAnimations;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Create 4 staggered animations for the main cards
    _staggerAnimations = List.generate(4, (i) {
      final start = i * 0.12;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });

    _glowAnimation = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    );

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  void _openStory(BuildContext context, GameState gameState, dynamic story, {bool? resume}) {
    final shouldResume = resume ?? gameState.profile.activeStorySteps.containsKey(story.id);
    gameState.startStory(story, resume: shouldResume);
    Navigator.of(context).push(
      StoryLaunchPageRoute(page: const StoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final hasActive = gameState.hasActiveStoryInProgress;

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
                  // Greeting Banner
                  _buildStaggered(0, child: _buildGreetingBanner(gameState)),
                  const SizedBox(height: 16),

                  // RESUME ADVENTURE CARD if active story exists!
                  if (hasActive) ...[
                    _buildStaggered(1, child: _buildResumeAdventureCard(gameState)),
                    const SizedBox(height: 20),
                  ],

                  // FEATURED QUEST CARD with pulsing glow
                  _buildStaggered(hasActive ? 2 : 1, child: _buildFeaturedQuestCard(gameState)),
                  const SizedBox(height: 20),

                  // RECENTLY PLAYED SECTION
                  _buildStaggered(hasActive ? 3 : 2, child: _buildRecentlyPlayedSection(gameState)),
                  const SizedBox(height: 20),

                  // DAILY QUEST
                  _buildStaggered(3, child: _buildDailyQuestCard(gameState)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaggered(int index, {required Widget child}) {
    return AnimatedBuilder(
      animation: _staggerAnimations[index],
      builder: (context, _) {
        return Opacity(
          opacity: _staggerAnimations[index].value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1.0 - _staggerAnimations[index].value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildGreetingBanner(GameState gameState) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${gameState.greeting}, ${gameState.profile.playerName}! 👋',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
                fontFamily: 'serif',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeAdventureCard(GameState gameState) {
    final activeId = gameState.lastActiveStoryId;
    if (activeId == null) return const SizedBox.shrink();
    final allStories = SampleStories.getAllStories();
    final match = allStories.where((s) => s.id == activeId);
    if (match.isEmpty) return const SizedBox.shrink();
    final story = match.first;
    final isHindi = gameState.isHindi;
    final title = isHindi ? story.titleRegional : story.titleEn;
    final coverPath = story.coverImage ?? 'assets/images/backgrounds_for_hare_tortoise_story/1.png';
    final stepIndex = gameState.profile.activeStorySteps[story.id] ?? 0;
    final panelIndex = gameState.profile.activeStoryPanels[story.id] ?? 0;
    final totalSteps = story.steps.length;
    final progress = ((stepIndex + 1) / totalSteps).clamp(0.0, 1.0);

    String locationLabel;
    if (stepIndex < story.steps.length) {
      final currentStep = story.steps[stepIndex];
      if (currentStep.type == StoryStepType.comic) {
        final totalPanels = (currentStep as ComicStep).panels.length;
        locationLabel = isHindi
            ? 'चित्रकथा पैनल ${panelIndex + 1}/$totalPanels • चरण ${stepIndex + 1}/$totalSteps'
            : 'Comic Panel ${panelIndex + 1}/$totalPanels • Step ${stepIndex + 1}/$totalSteps';
      } else if (currentStep.type == StoryStepType.miniGame) {
        locationLabel = isHindi
            ? 'मिनी-गेम • चरण ${stepIndex + 1}/$totalSteps'
            : 'Mini Game • Step ${stepIndex + 1}/$totalSteps';
      } else if (currentStep.type == StoryStepType.quiz) {
        locationLabel = isHindi
            ? 'क्विज़ • चरण ${stepIndex + 1}/$totalSteps'
            : 'Quiz • Step ${stepIndex + 1}/$totalSteps';
      } else {
        locationLabel = isHindi
            ? 'इनाम • चरण ${stepIndex + 1}/$totalSteps'
            : 'Reward • Step ${stepIndex + 1}/$totalSteps';
      }
    } else {
      locationLabel = isHindi ? 'चरण ${stepIndex + 1}/$totalSteps' : 'Step ${stepIndex + 1}/$totalSteps';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF2EC4B6), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2EC4B6).withOpacity(0.22),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Tag
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2EC4B6), Color(0xFF0F9F90)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      isHindi ? 'कहानी जारी रखें' : 'RESUME ADVENTURE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}% ${isHindi ? 'पूरा' : 'Complete'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F9F90),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  coverPath,
                  width: 78,
                  height: 78,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    width: 78,
                    height: 78,
                    color: const Color(0xFFEADBBE),
                    child: Center(
                      child: Text(story.coverEmoji, style: const TextStyle(fontSize: 32)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                        fontFamily: 'serif',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      locationLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6D4C41),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: const Color(0xFFEADBBE),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2EC4B6)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TactilePillButton(
            text: isHindi ? 'कहानी जारी रखें ➔' : 'Resume Quest ➔',
            height: 42,
            fontSize: 15,
            variant: TactilePillVariant.emerald,
            onTap: () => _openStory(context, gameState, story, resume: true),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedQuestCard(GameState gameState) {
    final featuredStory = SampleStories.hareAndTortoise;
    final isHindi = gameState.isHindi;
    final title = isHindi ? featuredStory.titleRegional : featuredStory.titleEn;
    final coverPath = featuredStory.coverImage ?? 'assets/images/backgrounds_for_hare_tortoise_story/1.png';
    final hasProgress = gameState.profile.activeStorySteps.containsKey(featuredStory.id);
    final currentStep = gameState.profile.activeStorySteps[featuredStory.id] ?? 0;
    final totalSteps = featuredStory.steps.length;
    final progress = hasProgress ? ((currentStep + 1) / totalSteps).clamp(0.0, 1.0) : 0.1;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB300).withOpacity(
                    0.2 + 0.15 * _glowAnimation.value),
                blurRadius: 16 + 8 * _glowAnimation.value,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Container(
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
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(coverPath),
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
                  Text(
                    isHindi ? 'विशेष खोज:' : 'Featured Quest:',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMedium,
                      fontFamily: 'serif',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                      fontFamily: 'serif',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Progress Bar
                  Text(
                    hasProgress
                        ? (isHindi
                            ? 'प्रगति सहेजी गई! चरण ${currentStep + 1}/$totalSteps'
                            : 'Progress Saved! Step ${currentStep + 1}/$totalSteps')
                        : (isHindi
                            ? 'खेलने के लिए तैयार! ${featuredStory.coverEmoji}'
                            : 'Ready to Play! ${featuredStory.coverEmoji}'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: progress),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFEADBBE),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            hasProgress ? const Color(0xFF2EC4B6) : const Color(0xFFFFB300),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Play Now 3D Button
                  TactilePillButton(
                    text: hasProgress
                        ? (isHindi ? 'जारी रखें' : 'Resume Quest')
                        : (isHindi ? 'शुरू करें' : 'Play Now'),
                    height: 42,
                    fontSize: 15,
                    variant: hasProgress ? TactilePillVariant.emerald : TactilePillVariant.gold,
                    onTap: () => _openStory(
                      context,
                      gameState,
                      featuredStory,
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

  Widget _buildRecentlyPlayedSection(GameState gameState) {
    return Column(
      children: [
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
          height: 180,
          child: Builder(
            builder: (context) {
              final allStories = SampleStories.getAllStories();
              final recentIds = gameState.recentlyPlayedStoryIds;
              final List<dynamic> displayStories = [];
              for (final id in recentIds) {
                final match = allStories.where((s) => s.id == id);
                if (match.isNotEmpty) {
                  displayStories.add(match.first);
                }
              }
              for (final s in allStories) {
                if (!displayStories.contains(s)) {
                  displayStories.add(s);
                }
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: displayStories.length,
                itemBuilder: (context, idx) {
                  final story = displayStories[idx];
                  final title = gameState.isHindi ? story.titleRegional : story.titleEn;
                  String imageAsset;
                  if (story.id == 'story_hare_tortoise') {
                    imageAsset = 'assets/images/backgrounds_for_hare_tortoise_story/1.png';
                  } else if (story.id == 'story_rama_exile') {
                    imageAsset = 'assets/images/story_rama_exile.jpg';
                  } else if (story.id == 'story_panchatantra') {
                    imageAsset = 'assets/images/story_panchatantra.jpg';
                  } else {
                    imageAsset = 'assets/images/story_vikram_betaal.jpg';
                  }
                  final stars = gameState.profile.storyStars[story.id] ?? 0;
                  final hasProgress = gameState.profile.activeStorySteps.containsKey(story.id);

                  return _buildStoryCard(
                    title: title,
                    imageAsset: imageAsset,
                    stars: stars,
                    isInProgress: hasProgress,
                    onTap: () => _openStory(context, gameState, story),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyQuestCard(GameState gameState) {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final isClaimed = gameState.profile.lastDailyQuestClaimedDate == todayStr;
    const targetQuizzes = 2;
    final quizzesDone = gameState.database.analytics.quizzesAttempted;
    final progress = isClaimed ? 1.0 : (quizzesDone / targetQuizzes).clamp(0.0, 1.0);
    final canClaim = !isClaimed && quizzesDone >= targetQuizzes;

    return Container(
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
              children: [
                const Text(
                  'Daily Quest 🎯',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isClaimed
                      ? 'Completed for today! 🎉'
                      : 'Complete $targetQuizzes Quizzes ($quizzesDone/$targetQuizzes)',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isClaimed
                      ? 'You earned +300 Coins & XP!'
                      : 'Reward: +300 Coins & XP',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
                if (canClaim) ...[
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.stars_rounded, size: 16),
                    label: const Text('Claim 300 🪙 & XP!'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9F1C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      final success = gameState.claimDailyQuest();
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎉 Daily Quest Complete! +300 Coins & XP awarded!'),
                            backgroundColor: AppTheme.emerald,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Animated Reward Badge with dynamic progress ring
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 58,
                    height: 58,
                    child: CircularProgressIndicator(
                      value: val,
                      strokeWidth: 4.0,
                      backgroundColor: const Color(0xFFEADBBE),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isClaimed ? const Color(0xFF00C853) : const Color(0xFFFFB300),
                      ),
                    ),
                  ),
                  child!,
                ],
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isClaimed ? const Color(0xFFE8F5E9) : const Color(0xFFFFECC8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isClaimed ? const Color(0xFF81C784) : const Color(0xFFFFD54F),
                  width: 1.5,
                ),
              ),
              child: Icon(
                isClaimed ? Icons.check_circle_rounded : Icons.stars_rounded,
                color: isClaimed ? const Color(0xFF2E7D32) : const Color(0xFFFFA000),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard({
    required String title,
    required String imageAsset,
    required VoidCallback onTap,
    int stars = 0,
    bool isInProgress = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 14.0),
      child: _TapScaleCard(
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
                child: Stack(
                  children: [
                    Image.asset(
                      imageAsset,
                      width: 94,
                      height: 94,
                      fit: BoxFit.cover,
                    ),
                    if (stars > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 12),
                              const SizedBox(width: 2),
                              Text(
                                '$stars',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (isInProgress)
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
              const SizedBox(height: 6),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

/// A small wrapper that scales down to 0.97 on tap-down for tactile story cards
class _TapScaleCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TapScaleCard({required this.child, required this.onTap});

  @override
  State<_TapScaleCard> createState() => _TapScaleCardState();
}

class _TapScaleCardState extends State<_TapScaleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
