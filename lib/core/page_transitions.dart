import 'package:flutter/material.dart';

/// A cinematic slide+fade+scale page transition route for KathaQuest.
/// Uses a combined transform: the incoming page slides up slightly,
/// fades in, and scales from 0.92→1.0 for a premium feel.
class MagicalPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  MagicalPageRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.06),
                  end: Offset.zero,
                ).animate(curved),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
                  child: child,
                ),
              ),
            );
          },
        );
}

/// A dramatic curtain-open page transition for story launches.
/// The page scales up from center with a golden radial gradient overlay that fades.
class StoryLaunchPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  StoryLaunchPageRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 650),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuart,
              reverseCurve: Curves.easeInCubic,
            );

            return Stack(
              children: [
                // Page content with scale + fade
                FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
                    ),
                  ),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved),
                    child: child,
                  ),
                ),

                // Golden radial flash overlay (fades out)
                if (animation.value < 0.7)
                  IgnorePointer(
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0.6, end: 0.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
                        ),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 1.4,
                            colors: [
                              Color(0x88FFD54F),
                              Color(0x44FFB300),
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
}

/// A smooth crossfade with subtle vertical slide for tab switches.
class TabCrossFadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  TabCrossFadeRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        );
}
