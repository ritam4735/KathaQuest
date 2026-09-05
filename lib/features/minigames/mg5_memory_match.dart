import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/audio_manager.dart';
import '../../core/haptic_feedback_helper.dart';
import '../../core/models/story_model.dart';
import 'minigame_celebration_dialog.dart';
import 'minigame_container.dart';

class MemoryMatchMiniGame extends StatefulWidget {
  final MiniGameStep step;
  final Function(int score) onComplete;
  final VoidCallback? onPause;

  const MemoryMatchMiniGame({
    super.key,
    required this.step,
    required this.onComplete,
    this.onPause,
  });

  @override
  State<MemoryMatchMiniGame> createState() => _MemoryMatchMiniGameState();
}

class _MemoryCard {
  final int id;
  final String emoji;
  final String nameEn;
  final String nameRegional;
  bool isFaceUp = false;
  bool isMatched = false;

  _MemoryCard({
    required this.id,
    required this.emoji,
    required this.nameEn,
    required this.nameRegional,
  });
}

class _MemoryMatchMiniGameState extends State<MemoryMatchMiniGame> {
  late List<_MemoryCard> _cards;
  int? _firstSelectedIndex;
  bool _isProcessing = false;
  int _score = 0;
  int _consecutiveMatches = 0;
  int _matchedPairsCount = 0;

  Timer? _gameTimer;
  Timer? _countdownTimer;
  late int _remainingSeconds;
  bool _isGameOver = false;
  bool _isReady = true;
  bool _isCountingDown = false;
  int _countdown = 3;
  bool _isPaused = false;

  final List<Map<String, String>> _pairDefinitions = [
    {'emoji': '🐒', 'en': 'Monkey', 'hi': 'बंदर'},
    {'emoji': '🐊', 'en': 'Crocodile', 'hi': 'मगरमच्छ'},
    {'emoji': '🐢', 'en': 'Tortoise', 'hi': 'कछुआ'},
    {'emoji': '🐇', 'en': 'Hare', 'hi': 'खरगोश'},
    {'emoji': '🐘', 'en': 'Elephant', 'hi': 'हाथी'},
    {'emoji': '🦚', 'en': 'Peacock', 'hi': 'मोर'},
  ];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.step.durationSeconds > 0 ? widget.step.durationSeconds : 45;
    _initializeCards();
  }

  void _initializeCards() {
    List<_MemoryCard> cardList = [];
    int idCounter = 0;

    for (final def in _pairDefinitions) {
      // 2 cards per animal definition
      cardList.add(
        _MemoryCard(
          id: idCounter++,
          emoji: def['emoji']!,
          nameEn: def['en']!,
          nameRegional: def['hi']!,
        ),
      );
      cardList.add(
        _MemoryCard(
          id: idCounter++,
          emoji: def['emoji']!,
          nameEn: def['en']!,
          nameRegional: def['hi']!,
        ),
      );
    }

    // Shuffle cards
    cardList.shuffle(Random());
    _cards = cardList;
  }

  void _startCountdown() {
    setState(() {
      _isCountingDown = true;
      _countdown = 3;
    });
    AudioManager().playCountdown();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdown > 1) {
        setState(() => _countdown--);
        AudioManager().playCountdown();
      } else if (_countdown == 1) {
        timer.cancel();
        setState(() => _countdown = 0);
        AudioManager().playStar();

        Timer(const Duration(milliseconds: 650), () {
          if (!mounted) return;
          setState(() {
            _isReady = false;
            _isCountingDown = false;
          });
          _startTimer();
        });
      }
    });
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_isPaused || _isReady) return;

      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _endGame(false);
      }
    });
  }

  void _togglePause() {
    if (_isGameOver || _isReady) return;
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _restartGame() {
    _gameTimer?.cancel();
    _countdownTimer?.cancel();
    setState(() {
      _score = 0;
      _consecutiveMatches = 0;
      _matchedPairsCount = 0;
      _firstSelectedIndex = null;
      _isProcessing = false;
      _isGameOver = false;
      _isPaused = false;
      _isReady = true;
      _isCountingDown = false;
      _countdown = 3;
      _remainingSeconds = widget.step.durationSeconds > 0 ? widget.step.durationSeconds : 45;
      _initializeCards();
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _onCardTap(int index) {
    if (_isProcessing || _isGameOver || _isReady || _isPaused) return;
    final card = _cards[index];
    if (card.isFaceUp || card.isMatched) return;

    AudioManager().playTap();
    HapticHelper.light();

    setState(() {
      card.isFaceUp = true;
    });

    if (_firstSelectedIndex == null) {
      // First card flipped
      _firstSelectedIndex = index;
    } else {
      // Second card flipped -> Check match
      _isProcessing = true;
      final firstCard = _cards[_firstSelectedIndex!];
      final secondCard = card;

      if (firstCard.emoji == secondCard.emoji) {
        // MATCH!
        _consecutiveMatches++;
        final matchPoints = 20 + (_consecutiveMatches > 1 ? 10 : 0);

        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          AudioManager().playStar();
          HapticHelper.success();

          setState(() {
            firstCard.isMatched = true;
            secondCard.isMatched = true;
            _score += matchPoints;
            _matchedPairsCount++;
            _firstSelectedIndex = null;
            _isProcessing = false;
          });

          // Check Win condition
          if (_matchedPairsCount >= _pairDefinitions.length || _score >= widget.step.targetScore) {
            _endGame(true);
          }
        });
      } else {
        // MISMATCH
        _consecutiveMatches = 0;
        Future.delayed(const Duration(milliseconds: 750), () {
          if (!mounted) return;
          AudioManager().playWrong();
          HapticHelper.warning();

          setState(() {
            firstCard.isFaceUp = false;
            secondCard.isFaceUp = false;
            _firstSelectedIndex = null;
            _isProcessing = false;
          });
        });
      }
    }
  }

  void _endGame(bool isSuccess) {
    if (_isGameOver) return;
    _isGameOver = true;
    _gameTimer?.cancel();

    if (isSuccess || _score >= widget.step.targetScore) {
      AudioManager().playFanfare();
      AudioManager().playCheer();

      MiniGameCelebrationDialog.show(
        context: context,
        score: _score,
        targetScore: widget.step.targetScore,
        emoji: '🐒',
        onContinue: () {
          widget.onComplete(_score);
        },
      );
    } else {
      AudioManager().playWrong();
      HapticHelper.warning();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: const Color(0xFFFFFDF8),
          title: Column(
            children: const [
              Text('⏳', style: TextStyle(fontSize: 48)),
              SizedBox(height: 8),
              Text(
                'Time is Up!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppTheme.textDark),
              ),
            ],
          ),
          content: Text(
            'Keep your mind sharp! You scored $_score points. Would you like to try again?',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: AppTheme.textDark),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      widget.onPause?.call();
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: const Text('Exit', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _restartGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MiniGameContainer(
      title: widget.step.title,
      instructions: widget.step.instructionsEn,
      currentScore: _score,
      targetScore: widget.step.targetScore,
      remainingSeconds: _remainingSeconds,
      onPause: _togglePause,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Match Counter & Multiplier Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEADBBE), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Text('Pairs: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textMedium)),
                          Text(
                            '$_matchedPairsCount / ${_pairDefinitions.length} 🪷',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.primary),
                          ),
                        ],
                      ),
                    ),
                    if (_consecutiveMatches > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFF8F00)]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Combo x$_consecutiveMatches! 🔥',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // 4x3 Memory Card Grid
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _cards.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.92,
                    ),
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      return _buildCardWidget(card, index);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Ready / Countdown Overlay
          if (_isReady)
            Container(
              color: Colors.black.withOpacity(0.60),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: _isCountingDown
                      ? AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                          child: Container(
                            key: ValueKey<int>(_countdown),
                            width: _countdown == 0 ? 150 : 130,
                            height: _countdown == 0 ? 150 : 130,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.96),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _countdown == 0 ? const Color(0xFF2EC4B6) : const Color(0xFFFFB300),
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_countdown == 0 ? const Color(0xFF2EC4B6) : const Color(0xFFFFB300)).withOpacity(0.4),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _countdown == 0 ? 'GO! 🏁' : '$_countdown',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: _countdown == 0 ? 36 : 64,
                                  fontWeight: FontWeight.w900,
                                  color: _countdown == 0 ? const Color(0xFF00897B) : const Color(0xFFE65100),
                                  fontFamily: 'serif',
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.97),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: AppTheme.primary, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.secondary, width: 2),
                                ),
                                child: const Center(
                                  child: Text('🪷', style: TextStyle(fontSize: 34)),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Match the Pairs!',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textDark,
                                  fontFamily: 'serif',
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.step.instructionsEn,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textMedium,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFFFD54F)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🎯 Target Score: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text(
                                      '${widget.step.targetScore} ⭐',
                                      style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFE65100), fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                                  label: const Text('Ready? Let\'s Play!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                  ),
                                  onPressed: _startCountdown,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),

          // In-Game Pause Overlay
          if (_isPaused)
            Container(
              color: Colors.black.withOpacity(0.60),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.97),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Game Paused ⏸️',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark, fontFamily: 'serif'),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow_rounded, size: 22),
                            label: const Text('Resume Game', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            onPressed: _togglePause,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.refresh_rounded, size: 22),
                            label: const Text('Restart Level', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.textDark,
                              side: const BorderSide(color: AppTheme.primary, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            onPressed: _restartGame,
                          ),
                        ),
                        if (widget.onPause != null) ...[
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: widget.onPause,
                            child: const Text('Exit to Story', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardWidget(_MemoryCard card, int index) {
    final showFace = card.isFaceUp || card.isMatched;

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutBack,
        decoration: BoxDecoration(
          color: card.isMatched
              ? const Color(0xFFE8F5E9)
              : (showFace ? const Color(0xFFFFF9E6) : const Color(0xFF4A154B)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: card.isMatched
                ? const Color(0xFF00C853)
                : (showFace ? AppTheme.gold : const Color(0xFFFFD54F)),
            width: card.isMatched ? 2.5 : (showFace ? 2.0 : 1.5),
          ),
          boxShadow: [
            BoxShadow(
              color: card.isMatched
                  ? const Color(0xFF00C853).withOpacity(0.3)
                  : Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: showFace
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(card.emoji, style: const TextStyle(fontSize: 34)),
                    const SizedBox(height: 4),
                    Text(
                      card.nameEn,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: card.isMatched ? const Color(0xFF2E7D32) : AppTheme.textDark,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('🪷', style: TextStyle(fontSize: 26)),
                    SizedBox(height: 2),
                    Text(
                      '?',
                      style: TextStyle(
                        color: Color(0xFFFFD54F),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
