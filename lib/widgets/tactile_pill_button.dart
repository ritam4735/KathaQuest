import 'package:flutter/material.dart';
import '../core/app_theme.dart';

enum TactilePillVariant {
  parchment,
  gold,
  emerald,
  saffron,
}

class TactilePillButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    Gradient gradient;
    Color borderColor;
    Color textColor;
    Color shadowColor;

    switch (variant) {
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
      default:
        gradient = AppTheme.parchmentPillGradient;
        borderColor = const Color(0xFFE2D0B0);
        textColor = const Color(0xFF3E2723);
        shadowColor = const Color(0x183E2723);
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: variant == TactilePillVariant.emerald ? 16 : 8,
              offset: const Offset(0, 4),
            ),
            const BoxShadow(
              color: Colors.white70,
              blurRadius: 0,
              offset: Offset(0, -1.5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: width == null ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontFamily: 'serif',
                  fontFamilyFallback: AppTheme.fontFallbacks,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (hasCheckmark) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 24,
              ),
            ],
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
