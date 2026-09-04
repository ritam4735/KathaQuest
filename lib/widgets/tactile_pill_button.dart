import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/haptic_feedback_helper.dart';

enum TactilePillVariant {
  parchment,
  gold,
  emerald,
  saffron,
}

class TactilePillButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final TactilePillVariant variant;
  final bool hasCheckmark;
  final Widget? leading;
  final Widget? trailing;
  final double height;
  final double? width;
  final double fontSize;

  const TactilePillButton({
    super.key,
    required this.text,
    required this.onTap,
    this.variant = TactilePillVariant.parchment,
    this.hasCheckmark = false,
    this.leading,
    this.trailing,
    this.height = 56.0,
    this.width,
    this.fontSize = 17.0,
  });

  @override
  State<TactilePillButton> createState() => _TactilePillButtonState();
}

class _TactilePillButtonState extends State<TactilePillButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _shadowAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _pressController.reverse();
    HapticHelper.light();
    widget.onTap();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Gradient gradient;
    Color borderColor;
    Color textColor;
    Color shadowColor;

    switch (widget.variant) {
      case TactilePillVariant.gold:
        gradient = AppTheme.goldPillGradient;
        borderColor = const Color(0xFFFFB300);
        textColor = const Color(0xFF3E2723);
        shadowColor = const Color(0x44FFA000);
        break;
      case TactilePillVariant.emerald:
        gradient = AppTheme.emeraldPillGradient;
        borderColor = const Color(0xFF00C853);
        textColor = Colors.white;
        shadowColor = const Color(0x6600E676);
        break;
      case TactilePillVariant.saffron:
        gradient = AppTheme.saffronPillGradient;
        borderColor = const Color(0xFFF57C00);
        textColor = Colors.white;
        shadowColor = const Color(0x44FF9800);
        break;
      case TactilePillVariant.parchment:
        gradient = AppTheme.parchmentPillGradient;
        borderColor = const Color(0xFFE2D0B0);
        textColor = const Color(0xFF3E2723);
        shadowColor = const Color(0x183E2723);
        break;
    }

    return AnimatedBuilder(
      animation: _pressController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              width: widget.width,
              height: widget.height,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(widget.height / 2),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: (widget.variant == TactilePillVariant.emerald ? 16 : 8) *
                        _shadowAnimation.value,
                    offset: Offset(0, 4 * _shadowAnimation.value),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.7 * _shadowAnimation.value),
                    blurRadius: 0,
                    offset: Offset(0, -1.5 * _shadowAnimation.value),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: widget.width == null ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontFamily: 'serif',
                        fontFamilyFallback: AppTheme.fontFallbacks,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (widget.hasCheckmark) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                  if (widget.trailing != null) ...[
                    const SizedBox(width: 8),
                    widget.trailing!,
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
