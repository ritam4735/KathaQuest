import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashTitleOverlay extends StatelessWidget {
  final double progress; // 0.0 to 1.0 (final phase: ~7.5s to 9.5s)
  final double pulseTime;
  final VoidCallback onBeginTap;

  const SplashTitleOverlay({
    super.key,
    required this.progress,
    required this.pulseTime,
    required this.onBeginTap,
  });

  @override
  Widget build(BuildContext context) {
    if (progress <= 0.01) return const SizedBox.shrink();

    // Stagger:
    // Title: 0.0 -> 0.6
    // Subtitle & Tap button: 0.3 -> 1.0
    final titleOpacity = (progress / 0.6).clamp(0.0, 1.0);
    final buttonOpacity = ((progress - 0.3) / 0.7).clamp(0.0, 1.0);

    return Positioned.fill(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Title: कथा Quest
              Opacity(
                opacity: titleOpacity,
                child: Transform.translate(
                  offset: Offset(0, (1.0 - titleOpacity) * -20),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: Column(
                      children: [
                        // कथा
                        Text(
                          'कथा',
                          style: const TextStyle(
                            fontFamily: 'NotoSansDevanagari',
                            fontFamilyFallback: ['NotoSerifDevanagari'],
                            fontSize: 60,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            color: Color(0xFFFFD54F),
                            shadows: [
                              Shadow(
                                color: Color(0xE6380E39),
                                blurRadius: 18,
                                offset: Offset(0, 6),
                              ),
                              Shadow(
                                color: Color(0xFFFFA000),
                                blurRadius: 30,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        // Quest
                        Transform.translate(
                          offset: const Offset(0, -12),
                          child: Text(
                            'Quest',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              color: const Color(0xFFFFECB3),
                              shadows: [
                                Shadow(
                                  color: const Color(0xE6380E39),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Subtitle
                        Text(
                          "Rediscover India's Stories Through Play",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.9,
                            color: Colors.white.withOpacity(0.95),
                            shadows: const [
                              Shadow(
                                color: Colors.black87,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Action: Tap Anywhere to Begin
              Opacity(
                opacity: buttonOpacity,
                child: Transform.translate(
                  offset: Offset(0, (1.0 - buttonOpacity) * 20),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Transform.scale(
                      scale: 1.0 + (0.035 * math.sin(pulseTime * 4)),
                      child: GestureDetector(
                        onTap: onBeginTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          constraints: const BoxConstraints(maxWidth: 290),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFFFB74D),
                                Color(0xFFFF9800),
                                Color(0xFFE65100),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFFFFE082),
                              width: 2.2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x8CFF9800),
                                blurRadius: 20,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('✨', style: TextStyle(fontSize: 18)),
                                SizedBox(width: 8),
                                Text(
                                  'Tap Anywhere to Begin',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    fontFamily: 'serif',
                                    letterSpacing: 0.8,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black45,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('✨', style: TextStyle(fontSize: 18)),
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
      ),
    );
  }
}
