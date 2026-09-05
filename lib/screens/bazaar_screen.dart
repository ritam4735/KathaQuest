import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/audio_manager.dart';
import '../core/haptic_feedback_helper.dart';
import '../state/game_state.dart';

class BazaarScreen extends StatefulWidget {
  const BazaarScreen({super.key});

  @override
  State<BazaarScreen> createState() => _BazaarScreenState();
}

class _BazaarScreenState extends State<BazaarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Catalog Data ---
  final List<Map<String, dynamic>> _companionItems = [
    {
      'id': 'avatar_timo',
      'name': 'Timo the Tortoise',
      'emoji': '🐢',
      'asset': 'assets/spritesheets/turtle.png',
      'desc': 'Slow, patient, and steadfast.',
      'cost': 0,
    },
    {
      'id': 'avatar_shona',
      'name': 'Shona the Hare',
      'emoji': '🐇',
      'asset': 'assets/spritesheets/rabbit.png',
      'desc': 'Swift as the forest wind!',
      'cost': 0,
    },
    {
      'id': 'avatar_owl',
      'name': 'Wise Forest Owl',
      'emoji': '🦉',
      'asset': 'assets/spritesheets/turtle.png',
      'desc': 'Seer of midnight truth and riddle keeper.',
      'cost': 200,
    },
    {
      'id': 'avatar_peacock',
      'name': 'Royal Peacock',
      'emoji': '🦚',
      'asset': 'assets/spritesheets/turtle.png',
      'desc': 'Crested emblem of rains and victory.',
      'cost': 300,
    },
    {
      'id': 'avatar_deer',
      'name': 'Mythic Golden Deer',
      'emoji': '🦌',
      'asset': 'assets/spritesheets/turtle.png',
      'desc': 'Luminous and enchanted creature of Dandaka.',
      'cost': 400,
    },
    {
      'id': 'avatar_tiger',
      'name': 'Brave Royal Tiger',
      'emoji': '🐅',
      'asset': 'assets/spritesheets/turtle.png',
      'desc': 'Fierce guardian of ancient wisdom.',
      'cost': 500,
    },
    {
      'id': 'avatar_rama',
      'name': 'Young Prince Rama',
      'emoji': '🏹',
      'asset': 'assets/images/young_rama_mascot.jpg',
      'desc': 'Noble warrior guided by eternal dharma.',
      'cost': 600,
    },
  ];

  final List<Map<String, dynamic>> _titleItems = [
    {
      'id': 'title_seeker',
      'title': 'Story Seeker',
      'emoji': '📜',
      'desc': 'A curious listener of ancient tales.',
      'cost': 0,
    },
    {
      'id': 'title_wanderer',
      'title': 'Forest Wanderer',
      'emoji': '🌲',
      'desc': 'Traveler of the sacred Dandaka groves.',
      'cost': 100,
    },
    {
      'id': 'title_champion',
      'title': 'Mythic Champion',
      'emoji': '⚔️',
      'desc': 'Victor of legendary challenges and races.',
      'cost': 250,
    },
    {
      'id': 'title_wisdom',
      'title': 'Guardian of Wisdom',
      'emoji': '🪷',
      'desc': 'Master of Panchatantra virtues and wits.',
      'cost': 400,
    },
    {
      'id': 'title_dharma',
      'title': 'Dharma Master',
      'emoji': '👑',
      'desc': 'Exemplar of truth, honor, and courage.',
      'cost': 600,
    },
  ];

  final List<Map<String, dynamic>> _bubbleItems = [
    {
      'id': 'bubble_parchment',
      'name': 'Classic Parchment',
      'emoji': '📜',
      'desc': 'Warm antique manuscript parchment.',
      'cost': 0,
    },
    {
      'id': 'bubble_gold',
      'name': 'Royal Golden Glow',
      'emoji': '✨',
      'desc': 'Shimmering warm gold border for dialogues.',
      'cost': 150,
    },
    {
      'id': 'bubble_emerald',
      'name': 'Forest Emerald',
      'emoji': '🍃',
      'desc': 'Peaceful woodland green aesthetic.',
      'cost': 250,
    },
    {
      'id': 'bubble_star',
      'name': 'Mystic Starlight',
      'emoji': '🌌',
      'desc': 'Cosmic night sky hue with celestial glimmer.',
      'cost': 350,
    },
  ];

  void _handleBuy(String id, int cost, String name, VoidCallback onPurchased) {
    final gameState = Provider.of<GameState>(context, listen: false);
    if (gameState.profile.coins < cost) {
      AudioManager().playWrong();
      HapticHelper.warning();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough coins! You need ${cost - gameState.profile.coins} more 🪙'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final success = gameState.purchaseItem(itemId: id, cost: cost);
    if (success) {
      HapticHelper.success();
      onPurchased();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unlocked $name! 🌟'),
          backgroundColor: const Color(0xFF00A896),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final isHindi = gameState.isHindi;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8EE),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header: Title & Coin Counter Pill
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHindi ? 'शाही बाज़ार 🛍️' : 'The Royal Bazaar 🛍️',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                          fontFamily: 'serif',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isHindi ? 'सिक्कों से नए अवतार और उपाधियां पाएं' : 'Unlock companions, titles & speech skins',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  // Coin Purse Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB300).withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '${gameState.profile.coins}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFEADBBE).withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textMedium,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(text: isHindi ? 'अवतार 🎭' : 'Avatars 🎭'),
                  Tab(text: isHindi ? 'उपाधियां 📜' : 'Titles 📜'),
                  Tab(text: isHindi ? 'संवाद शैली 💬' : 'Dialogue 💬'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAvatarsList(gameState, isHindi),
                  _buildTitlesList(gameState, isHindi),
                  _buildBubbleThemesList(gameState, isHindi),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Category 1: Avatars ---
  Widget _buildAvatarsList(GameState gameState, bool isHindi) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: _companionItems.length,
      itemBuilder: (context, index) {
        final item = _companionItems[index];
        final id = item['id'] as String;
        final cost = item['cost'] as int;
        final isOwned = cost == 0 || gameState.profile.purchasedItemIds.contains(id);
        final isEquipped = gameState.profile.avatarEmoji == item['emoji'];

        return _buildShopCard(
          emoji: item['emoji'] as String,
          title: item['name'] as String,
          desc: item['desc'] as String,
          cost: cost,
          isOwned: isOwned,
          isEquipped: isEquipped,
          onEquip: () {
            gameState.updateAvatar(
              emoji: item['emoji'] as String,
              asset: item['asset'] as String,
            );
          },
          onBuy: () {
            _handleBuy(id, cost, item['name'] as String, () {
              gameState.updateAvatar(
                emoji: item['emoji'] as String,
                asset: item['asset'] as String,
              );
            });
          },
        );
      },
    );
  }

  // --- Category 2: Titles ---
  Widget _buildTitlesList(GameState gameState, bool isHindi) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: _titleItems.length,
      itemBuilder: (context, index) {
        final item = _titleItems[index];
        final id = item['id'] as String;
        final cost = item['cost'] as int;
        final isOwned = cost == 0 || gameState.profile.purchasedItemIds.contains(id);
        final isEquipped = gameState.profile.currentTitle == item['title'];

        return _buildShopCard(
          emoji: item['emoji'] as String,
          title: item['title'] as String,
          desc: item['desc'] as String,
          cost: cost,
          isOwned: isOwned,
          isEquipped: isEquipped,
          onEquip: () {
            gameState.equipTitle(item['title'] as String);
          },
          onBuy: () {
            _handleBuy(id, cost, item['title'] as String, () {
              gameState.equipTitle(item['title'] as String);
            });
          },
        );
      },
    );
  }

  // --- Category 3: Bubble Themes ---
  Widget _buildBubbleThemesList(GameState gameState, bool isHindi) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: _bubbleItems.length,
      itemBuilder: (context, index) {
        final item = _bubbleItems[index];
        final id = item['id'] as String;
        final cost = item['cost'] as int;
        final isOwned = cost == 0 || gameState.profile.purchasedItemIds.contains(id);
        final isEquipped = gameState.profile.currentBubbleTheme == id;

        return _buildShopCard(
          emoji: item['emoji'] as String,
          title: item['name'] as String,
          desc: item['desc'] as String,
          cost: cost,
          isOwned: isOwned,
          isEquipped: isEquipped,
          onEquip: () {
            gameState.equipBubbleTheme(id);
          },
          onBuy: () {
            _handleBuy(id, cost, item['name'] as String, () {
              gameState.equipBubbleTheme(id);
            });
          },
        );
      },
    );
  }

  // --- Reusable Shop Card ---
  Widget _buildShopCard({
    required String emoji,
    required String title,
    required String desc,
    required int cost,
    required bool isOwned,
    required bool isEquipped,
    required VoidCallback onEquip,
    required VoidCallback onBuy,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.ornateParchmentDecoration(
        backgroundColor: isEquipped ? const Color(0xFFFFF9E6) : Colors.white,
        borderColor: isEquipped ? AppTheme.gold : const Color(0xFFEADBBE),
        radius: 20,
      ),
      child: Row(
        children: [
          // Emoji Avatar Icon Box
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isEquipped ? const Color(0xFFFFE082).withOpacity(0.4) : const Color(0xFFFBF8EE),
              shape: BoxShape.circle,
              border: Border.all(
                color: isEquipped ? AppTheme.gold : const Color(0xFFEADBBE),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    if (isEquipped) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C853).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Active ✓',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF00C853),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Action Button
          if (isEquipped)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Equipped',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00A896),
                ),
              ),
            )
          else if (isOwned)
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: onEquip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Equip', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            )
          else
            SizedBox(
              height: 36,
              child: ElevatedButton.icon(
                icon: const Text('🪙', style: TextStyle(fontSize: 12)),
                label: Text('$cost', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9F1C),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: onBuy,
              ),
            ),
        ],
      ),
    );
  }
}
