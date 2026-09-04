import 'package:flutter/material.dart';

/// Centralized image precache service for KathaQuest.
/// Tracks which images have been precached to avoid duplicate work,
/// and provides utilities for story-specific preloading.
class ImagePrecacheService {
  static final ImagePrecacheService _instance = ImagePrecacheService._internal();
  factory ImagePrecacheService() => _instance;
  ImagePrecacheService._internal();

  final Set<String> _cachedAssets = {};
  bool _coreAssetsCached = false;

  bool get coreAssetsCached => _coreAssetsCached;

  /// Core images used across the app (backgrounds, UI elements).
  static const List<String> coreAssets = [
    'assets/images/ancient_india_map.jpg',
    'assets/images/grand_kingdom_view_bg.png',
    'assets/images/magical_forest_bg.png',
    'assets/images/night_view_bg.png',
    'assets/images/temple_pillars_bg.jpg',
    'assets/images/young_rama_mascot.jpg',
    'assets/images/story_panchatantra.jpg',
    'assets/images/story_rama_exile.jpg',
    'assets/images/story_vikram_betaal.jpg',
  ];

  /// Story-specific background images.
  static const Map<String, List<String>> storyAssets = {
    'story_hare_tortoise': [
      'assets/images/backgrounds_for_hare_tortoise_story/1.png',
      'assets/images/backgrounds_for_hare_tortoise_story/2.png',
      'assets/images/backgrounds_for_hare_tortoise_story/3.png',
      'assets/images/backgrounds_for_hare_tortoise_story/4.png',
      'assets/images/backgrounds_for_hare_tortoise_story/5.png',
    ],
  };

  /// Precache core UI assets on app start. Safe to call multiple times.
  Future<void> precacheCoreAssets(BuildContext context) async {
    if (_coreAssetsCached) return;

    for (final asset in coreAssets) {
      await _precacheSingle(asset, context);
    }
    _coreAssetsCached = true;
  }

  /// Precache all images for a specific story before entering StoryScreen.
  Future<void> precacheStoryAssets(String storyId, BuildContext context) async {
    final assets = storyAssets[storyId];
    if (assets == null) return;

    for (final asset in assets) {
      await _precacheSingle(asset, context);
    }
  }

  /// Precache a single image if not already cached.
  Future<void> _precacheSingle(String asset, BuildContext context) async {
    if (_cachedAssets.contains(asset)) return;

    try {
      await precacheImage(AssetImage(asset), context);
      _cachedAssets.add(asset);
    } catch (_) {
      // Silently ignore missing assets in development
    }
  }

  /// Check if a specific asset is already cached.
  bool isAssetCached(String asset) => _cachedAssets.contains(asset);

  /// Get count of cached assets for loading progress tracking.
  int get cachedCount => _cachedAssets.length;
}
