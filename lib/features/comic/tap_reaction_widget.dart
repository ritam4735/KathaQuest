import 'package:flutter/material.dart';
import '../../core/models/story_model.dart';
import '../../core/audio_manager.dart';
import '../../core/app_theme.dart';
import '../../widgets/animated_sprite_widget.dart';
import '../../widgets/magical_speech_bubble.dart';

class TapReactionWidget extends StatefulWidget {
  final ComicCharacterTarget target;

  const TapReactionWidget({
    super.key,
    required this.target,
  });

  @override
  State<TapReactionWidget> createState() => _TapReactionWidgetState();
}

class _TapReactionWidgetState extends State<TapReactionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showBubble = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    AudioManager().playSfx(widget.target.soundEffect);
    _controller.forward(from: 0.0);
    setState(() {
      _showBubble = true;
    });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showBubble = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSprite = widget.target.spriteAnimation != null &&
        widget.target.spriteAnimation!.isNotEmpty;

    return GestureDetector(
      onTap: _handleTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dynamic glowing pop-up bubble on tap
          AnimatedOpacity(
            opacity: _showBubble ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: MagicalFloatingBubble(
                text: widget.target.speechBubbleOnTap,
              ),
            ),
          ),

          // Animated character sprite / emoji with bounce
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final val = _controller.value;
              final scale = 1.0 + (0.35 * (1 - (val * 2 - 1).abs()).clamp(0.0, 1.0));
              final rotation = 0.15 * (1 - val) * (val > 0.5 ? -1 : 1);

              return Transform.scale(
                scale: scale,
                child: Transform.rotate(
                  angle: rotation,
                  child: hasSprite
                      ? Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.35),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: AnimatedSpriteWidget(
                              animation: widget.target.spriteAnimation!,
                              width: 85,
                              height: 85,
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.secondary.withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.secondary.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.target.emoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: 4),

          // Character name pill with "Tap me!" prompt
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.target.name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.touch_app_rounded,
                  size: 13,
                  color: AppTheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
