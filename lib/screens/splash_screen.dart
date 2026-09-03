import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/audio_manager.dart';
import '../state/game_state.dart';
import 'main_shell_screen.dart';
import 'splash/layers/hero_background_layer.dart';
import 'splash/layers/cloud_layer.dart';
import 'splash/layers/particle_layer.dart';
import 'splash/layers/butterfly_layer.dart';
import 'splash/layers/bird_layer.dart';
import 'splash/layers/light_glow_layer.dart';
import 'splash/layers/character_stage_layer.dart';
import 'splash/ui/tap_to_begin_overlay.dart';

/// Backward-compatible alias for existing main.dart entry
typedef SplashScreen = HeroSplashScreen;

/// Premium Interactive Hero Splash Animation Screen.
/// Plays multi-stage cinematic animation using separated transparent PNG hero assets,
/// runs background initialization with a glowing progress bar, transitions to an
/// interactive "Tap to Begin" prompt, and continues subtle atmospheric idle loops
/// until the user taps.
class HeroSplashScreen extends StatefulWidget {
  const HeroSplashScreen({super.key});

  @override
  State<HeroSplashScreen> createState() => _HeroSplashScreenState();
}

class _HeroSplashScreenState extends State<HeroSplashScreen>
    with TickerProviderStateMixin {
  // 1. Stage 1 to 3 Master Intro Controller (7.0 seconds total)
  late AnimationController _introController;

  // 2. Stage 4 Continuous Atmospheric Idle Loop Controller (4.0 seconds repeating)
  late AnimationController _idleLoopController;

  // 3. User Tap Feedback & Transition Controller (550ms)
  late AnimationController _tapTransitionController;

  // Loading state & progress tracking
  double _loadingProgress = 0.0;
  bool _isLoaded = false;
  bool _hasTransitioned = false;

  // Sound sync flags
  bool _hasTriggeredBookChime = false;
  bool _hasTriggeredCharacterFanfare = false;

  @override
  void initState() {
    super.initState();

    // 1. Master Intro Timeline
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );

    // 2. Stage 4 Idle Loop Controller
    _idleLoopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    // 3. Tap Feedback Controller
    _tapTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _introController.addListener(_onIntroUpdate);

    // Start cinematic intro sequence
    _introController.forward();

    // Start background asset pre-caching and state initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBackgroundInitialization();
    });
  }

  void _onIntroUpdate() {
    final t = _introController.value;

    // Trigger book awakening audio chime around 2.2s (t ≈ 0.31)
    if (t >= 0.31 && !_hasTriggeredBookChime) {
      _hasTriggeredBookChime = true;
      AudioManager().playStar();
    }

    // Trigger magical fanfare as characters materialize around 5.0s (t ≈ 0.71)
    if (t >= 0.71 && !_hasTriggeredCharacterFanfare) {
      _hasTriggeredCharacterFanfare = true;
      AudioManager().playFanfare();
    }
  }

  /// Asynchronously loads app resources and precaches all 9 hero layers
  Future<void> _startBackgroundInitialization() async {
    final assetsToPrecache = [
      'assets/images/hero_splash/background.png',
      'assets/images/hero_splash/flowers.png',
      'assets/images/hero_splash/kids.png',
      'assets/images/hero_splash/book.png',
      'assets/images/hero_splash/constalations.png',
      'assets/images/hero_splash/char1.png',
      'assets/images/hero_splash/char2.png',
      'assets/images/hero_splash/char3.png',
      'assets/images/hero_splash/char4.png',
    ];

    final totalSteps = assetsToPrecache.length + 2;
    int completedSteps = 0;

    void updateProgress() {
      if (!mounted) return;
      setState(() {
        _loadingProgress = (completedSteps / totalSteps).clamp(0.0, 1.0);
      });
    }

    // Step 1: Wait for GameState to initialize
    try {
      final gameState = Provider.of<GameState>(context, listen: false);
      while (gameState.isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    } catch (_) {}
    completedSteps++;
    updateProgress();

    // Step 2..N: Precache all 9 hero assets
    for (final asset in assetsToPrecache) {
      try {
        await precacheImage(AssetImage(asset), context);
      } catch (_) {}
      completedSteps++;
      updateProgress();
      await Future.delayed(const Duration(milliseconds: 40));
    }

    // Final buffer for smooth visual progress bar fill
    completedSteps++;
    updateProgress();

    if (mounted) {
      setState(() {
        _isLoaded = true;
      });
    }
  }

  /// User interactive tap action
  void _onTapToBegin() {
    if (_hasTransitioned || !_isLoaded) return;
    _hasTransitioned = true;

    // 1. Tactile Audio Feedback
    AudioManager().playTap();

    // 2. Trigger Tap Feedback Transition (light burst, camera push, fade)
    _tapTransitionController.forward().then((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 650),
          pageBuilder: (context, anim1, anim2) => const MainShellScreen(),
          transitionsBuilder: (context, anim1, anim2, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: anim1,
                curve: Curves.easeInOutCubic,
              ),
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _introController.removeListener(_onIntroUpdate);
    _introController.dispose();
    _idleLoopController.dispose();
    _tapTransitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Accessibility: Check if system prefers reduced motion
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _isLoaded ? _onTapToBegin : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _introController,
            _idleLoopController,
            _tapTransitionController,
          ]),
          builder: (context, child) {
            final introT = disableAnimations ? 1.0 : _introController.value;
            final loopT = disableAnimations ? 0.0 : _idleLoopController.value;
            final tapT = _tapTransitionController.value;

            final continuousTime = (loopT * 4.0) + (introT * 7.0);

            // --- STAGE 1: FADE IN FROM BLACK (0.0 to 0.14) ---
            final fadeInOpacity = disableAnimations
                ? 1.0
                : (introT / 0.14).clamp(0.0, 1.0);

            // --- CAMERA ZOOM ---
            // Stage 1 & 2: Zooms smoothly from 1.00 to 1.045
            // Stage 4: Subtle gentle breathing
            // Tap: Snappy push-in zoom to 1.09
            final baseZoom = 1.00 + (0.045 * Curves.easeOutQuad.transform(introT));
            final tapZoom = 0.045 * Curves.easeOutCubic.transform(tapT);
            final cameraZoom = baseZoom + tapZoom;

            // Background Brightening ramp (Stage 1: 0.0 to 0.14)
            final brightness = (0.2 + 0.8 * (introT / 0.14)).clamp(0.2, 1.0);

            // Parallax pan offset (subtle natural sway)
            final parallaxOffset = Offset(
              math.sin(continuousTime * 0.4) * 8.0,
              math.cos(continuousTime * 0.3) * 5.0,
            );

            return Opacity(
              opacity: fadeInOpacity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. HERO BACKGROUND LAYER (Palace, sky, temple pillars, horizon)
                  HeroBackgroundLayer(
                    introProgress: introT,
                    idleTime: continuousTime,
                    cameraZoom: cameraZoom,
                    brightness: brightness,
                    parallaxOffset: parallaxOffset,
                  ),

                  // 2. CLOUD LAYER (Horizontal drifting volumetric clouds)
                  CloudLayer(
                    introProgress: introT,
                    idleTime: continuousTime,
                  ),

                  // 3. BIRD LAYER (Silhouette birds soaring across sky)
                  BirdLayer(
                    introProgress: introT,
                    idleTime: continuousTime,
                  ),

                  // 4. LIGHT GLOW & GOD RAYS LAYER (Constellations, book rays, ambient bloom)
                  LightGlowLayer(
                    introProgress: introT,
                    idleTime: continuousTime,
                  ),

                  // 5. CHARACTER STAGE LAYER (Flowers, kids, scripture book, 4 story deities)
                  CharacterStageLayer(
                    introProgress: introT,
                    idleTime: continuousTime,
                    parallaxOffset: parallaxOffset,
                  ),

                  // 6. BUTTERFLY LAYER (3D fluttering jewel butterflies)
                  ButterflyLayer(
                    introProgress: introT,
                    idleTime: continuousTime,
                  ),

                  // 7. PARTICLE LAYER (Golden stardust, rising book embers, twinkles)
                  ParticleLayer(
                    introProgress: introT,
                    idleTime: continuousTime,
                  ),

                  // 8. TAP TO BEGIN & TITLE OVERLAY (Title, Loading bar -> "Tap to Begin")
                  TapToBeginOverlay(
                    introProgress: introT,
                    idleTime: continuousTime,
                    loadingProgress: _loadingProgress,
                    isLoaded: _isLoaded,
                    onTap: _onTapToBegin,
                  ),

                  // 9. TAP FEEDBACK BURST & TRANSITION FLASH
                  if (tapT > 0)
                    _buildTapFeedbackOverlay(tapT),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Premium visual tap feedback: light burst, sparkles, and radiant fade
  Widget _buildTapFeedbackOverlay(double t) {
    // 0.0 -> 0.3: Rapid golden flash burst
    // 0.3 -> 1.0: Smooth fade to radiant white/theme
    final flashOpacity = (t < 0.35)
        ? (t / 0.35).clamp(0.0, 1.0)
        : (1.0 - (t - 0.35) / 0.65 * 0.25).clamp(0.0, 1.0);

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Radial Golden Flash Burst
          Opacity(
            opacity: (math.sin(t * math.pi) * 0.85).clamp(0.0, 1.0),
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, 0.5),
                  radius: 1.2,
                  colors: [
                    Color(0xEEFFFFFF),
                    Color(0x99FFE082),
                    Color(0x44FFA000),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // Radiant Curtain Fade
          Opacity(
            opacity: flashOpacity * Curves.easeInQuad.transform(t),
            child: Container(
              color: const Color(0xFFFFF8E7), // Royal parchment light
            ),
          ),
        ],
      ),
    );
  }
}
