import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/story_model.dart';
import '../../state/game_state.dart';
import '../../core/app_theme.dart';
import 'speech_bubble.dart';
import 'tap_reaction_widget.dart';

class ComicReaderView extends StatefulWidget {
  final ComicStep step;
  final VoidCallback onContinue;

  const ComicReaderView({
    super.key,
    required this.step,
    required this.onContinue,
  });

  @override
  State<ComicReaderView> createState() => _ComicReaderViewState();
}

class _ComicReaderViewState extends State<ComicReaderView> {
  int _currentPanelIndex = 0;
  bool _isSpeakingNarration = false;

  ComicPanel get currentPanel => widget.step.panels[_currentPanelIndex];

  void _nextPanelOrStep() {
    if (_currentPanelIndex < widget.step.panels.length - 1) {
      setState(() {
        _currentPanelIndex++;
      });
    } else {
      widget.onContinue();
    }
  }

  void _playNarration() {
    setState(() {
      _isSpeakingNarration = true;
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isSpeakingNarration = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final isHindi = gameState.isHindi;
    final panel = currentPanel;
    final hasBgImage = panel.backgroundImage != null && panel.backgroundImage!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        gradient: hasBgImage ? null : _getBackgroundGradient(panel.backgroundTheme),
      ),
      child: Stack(
        children: [
          // Background scenic illustration decorations or high-res background image
          if (hasBgImage) ...[
            Positioned.fill(
              child: Image.asset(
                panel.backgroundImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildScenicDecorations(panel.backgroundTheme),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.20),
                      Colors.transparent,
                      Colors.black.withOpacity(0.25),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
          ] else ...[
            _buildScenicDecorations(panel.backgroundTheme),
          ],

          // Main Interactive Layout
          Column(
            children: [
              // Panel header / Chapter title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primary, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Text('📖 ', style: TextStyle(fontSize: 14)),
                          Text(
                            widget.step.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.volume_up_rounded, size: 20),
                      label: Text(_isSpeakingNarration ? 'Playing...' : 'Read to Me'),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        foregroundColor: AppTheme.primaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _playNarration,
                    ),
                  ],
                ),
              ),

              // Interactive Character Stage
              Expanded(
                flex: 4,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        // Interactive tap targets placed on stage
                        for (final target in panel.interactiveTargets)
                          Positioned(
                            left: (constraints.maxWidth * target.posX) - 50,
                            top: (constraints.maxHeight * target.posY) - 50,
                            child: TapReactionWidget(target: target),
                          ),

                        // Dialogue bubbles overlay
                        Positioned(
                          left: 16,
                          right: 16,
                          top: 10,
                          child: Column(
                            children: panel.dialogues.map((d) {
                              return SpeechBubble(
                                speaker: d.speaker,
                                avatar: d.avatar,
                                text: isHindi ? d.textRegional : d.textEn,
                                isLeft: d.isLeftAligned,
                                isNarrating: _isSpeakingNarration,
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Bottom Narration Box & Continue button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Narration text with bilingual support
                    Text(
                      isHindi ? panel.narrationRegional : panel.narrationEn,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: _isSpeakingNarration
                            ? AppTheme.primaryDark
                            : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Next / Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: Text(
                          _currentPanelIndex < widget.step.panels.length - 1
                              ? (isHindi ? 'अगला दृश्य' : 'Next Scene')
                              : (isHindi ? 'आगे बढ़ें (मिनी-गेम!)' : 'Continue (Mini-Game!)'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: _nextPanelOrStep,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  LinearGradient _getBackgroundGradient(String theme) {
    switch (theme) {
      case 'race_track':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF80ED99), Color(0xFFC7F9CC), Color(0xFFE9EDC9)],
        );
      case 'apple_tree_meadow':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
        );
      case 'finish_line':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFD166), Color(0xFFFFF3B0), Color(0xFFE9EDC9)],
        );
      case 'sunny_forest':
      default:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBAE6FD), Color(0xFFE0F2FE), Color(0xFFDCFCE7)],
        );
    }
  }

  Widget _buildScenicDecorations(String theme) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // Clouds in sky
            Positioned(
              top: 20,
              left: 30,
              child: Opacity(
                opacity: 0.6,
                child: Row(
                  children: const [
                    Text('☁️', style: TextStyle(fontSize: 34)),
                    SizedBox(width: 40),
                    Text('☀️', style: TextStyle(fontSize: 40)),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 40,
              child: Opacity(
                opacity: 0.5,
                child: const Text('☁️', style: TextStyle(fontSize: 28)),
              ),
            ),

            // Theme-specific ground scenery
            if (theme == 'apple_tree_meadow') ...[
              Positioned(
                bottom: 120,
                left: 20,
                child: const Text('🌳🍎', style: TextStyle(fontSize: 64)),
              ),
              Positioned(
                bottom: 130,
                right: 30,
                child: const Text('🌺🌼', style: TextStyle(fontSize: 32)),
              ),
            ] else if (theme == 'race_track') ...[
              Positioned(
                bottom: 120,
                left: 10,
                child: const Text('🚩🏁', style: TextStyle(fontSize: 48)),
              ),
              Positioned(
                bottom: 125,
                right: 20,
                child: const Text('🏁🚩', style: TextStyle(fontSize: 48)),
              ),
            ] else if (theme == 'finish_line') ...[
              Positioned(
                bottom: 120,
                left: 30,
                child: const Text('🎉🎈', style: TextStyle(fontSize: 52)),
              ),
              Positioned(
                bottom: 120,
                right: 30,
                child: const Text('🏆✨', style: TextStyle(fontSize: 52)),
              ),
            ] else ...[
              Positioned(
                bottom: 120,
                left: 15,
                child: const Text('🌲🍄', style: TextStyle(fontSize: 48)),
              ),
              Positioned(
                bottom: 120,
                right: 20,
                child: const Text('🌳🌸', style: TextStyle(fontSize: 48)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
