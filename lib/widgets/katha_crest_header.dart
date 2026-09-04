import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../state/game_state.dart';

class KathaCrestHeader extends StatefulWidget {
  const KathaCrestHeader({super.key});

  @override
  State<KathaCrestHeader> createState() => _KathaCrestHeaderState();
}

class _KathaCrestHeaderState extends State<KathaCrestHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _showAvatarPicker(BuildContext context, GameState gameState) {
    final avatars = [
      {'emoji': '👧', 'asset': 'assets/images/young_rama_mascot.jpg', 'name': 'Aarohi'},
      {'emoji': '🧒', 'asset': 'assets/images/young_rama_mascot.jpg', 'name': 'Aarav'},
      {'emoji': '🏹', 'asset': 'assets/images/story_rama_exile.jpg', 'name': 'Rama'},
      {'emoji': '👑', 'asset': 'assets/images/story_vikram_betaal.jpg', 'name': 'Vikram'},
      {'emoji': '🦚', 'asset': 'assets/images/backgrounds_for_hare_tortoise_story/1.png', 'name': 'Mayura'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Your Avatar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: avatars.map((av) {
                final isSelected = gameState.profile.avatarEmoji == av['emoji'];
                return GestureDetector(
                  onTap: () {
                    gameState.updateAvatar(emoji: av['emoji']!, asset: av['asset']!);
                    Navigator.of(ctx).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFECC8) : Colors.grey.shade100,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                        width: 2.5,
                      ),
                    ),
                    child: Text(av['emoji']!, style: const TextStyle(fontSize: 32)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final profile = gameState.profile;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: const BoxDecoration(
        color: AppTheme.parchmentLight,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT: Player Avatar Card
              GestureDetector(
                onTap: () => _showAvatarPicker(context, gameState),
                child: Container(
                  width: 95,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7EA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5D5B5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Player Avatar',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Main Avatar
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.saffron, width: 2),
                              image: DecorationImage(
                                image: AssetImage(profile.avatarAsset),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Center(
                              child: Text(profile.avatarEmoji, style: const TextStyle(fontSize: 22)),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Mini Variant Avatars (Interactive)
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () => gameState.updateAvatar(
                                  emoji: '👧',
                                  asset: 'assets/images/young_rama_mascot.jpg',
                                ),
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: profile.avatarEmoji == '👧' ? AppTheme.primary : Colors.grey.shade400,
                                      width: 1.2,
                                    ),
                                    color: const Color(0xFFFFE0B2),
                                  ),
                                  child: const Center(child: Text('👧', style: TextStyle(fontSize: 10))),
                                ),
                              ),
                              const SizedBox(height: 3),
                              GestureDetector(
                                onTap: () => gameState.updateAvatar(
                                  emoji: '🧒',
                                  asset: 'assets/images/young_rama_mascot.jpg',
                                ),
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: profile.avatarEmoji == '🧒' ? AppTheme.primary : Colors.grey.shade400,
                                      width: 1.2,
                                    ),
                                    color: const Color(0xFFFFCC80),
                                  ),
                                  child: const Center(child: Text('🧒', style: TextStyle(fontSize: 10))),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap to change',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // CENTER: Purple KathaQuest Crest with Shimmer
              Expanded(
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return ShaderMask(
                          shaderCallback: (rect) {
                            final shimmerPos = _shimmerController.value;
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
                          child: child!,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: AppTheme.purpleCrestGradient,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.royalPurple.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'कथा',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFD54F),
                                letterSpacing: 1.2,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              'Quest',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.5,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Level Indicator Pill with animated XP bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7EA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5D5B5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield_rounded, size: 14, color: AppTheme.saffron),
                          const SizedBox(width: 4),
                          Text(
                            'Level ${profile.level}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 50,
                            height: 6,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                  begin: 0,
                                  end: profile.currentXp / profile.targetXp,
                                ),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, _) {
                                  return LinearProgressIndicator(
                                    value: value,
                                    backgroundColor: Colors.grey.shade300,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                        AppTheme.saffron),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // RIGHT: Animated XP, Coins, and Streak Badges
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _AnimatedStatPill(
                    icon: '⭐',
                    value: profile.currentXp,
                    label: 'XP',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                    ),
                    textColor: const Color(0xFF1B5E20),
                  ),
                  const SizedBox(height: 4),
                  _AnimatedStatPill(
                    icon: '🪙',
                    value: profile.coins,
                    label: 'Coins',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF9C4), Color(0xFFFFECB3)],
                    ),
                    textColor: const Color(0xFFB78103),
                  ),
                  const SizedBox(height: 4),
                  _AnimatedStatPill(
                    icon: '🔥',
                    value: profile.dayStreak,
                    label: 'Day Streak',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
                    ),
                    textColor: const Color(0xFFE65100),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stat pill with animated counting-up number
class _AnimatedStatPill extends StatelessWidget {
  final String icon;
  final int value;
  final String label;
  final Gradient gradient;
  final Color textColor;

  const _AnimatedStatPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.gradient,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Expanded(
            child: TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: value),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, _) {
                final formatted = animatedValue.toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                );
                return Text(
                  '$formatted $label',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
