import 'package:flutter/material.dart';

class AchievementItem {
  final String id;
  final String title;
  final String iconEmoji;
  final Color primaryColor;
  final Color secondaryColor;
  final int currentProgress;
  final int targetProgress;
  final int xpReward;
  final int coinReward;
  final String unlockedSkinName;

  const AchievementItem({
    required this.id,
    required this.title,
    required this.iconEmoji,
    required this.primaryColor,
    required this.secondaryColor,
    required this.currentProgress,
    required this.targetProgress,
    this.xpReward = 500,
    this.coinReward = 50,
    this.unlockedSkinName = 'Ancient Scroll Skin',
  });
}

class AchievementMedallionWidget extends StatelessWidget {
  final AchievementItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const AchievementMedallionWidget({
    super.key,
    required this.item,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (item.currentProgress / item.targetProgress).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular Ornate Medallion
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [item.secondaryColor, item.primaryColor],
              ),
              border: Border.all(
                color: isSelected ? const Color(0xFFFFD54F) : const Color(0xFFD4A310),
                width: isSelected ? 3.5 : 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: item.primaryColor.withOpacity(isSelected ? 0.6 : 0.35),
                  blurRadius: isSelected ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ornate inner ring
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
                  ),
                ),
                // Center Icon / Emblem
                Text(
                  item.iconEmoji,
                  style: const TextStyle(fontSize: 34),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Badge Title
          SizedBox(
            width: 84,
            child: Text(
              item.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF5E8CB),
                fontFamily: 'serif',
                height: 1.15,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Progress Bar Pill
          Container(
            width: 70,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: item.primaryColor.withOpacity(0.6), width: 1),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(item.primaryColor),
                    minHeight: 16,
                  ),
                ),
                Center(
                  child: Text(
                    '${item.currentProgress}/${item.targetProgress}',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
