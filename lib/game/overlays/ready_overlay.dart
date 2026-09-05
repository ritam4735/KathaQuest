import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../core/katha_flame_game.dart';

/// Pre-game Countdown & Instructions overlay (3... 2... 1... GO!).
class ReadyOverlay extends StatefulWidget {
  final KathaFlameGame game;

  const ReadyOverlay({super.key, required this.game});

  @override
  State<ReadyOverlay> createState() => _ReadyOverlayState();
}

class _ReadyOverlayState extends State<ReadyOverlay> {
  int _countdown = 3;
  Timer? _countdownTimer;
  bool _countingDown = false;

  void _startCountdown() {
    setState(() {
      _countingDown = true;
      _countdown = 3;
    });
    widget.game.audio.playCountdown();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdown > 1) {
        setState(() => _countdown--);
        widget.game.audio.playCountdown();
      } else if (_countdown == 1) {
        timer.cancel();
        setState(() => _countdown = 0); // 0 corresponds to "GO! 🏁"
        widget.game.audio.playStar();
        Timer(const Duration(milliseconds: 650), () {
          if (mounted) {
            widget.game.onReadyDismissed();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.55),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _countingDown
              ? AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Container(
                    key: ValueKey<int>(_countdown),
                    width: _countdown == 0 ? 150 : 130,
                    height: _countdown == 0 ? 150 : 130,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _countdown == 0 ? const Color(0xFF2EC4B6) : const Color(0xFFFFB300),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_countdown == 0 ? const Color(0xFF2EC4B6) : const Color(0xFFFFB300))
                              .withOpacity(0.4),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _countdown == 0 ? 'GO! 🏁' : '$_countdown',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _countdown == 0 ? 36 : 64,
                          fontWeight: FontWeight.w900,
                          color: _countdown == 0 ? const Color(0xFF00897B) : const Color(0xFFE65100),
                          fontFamily: 'serif',
                        ),
                      ),
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppTheme.primary, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge / Icon
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.secondary, width: 2),
                        ),
                        child: const Center(
                          child: Text('🎮', style: TextStyle(fontSize: 34)),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text(
                        widget.game.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                          fontFamily: 'serif',
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        widget.game.instructions,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMedium,
                        ),
                      ),
                      const SizedBox(height: 18),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFD54F)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🎯 Target Score: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(
                              '${widget.game.targetScore} ⭐',
                              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFE65100), fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Ready & Go Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow_rounded, size: 28),
                          label: const Text(
                            'Ready? Let\'s Play!',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            elevation: 6,
                          ),
                          onPressed: _startCountdown,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
