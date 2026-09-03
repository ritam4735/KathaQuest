import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_theme.dart';

/// Bubble tail direction
enum BubbleTailDirection { left, right, bottom, none }

/// Premium Glowing Magical Speech & Text Bubble
/// Features golden glowing borders, enchanted parchment gradient,
/// mystical font styling with Devanagari serif fallbacks, and corner sparkles.
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
  });

  @override
  State<MagicalSpeechBubble> createState() => _MagicalSpeechBubbleState();
}

class _MagicalSpeechBubbleState extends State<MagicalSpeechBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    if (widget.animatePulse) {
      _pulseController.repeat(reverse: true);
    }
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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = widget.animatePulse
            ? (math.sin(_pulseController.value * math.pi) * 0.4 + 0.6)
            : 0.8;

        return Row(
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
                      // Shimmering Golden Corner Sparkle
                      Positioned(
                        top: 3,
                        right: 6,
                        child: Text(
                          '✦',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFFFFB300).withOpacity(0.85 * pulse),
                            shadows: [
                              Shadow(
                                color: const Color(0xFFFFD54F),
                                blurRadius: 8 * pulse,
                              ),
                            ],
                          ),
                        ),
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
                            // Magical Typography Text
                            Text(
                              widget.text,
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
                            ),
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
        );
      },
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
