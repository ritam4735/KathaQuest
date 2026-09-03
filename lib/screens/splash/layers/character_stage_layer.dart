import 'dart:math' as math;
import 'package:flutter/material.dart';

/// CharacterStageLayer orchestrates the foreground flowers, kids, glowing book,
/// and the 4 ascending story characters (Lord Rama, Sita, Royal King, Winged Lion).
class CharacterStageLayer extends StatelessWidget {
  final double introProgress; // 0.0 to 1.0 master intro progression
  final double idleTime;      // Continuous idle time in seconds
  final Offset parallaxOffset; // Parallax pan offset

  const CharacterStageLayer({
    super.key,
    required this.introProgress,
    required this.idleTime,
    this.parallaxOffset = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Stage progressions:
        // Flowers & Kids fade in early: 0.05 to 0.30
        final foregroundProgress = ((introProgress - 0.05) / 0.25).clamp(0.0, 1.0);

        // Book awakens with golden glow: 0.20 to 0.60
        final bookProgress = ((introProgress - 0.20) / 0.40).clamp(0.0, 1.0);

        // Celestial Characters apparition sequence (Stage 3): 0.45 to 0.95
        final charSequenceProgress = ((introProgress - 0.45) / 0.50).clamp(0.0, 1.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. CELESTIAL STORY CHARACTERS (Ascending from the sacred scripture)
            if (charSequenceProgress > 0)
              _buildCelestialCharacters(w, h, charSequenceProgress, idleTime),

            // 2. THE SACRED SCRIPTURE BOOK (Glowing core on the pedestal)
            _buildSacredBook(w, h, bookProgress, idleTime),

            // 3. KIDS GAZING AT THE BOOK (Two children sitting in wonder)
            _buildCuriousKids(w, h, foregroundProgress, idleTime),

            // 4. FOREGROUND FLOWERS & BUSHES (Lush bottom framing)
            _buildForegroundFlowers(w, h, foregroundProgress, idleTime),
          ],
        );
      },
    );
  }

  // --- 1. CELESTIAL STORY CHARACTERS ---
  Widget _buildCelestialCharacters(double w, double h, double progress, double time) {
    // Staggered appearances:
    // char4 (Rama): 0.00 -> 0.35
    // char3 (Sita): 0.18 -> 0.55
    // char1 (King): 0.36 -> 0.75
    // char2 (Lion): 0.54 -> 0.95
    final ramaT = ((progress - 0.00) / 0.35).clamp(0.0, 1.0);
    final sitaT = ((progress - 0.18) / 0.37).clamp(0.0, 1.0);
    final kingT = ((progress - 0.36) / 0.39).clamp(0.0, 1.0);
    final lionT = ((progress - 0.54) / 0.41).clamp(0.0, 1.0);

    return RepaintBoundary(
      child: Stack(
        children: [
          // A. Lord Rama with Kodanda Bow (char4.png)
          if (ramaT > 0)
            _buildAscendingHero(
              w: w,
              h: h,
              t: ramaT,
              time: time,
              assetPath: 'assets/images/hero_splash/char4.png',
              targetFractionX: 0.24,
              targetFractionY: 0.36,
              aspectRatio: 176 / 362,
              targetHeight: h * 0.22,
              haloColor: const Color(0xFFFFD54F),
              hoverPhase: 0.0,
            ),

          // B. Princess Sita in Radiant Aura (char3.png)
          if (sitaT > 0)
            _buildAscendingHero(
              w: w,
              h: h,
              t: sitaT,
              time: time,
              assetPath: 'assets/images/hero_splash/char3.png',
              targetFractionX: 0.40,
              targetFractionY: 0.40,
              aspectRatio: 160 / 312,
              targetHeight: h * 0.20,
              haloColor: const Color(0xFFFFE082),
              hoverPhase: 1.5,
            ),

          // C. Royal King in Regal Garb (char1.png)
          if (kingT > 0)
            _buildAscendingHero(
              w: w,
              h: h,
              t: kingT,
              time: time,
              assetPath: 'assets/images/hero_splash/char1.png',
              targetFractionX: 0.58,
              targetFractionY: 0.33,
              aspectRatio: 1027 / 1532,
              targetHeight: h * 0.24,
              haloColor: const Color(0xFFFFB74D),
              hoverPhase: 3.0,
            ),

          // D. Winged Golden Lion Simha (char2.png)
          if (lionT > 0)
            _buildAscendingHero(
              w: w,
              h: h,
              t: lionT,
              time: time,
              assetPath: 'assets/images/hero_splash/char2.png',
              targetFractionX: 0.72,
              targetFractionY: 0.42,
              aspectRatio: 272 / 279,
              targetHeight: h * 0.19,
              haloColor: const Color(0xFFFF8F00),
              hoverPhase: 4.5,
              extraWingTilt: true,
            ),
        ],
      ),
    );
  }

  Widget _buildAscendingHero({
    required double w,
    required double h,
    required double t,
    required double time,
    required String assetPath,
    required double targetFractionX,
    required double targetFractionY,
    required double aspectRatio,
    required double targetHeight,
    required Color haloColor,
    required double hoverPhase,
    bool extraWingTilt = false,
  }) {
    // Book origin
    final originX = w * 0.50;
    final originY = h * 0.74;

    final targetX = w * targetFractionX;
    final targetY = h * targetFractionY;

    // Smooth Bezier rise
    final easeT = Curves.easeOutBack.transform(t);
    final curX = originX + (targetX - originX) * easeT;
    final curY = originY + (targetY - originY) * easeT;

    // Organic hover float
    final hoverY = math.sin(time * 2.2 + hoverPhase) * 6.0;
    final hoverX = math.cos(time * 1.4 + hoverPhase) * 3.0;

    final heroWidth = targetHeight * aspectRatio;
    final pulse = math.sin(time * 3.0 + hoverPhase);

    final tilt = extraWingTilt ? (math.sin(time * 4.0) * 0.05) : 0.0;

    return Positioned(
      left: curX - heroWidth * 0.5 + hoverX,
      top: curY - targetHeight * 0.5 + hoverY,
      width: heroWidth,
      height: targetHeight,
      child: Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(0.35 + (0.65 * easeT))
            ..rotateZ(tilt),
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              // Radiant Divine Aura Behind
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        haloColor.withOpacity(0.55 + 0.15 * pulse),
                        haloColor.withOpacity(0.18),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // Hero PNG Cutout
              Image.asset(
                assetPath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              ),

              // Shimmer Glint
              if (t > 0.8)
                Positioned(
                  top: targetHeight * 0.15,
                  right: heroWidth * 0.20,
                  child: Opacity(
                    opacity: ((pulse + 1.0) * 0.5 * 0.8).clamp(0.0, 1.0),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
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

  // --- 2. SACRED SCRIPTURE BOOK ---
  Widget _buildSacredBook(double w, double h, double progress, double time) {
    if (progress <= 0) return const SizedBox.shrink();

    final bookWidth = math.min(w * 0.55, 340.0);
    final bookHeight = bookWidth * (1141 / 1378);

    // Book sits at center lower-third
    final bookLeft = (w - bookWidth) * 0.50 + (parallaxOffset.dx * 0.25);
    final bookTop = h * 0.64 + (parallaxOffset.dy * 0.25);

    final breathe = math.sin(time * 1.8) * 2.5;
    final easeP = Curves.easeOutCubic.transform(progress);

    return Positioned(
      left: bookLeft,
      top: bookTop + breathe,
      width: bookWidth,
      height: bookHeight,
      child: Opacity(
        opacity: easeP,
        child: Transform.scale(
          scale: 0.85 + (0.15 * easeP),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Under-book golden ground aura
              Positioned(
                bottom: 0,
                left: 10,
                right: 10,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD54F).withOpacity(0.55 * easeP),
                        blurRadius: 28,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),

              // Book PNG Asset
              Image.asset(
                'assets/images/hero_splash/book.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 3. CURIOUS KIDS ---
  Widget _buildCuriousKids(double w, double h, double progress, double time) {
    if (progress <= 0) return const SizedBox.shrink();

    // Kids sitting on left looking toward the book
    final kidsWidth = math.min(w * 0.42, 240.0);
    final kidsHeight = kidsWidth * (394 / 624);

    final kidsLeft = w * 0.08 + (parallaxOffset.dx * 0.35);
    final kidsTop = h * 0.69 + (parallaxOffset.dy * 0.35);

    final breathe = math.sin(time * 1.5 + 0.8) * 2.0;

    return Positioned(
      left: kidsLeft,
      top: kidsTop + breathe,
      width: kidsWidth,
      height: kidsHeight,
      child: Opacity(
        opacity: progress,
        child: Image.asset(
          'assets/images/hero_splash/kids.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }

  // --- 4. FOREGROUND FLOWERS ---
  Widget _buildForegroundFlowers(double w, double h, double progress, double time) {
    if (progress <= 0) return const SizedBox.shrink();

    // Flowers span the bottom width (768:312 aspect ratio)
    final flowersHeight = w * (312 / 768);
    final windSway = math.sin(time * 1.6) * 3.0;

    return Positioned(
      left: -w * 0.04 + windSway + (parallaxOffset.dx * 0.60),
      right: -w * 0.04 - windSway - (parallaxOffset.dx * 0.60),
      bottom: -8 + (parallaxOffset.dy * 0.40),
      height: flowersHeight,
      child: Opacity(
        opacity: progress,
        child: RepaintBoundary(
          child: Image.asset(
            'assets/images/hero_splash/flowers.png',
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}
