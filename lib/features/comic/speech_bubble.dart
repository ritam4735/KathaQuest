import 'package:flutter/material.dart';
import '../../widgets/magical_speech_bubble.dart';

export '../../widgets/magical_speech_bubble.dart';

/// Enhanced glowing magical speech bubble for story comic dialogues and minigames.
class SpeechBubble extends StatelessWidget {
  final String speaker;
  final String avatar;
  final String text;
  final bool isLeft;
  final bool isNarrating;

  const SpeechBubble({
    super.key,
    required this.speaker,
    required this.avatar,
    required this.text,
    this.isLeft = true,
    this.isNarrating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: MagicalSpeechBubble(
        speaker: speaker,
        avatar: avatar,
        text: text,
        isLeft: isLeft,
        isNarrating: isNarrating,
        tailDirection: isLeft ? BubbleTailDirection.left : BubbleTailDirection.right,
        animatePulse: isNarrating,
      ),
    );
  }
}
