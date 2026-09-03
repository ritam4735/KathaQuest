import 'package:flutter/material.dart';
import 'main_shell_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _beginJourney() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const MainShellScreen(),
        transitionsBuilder: (context, anim1, anim2, child) =>
            FadeTransition(opacity: anim1, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Hero Artwork (Children & Glowing Book)
          Image.asset(
            'assets/images/splash_hero_art.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),

          // Vignette Overlay Gradients
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.transparent,
                  Colors.black.withOpacity(0.65),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // Foreground Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Title: कथा Quest
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Column(
                      children: [
                        // कथा
                        Text(
                          'कथा',
                          style: TextStyle(
                            fontSize: 58,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: const Color(0xFFFFD54F),
                            shadows: [
                              Shadow(
                                color: const Color(0xFF380E39).withOpacity(0.9),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                              const Shadow(
                                color: Color(0xFFFFA000),
                                blurRadius: 28,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        // Quest
                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: Text(
                            'Quest',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                              color: const Color(0xFFFFE082),
                              shadows: [
                                Shadow(
                                  color: const Color(0xFF380E39).withOpacity(0.9),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Subtitle
                        Text(
                          "Rediscover India's Stories Through Play",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
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

                  // Bottom Action Button: Begin Journey with Peacock Feathers
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        final scale = 1.0 + (0.04 * _animController.value);
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: GestureDetector(
                        onTap: _beginJourney,
                        child: Container(
                          height: 64,
                          constraints: const BoxConstraints(maxWidth: 320),
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
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: const Color(0xFFFFE082),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF9800).withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('🪶', style: TextStyle(fontSize: 24)),
                              SizedBox(width: 10),
                              Text(
                                'Begin Journey',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  fontFamily: 'serif',
                                  letterSpacing: 1.0,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('🪶', style: TextStyle(fontSize: 24)),
                            ],
                          ),
                        ),
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
}
