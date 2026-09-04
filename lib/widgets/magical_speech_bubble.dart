import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Bubble tail direction
enum BubbleTailDirection { left, right, bottom, none }

/// Premium Glowing Magical Speech & Text Bubble with Typewriter effect,
/// entrance animation, shimmer sweep, and animated sparkle particles.
class MagicalSpeechBubble extends StatefulWidget {
  final String text;
  final String? speaker;
  final String? avatar;
  final bool isLeft;
  final bool isNarrating;
  final BubbleTailDirection tailDirection;
  final double maxWidth;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;
  final bool animatePulse;
  final bool enableTypewriter;
  final Duration typewriterCharDelay;

  const MagicalSpeechBubble({
    super.key,
    required this.text,
    this.speaker,
    this.avatar,
    this.isLeft = true,
    this.isNarrating = false,
    this.tailDirection = BubbleTailDirection.left,
    this.maxWidth = 340,
    this.fontSize = 15.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.trailing,
    this.animatePulse = false,
    this.enableTypewriter = false,
    this.typewriterCharDelay = const Duration(milliseconds: 30),
  });

  @override
  State<MagicalSpeechBubble> createState() => _MagicalSpeechBubbleState();
}

class _MagicalSpeechBubbleState extends State<MagicalSpeechBubble>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _entranceController;
  late AnimationController _shimmerController;

  // Typewriter state
  int _typewriterCharCount = 0;
  bool _typewriterComplete = false;

  @override
  void initState() {
    super.initState();

    // Pulse glow animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    if (widget.animatePulse) {
      _pulseController.repeat(reverse: true);
    }

    // Entrance pop-in animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    // Shimmer sweep animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    // Delay shimmer slightly after entrance
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _shimmerController.forward();
    });

    // Typewriter effect
    if (widget.enableTypewriter && widget.text.isNotEmpty) {
      _startTypewriter();
    } else {
      _typewriterCharCount = widget.text.length;
      _typewriterComplete = true;
    }
  }

  void _startTypewriter() {
    _typewriterCharCount = 0;
    _typewriterComplete = false;
    _advanceTypewriter();
  }

  void _advanceTypewriter() {
    if (!mounted || _typewriterComplete) return;
    if (_typewriterCharCount >= widget.text.length) {
      setState(() => _typewriterComplete = true);
      return;
    }

    Future.delayed(widget.typewriterCharDelay, () {
      if (!mounted) return;
      setState(() {
        _typewriterCharCount++;
      });
      _advanceTypewriter();
    });
  }

  void _skipTypewriter() {
    setState(() {
      _typewriterCharCount = widget.text.length;
      _typewriterComplete = true;
    });
  }

  @override
  void didUpdateWidget(covariant MagicalSpeechBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animatePulse != oldWidget.animatePulse) {
      if (widget.animatePulse) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.value = 0.0;
      }
    }
    // Reset typewriter if text changes
    if (widget.text != oldWidget.text) {
      if (widget.enableTypewriter) {
        _startTypewriter();
      } else {
        _typewriterCharCount = widget.text.length;
        _typewriterComplete = true;
      }
      // Re-run entrance + shimmer
      _entranceController.forward(from: 0.0);
      _shimmerController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entranceController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _entranceController, _shimmerController]),
      builder: (context, child) {
        final pulse = widget.animatePulse
            ? (math.sin(_pulseController.value * math.pi) * 0.4 + 0.6)
            : 0.8;

        // Entrance animation values
        final entranceT = CurvedAnimation(
          parent: _entranceController,
          curve: Curves.elasticOut,
        ).value;
        final entranceScale = 0.8 + (0.2 * entranceT).clamp(0.0, 0.2);
        final entranceOpacity = _entranceController.value.clamp(0.0, 1.0);

        return GestureDetector(
          onTap: widget.enableTypewriter && !_typewriterComplete
              ? _skipTypewriter
              : null,
          child: Opacity(
            opacity: entranceOpacity,
            child: Transform.scale(
              scale: entranceScale,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment:
                    widget.isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isLeft && widget.avatar != null) ...[
                    _buildAvatar(pulse),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: widget.maxWidth),
                      decoration: BoxDecoration(
                        borderRadius: _getBorderRadius(),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: widget.isNarrating
                              ? const [
                                  Color(0xFFFFFDF5),
                                  Color(0xFFFFF7E2),
                                  Color(0xFFFFECB3),
                                ]
                              : const [
                                  Color(0xFFFFFFFF),
                                  Color(0xFFFFFDF7),
                                  Color(0xFFFFF9E6),
                                ],
                        ),
                        border: Border.all(
                          color: widget.isNarrating
                              ? const Color(0xFFFFB300)
                              : const Color(0xFFFFD54F),
                          width: 2.0,
                        ),
                        boxShadow: [
                          // Outer golden magical halo glow
                          BoxShadow(
                            color: const Color(0xFFFFB300).withOpacity(0.35 * pulse),
                            blurRadius: 16,
                            spreadRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                          // Inner ambient glow
                          BoxShadow(
                            color: const Color(0xFFFFE082).withOpacity(0.45 * pulse),
                            blurRadius: 6,
                            spreadRadius: 0.5,
                          ),
                          // Drop ground shadow
                          BoxShadow(
                            color: Colors.brown.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: _getBorderRadius(),
                        child: Stack(
                          children: [
                            // Shimmer sweep overlay
                            if (_shimmerController.value > 0 && _shimmerController.value < 1.0)
                              Positioned.fill(
                                child: _buildShimmerSweep(),
                              ),

                            // Animated sparkle particles in corner
                            Positioned(
                              top: 3,
                              right: 6,
                              child: _AnimatedSparkle(pulse: pulse),
                            ),

                            // Bubble Content
                            Padding(
                              padding: widget.padding,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.speaker != null &&
                                      widget.speaker!.isNotEmpty) ...[
                                    _buildSpeakerTag(pulse),
                                    const SizedBox(height: 5),
                                  ],
                                  // Magical Typography Text (with typewriter)
                                  _buildTextContent(),
                                  if (widget.trailing != null) ...[
                                    const SizedBox(height: 6),
                                    widget.trailing!,
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!widget.isLeft && widget.avatar != null) ...[
                    const SizedBox(width: 8),
                    _buildAvatar(pulse),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextContent() {
    final displayText = widget.enableTypewriter
        ? widget.text.substring(0, _typewriterCharCount)
        : widget.text;

    return RichText(
      text: TextSpan(
        text: displayText,
        style: TextStyle(
          fontSize: widget.fontSize,
          height: 1.42,
          fontWeight: FontWeight.w700,
          fontFamily: 'serif',
          fontFamilyFallback: const [
            'NotoSerifDevanagari',
            'NotoSansDevanagari',
          ],
          color: const Color(0xFF2C1810), // Deep royal ink
          shadows: const [
            Shadow(
              color: Color(0x33FFD54F),
              offset: Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
        children: [
          // Blinking cursor while typing
          if (widget.enableTypewriter && !_typewriterComplete)
            WidgetSpan(
              child: _BlinkingCursor(),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerSweep() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, _) {
          final shimmerPos = _shimmerController.value;
          return ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment(-1.0 + 3.0 * shimmerPos, 0),
                end: Alignment(-0.5 + 3.0 * shimmerPos, 0),
                colors: const [
                  Colors.transparent,
                  Color(0x33FFD54F),
                  Colors.transparent,
                ],
              ).createShader(rect);
            },
            blendMode: BlendMode.srcATop,
            child: Container(
              color: const Color(0x22FFD54F),
            ),
          );
        },
      ),
    );
  }

  BorderRadius _getBorderRadius() {
    switch (widget.tailDirection) {
      case BubbleTailDirection.left:
        return const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(22),
        );
      case BubbleTailDirection.right:
        return const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(4),
        );
      case BubbleTailDirection.bottom:
        return const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        );
      case BubbleTailDirection.none:
        return BorderRadius.circular(22);
    }
  }

  Widget _buildSpeakerTag(double pulse) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: widget.isLeft
              ? const [Color(0xFF5D1A5E), Color(0xFF380E39)] // Royal purple
              : const [Color(0xFF00897B), Color(0xFF004D40)], // Peacock teal
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.isLeft ? const Color(0xFF5D1A5E) : const Color(0xFF00897B))
                .withOpacity(0.35),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '✨',
            style: TextStyle(fontSize: 10 * pulse),
          ),
          const SizedBox(width: 4),
          Text(
            widget.speaker!,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: Color(0xFFFFE082),
              fontFamily: 'serif',
              fontFamilyFallback: [
                'NotoSerifDevanagari',
                'NotoSansDevanagari',
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(double pulse) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFFFFFDF5),
            Color(0xFFFFECB3),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFFD54F),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withOpacity(0.40 * pulse),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.avatar ?? '✨',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

/// Animated sparkle particles drawn with CustomPainter
class _AnimatedSparkle extends StatefulWidget {
  final double pulse;
  const _AnimatedSparkle({required this.pulse});

  @override
  State<_AnimatedSparkle> createState() => _AnimatedSparkleState();
}

class _AnimatedSparkleState extends State<_AnimatedSparkle>
    with SingleTickerProviderStateMixin {
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(18, 18),
          painter: _SparklePainter(
            time: _sparkleController.value,
            pulse: widget.pulse,
          ),
        );
      },
    );
  }
}

class _SparklePainter extends CustomPainter {
  final double time;
  final double pulse;

  _SparklePainter({required this.time, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Color.fromRGBO(255, 179, 0, 0.7 * pulse)
      ..style = PaintingStyle.fill;

    // Draw 4 rotating micro-stars
    for (int i = 0; i < 4; i++) {
      final angle = (time * math.pi * 2) + (i * math.pi / 2);
      final radius = 5.0 + math.sin(time * math.pi * 2 + i) * 2.0;
      final starX = center.dx + math.cos(angle) * radius;
      final starY = center.dy + math.sin(angle) * radius;
      final starSize = 1.5 + math.sin(time * math.pi * 4 + i * 1.5) * 0.8;

      canvas.drawCircle(Offset(starX, starY), starSize, paint);
    }

    // Central bright point
    canvas.drawCircle(
      center,
      1.2 + math.sin(time * math.pi * 6) * 0.6,
      Paint()
        ..color = Color.fromRGBO(255, 213, 79, 0.85 * pulse)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) =>
      time != oldDelegate.time || pulse != oldDelegate.pulse;
}

/// Blinking cursor widget for typewriter effect
class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, _) {
        return Opacity(
          opacity: _blinkController.value,
          child: const Text(
            '▌',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFFFB300),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}


/// Compact Glowing Magical Bubble for in-game characters & floating prompts
/// (e.g. "👈 Drag Timo 👉", "Zzz... 😴", "Steady! 🌟")
class MagicalFloatingBubble extends StatelessWidget {
  final String text;
  final String? icon;
  final Color? glowColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const MagicalFloatingBubble({
    super.key,
    required this.text,
    this.icon,
    this.glowColor,
    this.fontSize = 12.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
  });

  @override
  Widget build(BuildContext context) {
    final glow = glowColor ?? const Color(0xFFFFB300);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFDF5),
            Color(0xFFFFF6DD),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFFD54F),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: glow.withOpacity(0.45),
            blurRadius: 12,
            spreadRadius: 1.5,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Text(icon!, style: TextStyle(fontSize: fontSize + 2)),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              fontFamily: 'serif',
              fontFamilyFallback: const [
                'NotoSerifDevanagari',
                'NotoSansDevanagari',
              ],
              color: const Color(0xFF2C1810),
              shadows: const [
                Shadow(
                  color: Color(0x33FFD54F),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            '✨',
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

/// Enchanted Instructions Quest Banner for Mini Games
class MagicalHintBanner extends StatelessWidget {
  final String instructions;

  const MagicalHintBanner({
    super.key,
    required this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFFFDF5),
            Color(0xFFFFF8E7),
            Color(0xFFFFECB3),
            Color(0xFFFFFDF5),
          ],
        ),
        border: const Border.symmetric(
          horizontal: BorderSide(
            color: Color(0xFFFFD54F),
            width: 1.6,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withOpacity(0.22),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFD54F).withOpacity(0.35),
            ),
            child: const Text('✨', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              instructions,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                fontFamily: 'serif',
                fontFamilyFallback: [
                  'NotoSerifDevanagari',
                  'NotoSansDevanagari',
                ],
                color: Color(0xFF3E2723),
                shadows: [
                  Shadow(
                    color: Color(0x33FFD54F),
                    offset: Offset(0, 1),
                    blurRadius: 2,
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
