import 'package:flutter/material.dart';

class StarRatingBar extends StatefulWidget {
  final int rating; // 0 - 3
  final double starSize;
  final bool animate;

  const StarRatingBar({
    super.key,
    required this.rating,
    this.starSize = 44.0,
    this.animate = true,
  });

  @override
  State<StarRatingBar> createState() => _StarRatingBarState();
}

class _StarRatingBarState extends State<StarRatingBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isFilled = index < widget.rating;
        final delay = index * 0.25;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final effectiveVal = (_controller.value - delay).clamp(0.0, 1.0) / (1.0 - delay);
            final scale = isFilled && widget.animate
                ? (Curves.elasticOut.transform(effectiveVal) * 1.15).clamp(0.0, 1.25)
                : 1.0;

            return Transform.scale(
              scale: scale,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Icon(
                  isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: widget.starSize,
                  color: isFilled
                      ? const Color(0xFFFFB703)
                      : Colors.grey.withOpacity(0.4),
                  shadows: isFilled
                      ? [
                          const Shadow(
                            color: Color(0x66FFB703),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          )
                        ]
                      : null,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
