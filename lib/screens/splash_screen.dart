import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/audio_manager.dart';
import 'main_shell_screen.dart';
import 'splash/painters/living_world_painter.dart';
import 'splash/painters/constellation_painter.dart';
import 'splash/painters/golden_particle_system.dart';
import 'splash/widgets/book_light_beam_widget.dart';
import 'splash/widgets/closed_book_widget.dart';
import 'splash/widgets/magical_sky_veil_widget.dart';
import 'splash/widgets/celestial_character_widget.dart';
import 'splash/widgets/splash_title_overlay.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _masterController;
  late AnimationController _loopController;

  bool _hasTriggeredChime = false;
  bool _hasTriggeredFanfare = false;
  bool _hasTransitioned = false;

  @override
  void initState() {
    super.initState();

    // 1. Master Timeline Controller (9.5 seconds)
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9500),
    );

    // 2. Continuous Loop Controller for idle breathing, fireflies, and hovering
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    // Track milestones for audio synchronization
    _masterController.addListener(_onTimelineUpdate);
    _masterController.addStatusListener(_onTimelineStatus);

    // Start cinematic sequence
    _masterController.forward();
  }

  void _onTimelineUpdate() {
    final t = _masterController.value;

    // Trigger book awakening chime at ~2.2s (t ≈ 0.23)
    if (t >= 0.23 && !_hasTriggeredChime) {
      _hasTriggeredChime = true;
      AudioManager().playStar();
    }

    // Trigger magical fanfare as Flying Lion and characters align at ~6.5s (t ≈ 0.68)
    if (t >= 0.68 && !_hasTriggeredFanfare) {
      _hasTriggeredFanfare = true;
      AudioManager().playFanfare();
    }
  }

  void _onTimelineStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // Auto-transition to home screen once sequence completes
      _beginJourney();
    }
  }

  @override
  void dispose() {
    _masterController.removeListener(_onTimelineUpdate);
    _masterController.removeStatusListener(_onTimelineStatus);
    _masterController.dispose();
    _loopController.dispose();
    super.dispose();
  }

  void _beginJourney() {
    if (_hasTransitioned || !mounted) return;
    _hasTransitioned = true;

    AudioManager().playTap();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 900),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _beginJourney, // Tap anywhere to begin immediately
        child: AnimatedBuilder(
          animation: Listenable.merge([_masterController, _loopController]),
          builder: (context, child) {
            final masterT = _masterController.value;
            final loopT = _loopController.value;
            final continuousTime = (loopT * 4.0) + (masterT * 9.5);

            // Phase 1: Fade In from Black (0.0 to 0.15)
            final fadeInOpacity = (masterT / 0.15).clamp(0.0, 1.0);

            // Phase 1 to 5: Camera Slow Zoom (3-5% zoom from 1.0 to 1.045)
            final cameraZoom = 1.0 + (0.045 * Curves.easeOutQuad.transform(masterT));

            // Phase 2: Living World Progress (active from 0.05 onwards)
            final livingWorldProgress = ((masterT - 0.05) / 0.95).clamp(0.0, 1.0);

            // Phase 3: Book Awakening & Light Beam (starts at ~2.0s -> masterT: 0.21)
            final bookProgress = ((masterT - 0.21) / 0.45).clamp(0.0, 1.0);

            // Phase 4: Spiral Particles (starts at ~2.8s -> masterT: 0.29)
            final spiralProgress = ((masterT - 0.29) / 0.45).clamp(0.0, 1.0);

            // Phase 4: Constellations Traced (starts at ~3.2s -> masterT: 0.33)
            final constellationProgress = ((masterT - 0.33) / 0.45).clamp(0.0, 1.0);

            // Phase 4: Character Apparitions Sequence (starts at ~4.2s -> masterT: 0.44)
            final charactersProgress = ((masterT - 0.44) / 0.45).clamp(0.0, 1.0);

            // Phase 5: Title & Tap Prompt (starts at ~7.2s -> masterT: 0.75)
            final titleProgress = ((masterT - 0.75) / 0.25).clamp(0.0, 1.0);

            return Opacity(
              opacity: fadeInOpacity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. CAMERA-ZOOMED BACKGROUND HERO ARTWORK
                  Transform.scale(
                    scale: cameraZoom,
                    child: Image.asset(
                      'assets/images/splash_hero_art.jpg',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),

                  // 2. MAGICAL SKY VEIL (Shrouds characters in evening twilight until they materialize)
                  MagicalSkyVeilWidget(
                    revealProgress: charactersProgress,
                    pulseTime: continuousTime,
                  ),

                  // 3. CLOSED SACRED SCRIPTURE BOOK (Shakes and opens into glowing pages)
                  ClosedBookWidget(
                    progress: bookProgress,
                    pulseTime: continuousTime,
                  ),

                  // 4. LIVING WORLD LAYER: Stars, Lanterns, Fountain, Fireflies
                  CustomPaint(
                    painter: LivingWorldPainter(
                      animationValue: loopT,
                      worldProgress: livingWorldProgress,
                    ),
                  ),

                  // 5. BOOK LIGHT BEAM & RADIAL GOD-RAYS (Awakening Phase)
                  BookLightBeamWidget(
                    awakeningProgress: bookProgress,
                    pulseTime: continuousTime,
                  ),

                  // 6. ASCENDING GOLDEN HELICAL SPIRAL PARTICLES
                  CustomPaint(
                    painter: GoldenParticleSystem(
                      progress: spiralProgress,
                      time: continuousTime,
                    ),
                  ),

                  // 7. CONSTELLATION STAR LINES IN THE SKY
                  CustomPaint(
                    painter: ConstellationPainter(
                      progress: constellationProgress,
                    ),
                  ),

                  // 8. CELESTIAL STORY CHARACTERS APPARITIONS
                  // (Lord Ram, Sita, Royal King, Flying Winged Lion with Flapping Wings)
                  CelestialCharactersWidget(
                    charactersProgress: charactersProgress,
                    hoverTime: continuousTime,
                  ),

                  // 7. CINEMATIC VIGNETTE OVERLAY GRADIENT
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.50),
                            Colors.transparent,
                            Colors.black.withOpacity(0.65),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // 8. FINAL SCENE: "कथाQuest" TITLE & "Tap Anywhere to Begin"
                  SplashTitleOverlay(
                    progress: titleProgress,
                    pulseTime: continuousTime,
                    onBeginTap: _beginJourney,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
