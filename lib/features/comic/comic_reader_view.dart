import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/story_model.dart';
import '../../state/game_state.dart';
import '../../core/app_theme.dart';
import '../../core/narration/narration_service.dart';
import '../../core/haptic_feedback_helper.dart';
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
  final NarrationService _narration = NarrationService.instance;

  ComicPanel get currentPanel => widget.step.panels[_currentPanelIndex];

  @override
  void initState() {
    super.initState();
    _narration.stop();
  }

  @override
  void dispose() {
    _narration.stop();
    super.dispose();
  }

  void _nextPanelOrStep() {
    _narration.stop();
    HapticHelper.light();
    if (_currentPanelIndex < widget.step.panels.length - 1) {
      setState(() {
        _currentPanelIndex++;
      });
    } else {
      widget.onContinue();
    }
  }

  void _handleNarrationToggle(String text, String lang) {
    HapticHelper.light();

    switch (_narration.status) {
      case NarrationStatus.idle:
        _narration.speak(
          text: text,
          language: lang,
          onComplete: () {
            if (mounted) setState(() {});
          },
        );
        break;
      case NarrationStatus.loading:
        // Ignored to prevent rapid duplicate triggers
        break;
      case NarrationStatus.playing:
        _narration.pause();
        break;
      case NarrationStatus.paused:
        _narration.resume();
        break;
    }
    setState(() {});
  }

  void _replayNarration(String text, String lang) {
    HapticHelper.light();
    _narration.speak(
      text: text,
      language: lang,
      onComplete: () {
        if (mounted) setState(() {});
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final isHindi = gameState.isHindi;
    final panel = currentPanel;
    final hasBgImage = panel.backgroundImage != null && panel.backgroundImage!.isNotEmpty;
    final narrationText = isHindi ? panel.narrationRegional : panel.narrationEn;
    final langCode = isHindi ? 'hi' : 'en';

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
              // Panel header / Chapter title & Narration HUD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Scene Title Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primary, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text('📖 ', style: TextStyle(fontSize: 14)),
                          Text(
                            widget.step.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Read To Me & Replay Controls
                    ValueListenableBuilder<NarrationStatus>(
                      valueListenable: _narration.statusNotifier,
                      builder: (context, status, _) {
                        String label = isHindi ? 'सुनाओ' : 'Read to Me';
                        IconData icon = Icons.volume_up_rounded;
                        Color buttonColor = AppTheme.primaryDark;

                        if (status == NarrationStatus.loading) {
                          label = isHindi ? 'लोड हो रहा...' : 'Loading...';
                          icon = Icons.hourglass_top_rounded;
                          buttonColor = Colors.grey;
                        } else if (status == NarrationStatus.playing) {
                          label = isHindi ? 'रोकें' : 'Pause';
                          icon = Icons.pause_circle_filled_rounded;
                          buttonColor = AppTheme.primaryDark;
                        } else if (status == NarrationStatus.paused) {
                          label = isHindi ? 'जारी रखें' : 'Resume';
                          icon = Icons.play_circle_fill_rounded;
                          buttonColor = const Color(0xFF00A896);
                        }

                        final isLoading = status == NarrationStatus.loading;

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              icon: Icon(icon, size: 20, color: buttonColor),
                              label: Text(
                                label,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: buttonColor,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.95),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: status == NarrationStatus.playing
                                        ? AppTheme.primary
                                        : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () => _handleNarrationToggle(narrationText, langCode),
                            ),
                            if (status != NarrationStatus.idle) ...[
                              const SizedBox(width: 6),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade300, width: 1.2),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.replay_rounded, size: 18),
                                  tooltip: isHindi ? 'फिर से सुनें' : 'Replay Narration',
                                  color: AppTheme.textDark,
                                  onPressed: () => _replayNarration(narrationText, langCode),
                                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
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
                        ValueListenableBuilder<NarrationStatus>(
                          valueListenable: _narration.statusNotifier,
                          builder: (context, status, _) {
                            final isPlaying = status == NarrationStatus.playing;
                            return Positioned(
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
                                    isNarrating: isPlaying,
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Bottom Narration Box with Word-by-Word Synchronized Highlighting
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.97),
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
                    // Synchronized Word Highlighting Display
                    ValueListenableBuilder<NarrationStatus>(
                      valueListenable: _narration.statusNotifier,
                      builder: (context, status, _) {
                        return ValueListenableBuilder<int>(
                          valueListenable: _narration.currentWordIndexNotifier,
                          builder: (context, activeWordIdx, _) {
                            final isSpeaking = status == NarrationStatus.playing ||
                                status == NarrationStatus.paused;
                            return _buildHighlightedNarrationText(
                              narrationText,
                              activeWordIdx,
                              isSpeaking,
                            );
                          },
                        );
                      },
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

  /// Builds narration text with smooth, child-friendly word-by-word highlighting.
  Widget _buildHighlightedNarrationText(
    String fullText,
    int activeWordIdx,
    bool isNarrating,
  ) {
    if (!isNarrating || activeWordIdx < 0) {
      return Text(
        fullText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          height: 1.45,
          fontWeight: FontWeight.w600,
          color: AppTheme.textDark,
        ),
      );
    }

    final words = fullText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: List.generate(words.length, (i) {
        final isCurrent = i == activeWordIdx;
        final isPast = i < activeWordIdx;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutQuad,
          padding: EdgeInsets.symmetric(
            horizontal: isCurrent ? 8 : 2,
            vertical: isCurrent ? 3 : 1,
          ),
          decoration: BoxDecoration(
            color: isCurrent
                ? const Color(0xFFFFE082)
                : (isPast ? const Color(0xFFF1F8E9) : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: isCurrent
                ? Border.all(color: const Color(0xFFFFB300), width: 1.5)
                : null,
          ),
          child: Text(
            words[i],
            style: TextStyle(
              fontSize: isCurrent ? 17.5 : 16,
              fontWeight: isCurrent
                  ? FontWeight.w900
                  : (isPast ? FontWeight.bold : FontWeight.w500),
              color: isCurrent
                  ? const Color(0xFF5D4037)
                  : (isPast ? AppTheme.textDark : AppTheme.textDark.withOpacity(0.7)),
            ),
          ),
        );
      }),
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
