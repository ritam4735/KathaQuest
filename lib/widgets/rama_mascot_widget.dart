import 'package:flutter/material.dart';

class RamaMascotWidget extends StatefulWidget {
  final int xpReward;
  final int coinsReward;

  const RamaMascotWidget({
    super.key,
    this.xpReward = 50,
    this.coinsReward = 10,
  });

  @override
  State<RamaMascotWidget> createState() => _RamaMascotWidgetState();
}

class _RamaMascotWidgetState extends State<RamaMascotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Reward Speech Bubble popping above Rama's shoulder
        Positioned(
          top: -20,
          left: -80,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFFFFDF5),
                  Color(0xFFFFF6DD),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFD54F), width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withOpacity(0.35),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFF00C853), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+${widget.xpReward} XP',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '+${widget.coinsReward} Coins',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFB78103),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Young Rama Mascot Image
        AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final dy = 4.0 * (1.0 - _animController.value);
            return Transform.translate(
              offset: Offset(0, dy),
              child: child,
            );
          },
          child: Container(
            width: 140,
            height: 180,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/young_rama_mascot.jpg'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
