import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/audio_manager.dart';
import '../core/haptic_feedback_helper.dart';
import '../state/game_state.dart';
import '../widgets/tactile_pill_button.dart';
import 'main_shell_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController(text: 'Aarav');
  int _currentPage = 0;

  // Selected companion
  String _selectedEmoji = '🐢';
  String _selectedAsset = 'assets/spritesheets/turtle.png';
  String _selectedCompanionName = 'Timo the Tortoise';

  // Mascot interaction state
  bool _mascotTapped = false;
  String _mascotSpeech = '';
  late AnimationController _mascotAnimController;

  // Tutorial interactive practice state
  bool _tutorialPracticed = false;

  final List<Map<String, String>> _companions = [
    {
      'name': 'Timo the Tortoise',
      'emoji': '🐢',
      'asset': 'assets/spritesheets/turtle.png',
      'trait': 'Patient & Wise',
      'desc': 'Slow and steady, always thoughtful!',
    },
    {
      'name': 'Shona the Hare',
      'emoji': '🐇',
      'asset': 'assets/spritesheets/rabbit.png',
      'trait': 'Swift & Spirited',
      'desc': 'Brimming with energy and speed!',
    },
    {
      'name': 'Veer the Elephant',
      'emoji': '🐘',
      'asset': 'assets/spritesheets/elephant_mascot.png',
      'trait': 'Strong & Gentle',
      'desc': 'Loyal protector of ancient lore!',
    },
    {
      'name': 'Young Prince Rama',
      'emoji': '🏹',
      'asset': 'assets/images/young_rama_mascot.jpg',
      'trait': 'Noble & True',
      'desc': 'Follows the path of righteous dharma!',
    },
  ];

  final List<String> _suggestedNames = [
    'Aarav',
    'Ananya',
    'Rohan',
    'Meera',
    'Diya',
    'Kabir',
  ];

  @override
  void initState() {
    super.initState();
    _mascotAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _mascotAnimController.dispose();
    super.dispose();
  }

  void _nextPage() {
    AudioManager().playTap();
    HapticHelper.light();
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    final name = _nameController.text.trim().isEmpty ? 'Explorer' : _nameController.text.trim();
    final gameState = Provider.of<GameState>(context, listen: false);

    gameState.completeOnboarding(
      playerName: name,
      avatarEmoji: _selectedEmoji,
      avatarAsset: _selectedAsset,
    );

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, anim1, anim2) => const MainShellScreen(),
        transitionsBuilder: (context, anim1, anim2, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8EE),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar / Step Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('✨', style: TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'KathaQuest',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                          fontFamily: 'serif',
                        ),
                      ),
                    ],
                  ),
                  // Step Indicator Dots (5 steps)
                  Row(
                    children: List.generate(5, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.primary : const Color(0xFFEADBBE),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Page Content Carousel
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildWelcomeSlide(),      // 1. Onboarding Welcome
                  _buildNameSlide(),         // 2. Player Name
                  _buildCompanionSlide(),    // 3. Avatar Selection
                  _buildMascotIntroSlide(),  // 4. Mascot Introduction
                  _buildTutorialSlide(),     // 5. Tutorial
                ],
              ),
            ),

            // Bottom Navigation Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        AudioManager().playTap();
                        HapticHelper.light();
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMedium,
                        ),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: 170,
                    child: TactilePillButton(
                      text: _currentPage == 4 ? 'Enter Realm 🚀' : 'Next →',
                      height: 48,
                      fontSize: 16,
                      variant: TactilePillVariant.gold,
                      onTap: _nextPage,
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

  // 1. Onboarding Welcome Slide
  Widget _buildWelcomeSlide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF3D6), Color(0xFFFFE082)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB703).withOpacity(0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Text('📜✨', style: TextStyle(fontSize: 54)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Welcome to KathaQuest!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Step into an enchanted realm of ancient mythology, moral tales, interactive comics, and arcade quests!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.textMedium,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),

          // 3 Feature Highlight Cards
          _buildFeatureBadge(
            icon: '📖',
            title: 'Interactive Comics',
            desc: 'Tap characters to hear them talk, swipe to turn pages.',
          ),
          const SizedBox(height: 10),
          _buildFeatureBadge(
            icon: '🎮',
            title: 'Action Mini-Games',
            desc: 'Dodge brambles, run with steady pacing, and sprint for the ribbon.',
          ),
          const SizedBox(height: 10),
          _buildFeatureBadge(
            icon: '🏆',
            title: 'Stars, Coins & Bazaar',
            desc: 'Answer quizzes, unlock royal badges, and customize your adventurer.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge({
    required String icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEADBBE), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Player Name Slide
  Widget _buildNameSlide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3D6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB703).withOpacity(0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Text('👋', style: TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Namaste, Explorer!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'What should we call you on your epic mythological journey?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.textMedium,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          // Name Input Box
          Container(
            decoration: AppTheme.ornateParchmentDecoration(
              backgroundColor: Colors.white,
              radius: 20,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              maxLength: 18,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
                letterSpacing: 0.5,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                hintText: 'Enter your name',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 20),

          // Suggested names chips
          const Text(
            'Or choose a popular name:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _suggestedNames.map((name) {
              final isSelected = _nameController.text.trim() == name;
              return InkWell(
                onTap: () {
                  AudioManager().playTap();
                  HapticHelper.light();
                  setState(() {
                    _nameController.text = name;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : const Color(0xFFEADBBE),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 3. Companion Avatar Selection Slide
  Widget _buildCompanionSlide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          const Text(
            'Choose Your Avatar',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Who will accompany you through the sacred forests and ancient kingdoms?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textMedium,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // 2x2 Companion Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _companions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final comp = _companions[index];
              final isSelected = _selectedCompanionName == comp['name'];

              return GestureDetector(
                onTap: () {
                  AudioManager().playTap();
                  HapticHelper.light();
                  setState(() {
                    _selectedCompanionName = comp['name']!;
                    _selectedEmoji = comp['emoji']!;
                    _selectedAsset = comp['asset']!;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFF6DF) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppTheme.gold : const Color(0xFFEADBBE),
                      width: isSelected ? 2.5 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFFFFB703).withOpacity(0.25)
                            : Colors.black.withOpacity(0.04),
                        blurRadius: isSelected ? 12 : 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(comp['emoji']!, style: const TextStyle(fontSize: 42)),
                      const SizedBox(height: 8),
                      Text(
                        comp['name']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comp['trait']!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 4. Mascot Introduction Slide
  Widget _buildMascotIntroSlide() {
    final name = _nameController.text.trim().isEmpty ? 'Explorer' : _nameController.text.trim();
    final defaultSpeech = 'Namaste, $name! I am Prince Rama, your mythical guide. I will accompany you across every tale and trial. Tap me to say hello!';
    final speechToShow = _mascotTapped ? _mascotSpeech : defaultSpeech;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Meet Your Royal Mascot Guide',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your wise mentor who celebrates your victories and shares ancient virtues!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: AppTheme.textMedium,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          // Speech bubble from Rama
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFFFFDF5), Color(0xFFFFF8E7)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFD54F), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('👑 ', style: TextStyle(fontSize: 16)),
                    Text(
                      'Prince Rama says:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFB78103),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  speechToShow,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Interactive Animated Mascot
          GestureDetector(
            onTap: () {
              AudioManager().playStar();
              HapticHelper.medium();
              setState(() {
                _mascotTapped = true;
                _mascotSpeech = 'May truth and valor guide your steps, $name! 🌟🏹 Let us now learn how to conquer quests!';
              });
            },
            child: AnimatedBuilder(
              animation: _mascotAnimController,
              builder: (context, child) {
                final dy = 6.0 * (1.0 - _mascotAnimController.value);
                return Transform.translate(
                  offset: Offset(0, dy),
                  child: child,
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Halo Glow
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFFD54F).withOpacity(0.45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Mascot Avatar
                  Container(
                    width: 130,
                    height: 165,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/young_rama_mascot.jpg'),
                        fit: BoxFit.contain,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  ),

                  // "Tap Me" badge
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9F1C),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('👆 ', style: TextStyle(fontSize: 12)),
                          Text(
                            'Tap Me!',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Interactive Tutorial Slide
  Widget _buildTutorialSlide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          const Text(
            'How KathaQuest Works (Tutorial)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Every journey combines moral stories, mini-games, and educational quizzes!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: AppTheme.textMedium,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          // Tutorial Step 1: Comics
          _buildTutorialCard(
            stepNumber: '1',
            icon: '📖',
            title: 'Interactive Comics',
            desc: 'Swipe left & right to turn pages! Tap characters to hear them speak.',
            interactiveWidget: InkWell(
              onTap: () {
                AudioManager().playStar();
                HapticHelper.light();
                setState(() => _tutorialPracticed = true);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _tutorialPracticed ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3D6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _tutorialPracticed ? const Color(0xFF4CAF50) : const Color(0xFFFFB703),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_tutorialPracticed ? '🐢 Timo: "Slow and steady wins!" 🌟' : '👉 Try it: Tap Timo 🐢'),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tutorial Step 2: Mini-Games
          _buildTutorialCard(
            stepNumber: '2',
            icon: '🎮',
            title: 'Arcade Mini-Games',
            desc: 'Dodge brambles, stay in the steady running zone, and sprint for the ribbon to guide heroes forward!',
          ),
          const SizedBox(height: 12),

          // Tutorial Step 3: Quizzes & Rewards
          _buildTutorialCard(
            stepNumber: '3',
            icon: '🏆',
            title: 'Quizzes & Bazaar',
            desc: 'Answer comprehension quizzes to collect 3 Stars, Coins, and unlock Royal Titles and Badges in your Bazaar!',
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialCard({
    required String stepNumber,
    required String icon,
    required String title,
    required String desc,
    Widget? interactiveWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEADBBE), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Step $stepNumber',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.textMedium,
                    height: 1.35,
                  ),
                ),
                if (interactiveWidget != null) interactiveWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
