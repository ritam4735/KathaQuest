import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/page_transitions.dart';
import '../data/sample_stories.dart';
import '../state/game_state.dart';
import 'story_screen.dart';

class AdventureMapScreen extends StatefulWidget {
  const AdventureMapScreen({super.key});

  @override
  State<AdventureMapScreen> createState() => _AdventureMapScreenState();
}

class _AdventureMapScreenState extends State<AdventureMapScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _nodeStaggerController;
  late AnimationController _particleController;
  late List<Animation<double>> _nodeAnimations;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _nodeStaggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _nodeAnimations = List.generate(3, (i) {
      final start = i * 0.2;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _nodeStaggerController,
        curve: Interval(start, end, curve: Curves.elasticOut),
      );
    });

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _nodeStaggerController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _launchChapter(BuildContext context, GameState gameState, [String? chapterId]) {
    final activeId = chapterId ?? gameState.selectedMapChapterId;
    gameState.selectMapChapter(activeId);
    final story = activeId == 'ch_1'
        ? SampleStories.ramasExile
        : (activeId == 'ch_2'
            ? SampleStories.hareAndTortoise
            : SampleStories.panchatantraTales);
    gameState.startStory(story);
    Navigator.of(context).push(
      StoryLaunchPageRoute(page: const StoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final selectedChapter = gameState.selectedMapChapterId;
    final String activeChapterTitle;
    final String activeImage;
    final String activeStatus;
    final Color activeStatusColor;

    if (selectedChapter == 'ch_1') {
      activeChapterTitle = 'Ch. 1:\nRama\'s Exile';
      activeImage = 'assets/images/story_rama_exile.jpg';
      final stars = gameState.profile.storyStars['story_rama_exile'] ?? 0;
      activeStatus = stars > 0 ? 'Done ($stars⭐)' : 'In Progress';
      activeStatusColor = const Color(0xFF00C853);
    } else if (selectedChapter == 'ch_2') {
      activeChapterTitle = 'Ch. 2:\nHare & Tortoise';
      activeImage = 'assets/images/backgrounds_for_hare_tortoise_story/1.png';
      final stars = gameState.profile.storyStars['story_hare_tortoise'] ?? 0;
      activeStatus = stars > 0 ? 'Done ($stars⭐)' : 'Current Quest';
      activeStatusColor = stars > 0 ? const Color(0xFF00C853) : const Color(0xFFFF9F1C);
    } else {
      activeChapterTitle = 'Ch. 3:\nPanchatantra';
      activeImage = 'assets/images/story_panchatantra.jpg';
      final isUnlocked = gameState.profile.storyStars.containsKey('story_hare_tortoise');
      activeStatus = isUnlocked ? 'Unlocked' : 'Locked';
      activeStatusColor = isUnlocked ? const Color(0xFFFF9F1C) : const Color(0xFF7B1FA2);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7EEDB),
      body: SafeArea(
        child: Stack(
          children: [
            // MAP BACKGROUND ARTWORK
            Positioned.fill(
              child: Image.asset(
                'assets/images/ancient_india_map.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),

            // Floating ambient particles (fireflies)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _FireflyPainter(
                        time: _particleController.value,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Dotted Trail & Interactive Nodes
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;

                  // Node positions
                  final node1 = Offset(w * 0.36, h * 0.18);
                  final node2 = Offset(w * 0.52, h * 0.38);
                  final node3 = Offset(w * 0.46, h * 0.60);

                  return Stack(
                    children: [
                      // Animated dotted path lines between nodes
                      AnimatedBuilder(
                        animation: _nodeStaggerController,
                        builder: (context, _) {
                          return CustomPaint(
                            size: Size(w, h),
                            painter: _DottedPathPainter(
                              nodes: [node1, node2, node3],
                              progress: _nodeStaggerController.value,
                            ),
                          );
                        },
                      ),

                      // Top Progress Dots
                      Positioned(
                        top: 14,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            6,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: i == 1 ? 10 : 8,
                              height: i == 1 ? 10 : 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i == 1 ? Colors.white : Colors.white54,
                                border: Border.all(color: Colors.black38),
                                boxShadow: i == 1
                                    ? [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.5),
                                          blurRadius: 4,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // NODE 1: Chapter 1 (Ramayana)
                      _buildAnimatedNode(
                        animation: _nodeAnimations[0],
                        position: Offset(node1.dx - 40, node1.dy),
                        child: _buildMapNode(
                          nodeIcon: Icons.check_rounded,
                          glowColor: const Color(0xFF00E676),
                          iconColor: Colors.white,
                          nodeColor: const Color(0xFF00C853),
                          chapterTitle: 'Ch. 1:\nRama\'s Exile',
                          statusText: 'Completed',
                          statusColor: const Color(0xFF00C853),
                          onTap: () => _launchChapter(context, gameState, 'ch_1'),
                        ),
                      ),

                      // NODE 2: Chapter 2 (The Hare and the Tortoise) - Connected to DB
                      _buildAnimatedNode(
                        animation: _nodeAnimations[1],
                        position: Offset(node2.dx - 40, node2.dy),
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final scale = (gameState.profile.storyStars.containsKey('story_hare_tortoise'))
                                ? 1.0
                                : 1.0 + (0.08 * _pulseController.value);
                            return Transform.scale(
                              scale: scale,
                              child: child,
                            );
                          },
                          child: _buildMapNode(
                            nodeIcon: gameState.profile.storyStars.containsKey('story_hare_tortoise')
                                ? Icons.check_rounded
                                : Icons.play_arrow_rounded,
                            glowColor: gameState.profile.storyStars.containsKey('story_hare_tortoise')
                                ? const Color(0xFF00E676)
                                : const Color(0xFFFF9800),
                            iconColor: Colors.white,
                            nodeColor: gameState.profile.storyStars.containsKey('story_hare_tortoise')
                                ? const Color(0xFF00C853)
                                : const Color(0xFFFF9F1C),
                            chapterTitle: "Ch. 2:\nHare & Tortoise",
                            statusText: gameState.profile.storyStars.containsKey('story_hare_tortoise')
                                ? 'Done (${gameState.profile.storyStars['story_hare_tortoise']}⭐)'
                                : 'Current',
                            statusColor: gameState.profile.storyStars.containsKey('story_hare_tortoise')
                                ? const Color(0xFF00C853)
                                : const Color(0xFFFF9F1C),
                            hasTreasureChest: true,
                            onTap: () => _launchChapter(context, gameState, 'ch_2'),
                          ),
                        ),
                      ),

                      // NODE 3: Chapter 3 (Panchatantra) - Unlocked when Ch. 2 completed in DB
                      _buildAnimatedNode(
                        animation: _nodeAnimations[2],
                        position: Offset(node3.dx - 40, node3.dy),
                        child: gameState.profile.storyStars.containsKey('story_hare_tortoise')
                            ? _buildMapNode(
                                nodeIcon: Icons.play_arrow_rounded,
                                glowColor: const Color(0xFFFF9800),
                                iconColor: Colors.white,
                                nodeColor: const Color(0xFFFF9F1C),
                                chapterTitle: 'Ch. 3:\nPanchatantra',
                                statusText: 'Unlocked',
                                statusColor: const Color(0xFFFF9F1C),
                                onTap: () => _launchChapter(context, gameState, 'ch_3'),
                              )
                            : _LockedNodeWrapper(
                                child: _buildMapNode(
                                  nodeIcon: Icons.lock_rounded,
                                  glowColor: const Color(0xFFAB47BC),
                                  iconColor: Colors.white70,
                                  nodeColor: const Color(0xFF7B1FA2),
                                  chapterTitle: 'Ch. 3:\nPanchatantra',
                                  statusText: 'Locked',
                                  statusColor: const Color(0xFF7B1FA2),
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Complete Chapter 2 (Hare & Tortoise) to unlock Chapter 3!'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),

                      // BOTTOM FLOATING CHAPTER DOCK
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 16,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: GestureDetector(
                                onTap: () => _launchChapter(context, gameState),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: AppTheme.ornateParchmentDecoration(
                                    backgroundColor: const Color(0xFFFFFDF5),
                                    borderColor: const Color(0xFFEADBBE),
                                    radius: 22,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Current Chapter',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textDark,
                                          fontFamily: 'serif',
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.asset(
                                              activeImage,
                                              width: 54,
                                              height: 54,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  activeChapterTitle,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w900,
                                                    color: AppTheme.textDark,
                                                    fontFamily: 'serif',
                                                    height: 1.15,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  activeStatus,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: activeStatusColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 5,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: AppTheme.ornateParchmentDecoration(
                                  backgroundColor: const Color(0xFFFFFDF5),
                                  borderColor: const Color(0xFFEADBBE),
                                  radius: 22,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Available Stories',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                        fontFamily: 'serif',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.asset(
                                            'assets/images/backgrounds_for_hare_tortoise_story/1.png',
                                            width: 50,
                                            height: 54,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.asset(
                                            'assets/images/story_panchatantra.jpg',
                                            width: 50,
                                            height: 54,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.asset(
                                            'assets/images/story_vikram_betaal.jpg',
                                            width: 50,
                                            height: 54,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedNode({
    required Animation<double> animation,
    required Offset position,
    required Widget child,
  }) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: animation.value,
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapNode({
    required IconData nodeIcon,
    required Color glowColor,
    required Color iconColor,
    required Color nodeColor,
    required String chapterTitle,
    required String statusText,
    required Color statusColor,
    bool hasTreasureChest = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEADBBE), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  chapterTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                    fontFamily: 'serif',
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: nodeColor,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withOpacity(0.6),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(nodeIcon, color: iconColor, size: 26),
              ),
              if (hasTreasureChest) ...[
                const SizedBox(width: 8),
                const Text('🎁', style: TextStyle(fontSize: 22)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Locked node that shakes on tap
class _LockedNodeWrapper extends StatefulWidget {
  final Widget child;
  const _LockedNodeWrapper({required this.child});

  @override
  State<_LockedNodeWrapper> createState() => _LockedNodeWrapperState();
}

class _LockedNodeWrapperState extends State<_LockedNodeWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _shake() {
    _shakeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _shake,
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final shake = sin(_shakeController.value * pi * 6) *
              4 *
              (1.0 - _shakeController.value);
          return Transform.translate(
            offset: Offset(shake, 0),
            child: Opacity(
              opacity: 0.7,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Custom painter for animated dotted paths between map nodes
class _DottedPathPainter extends CustomPainter {
  final List<Offset> nodes;
  final double progress;

  _DottedPathPainter({required this.nodes, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.length < 2) return;

    final paint = Paint()
      ..color = const Color(0xFFFFB300).withOpacity(0.7)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < nodes.length - 1; i++) {
      final nodeProgress = ((progress - i * 0.2) / 0.4).clamp(0.0, 1.0);
      if (nodeProgress <= 0) continue;

      final start = Offset(nodes[i].dx + 24, nodes[i].dy + 70);
      final end = Offset(nodes[i + 1].dx + 24, nodes[i + 1].dy);

      final controlX = (start.dx + end.dx) / 2 + 30;
      final controlY = (start.dy + end.dy) / 2;

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(controlX, controlY, end.dx, end.dy);

      // Draw as dashed
      final metrics = path.computeMetrics();
      for (final metric in metrics) {
        final totalLength = metric.length * nodeProgress;
        double distance = 0;
        while (distance < totalLength) {
          final dashLength = min(6.0, totalLength - distance);
          final extractedPath = metric.extractPath(distance, distance + dashLength);
          canvas.drawPath(extractedPath, paint);
          distance += 12; // dash + gap
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedPathPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

/// Floating firefly particles
class _FireflyPainter extends CustomPainter {
  final double time;
  final Random _random = Random(42); // Fixed seed for consistent positions

  _FireflyPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 12; i++) {
      final baseX = _random.nextDouble() * size.width;
      final baseY = _random.nextDouble() * size.height * 0.7;
      final phase = _random.nextDouble() * pi * 2;
      final radius = 20 + _random.nextDouble() * 30;

      final x = baseX + cos(time * pi * 2 + phase) * radius;
      final y = baseY + sin(time * pi * 2 + phase * 1.3) * radius * 0.6;

      final opacity = (0.3 + 0.4 * sin(time * pi * 4 + phase * 2)).clamp(0.0, 1.0);

      canvas.drawCircle(
        Offset(x, y),
        2 + sin(time * pi * 3 + i) * 1,
        Paint()
          ..color = Color.fromRGBO(255, 213, 79, opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FireflyPainter oldDelegate) =>
      time != oldDelegate.time;
}
