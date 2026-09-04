import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/haptic_feedback_helper.dart';
import '../state/game_state.dart';

class ParentCornerScreen extends StatefulWidget {
  const ParentCornerScreen({super.key});

  @override
  State<ParentCornerScreen> createState() => _ParentCornerScreenState();
}

class _ParentCornerScreenState extends State<ParentCornerScreen> {
  bool _isUnlocked = false;
  final TextEditingController _mathController = TextEditingController();
  final Random _random = Random();
  late int _num1;
  late int _num2;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _generateMathProblem();
  }

  void _generateMathProblem() {
    _num1 = 2 + _random.nextInt(6); // 2 to 7
    _num2 = 1 + _random.nextInt(7); // 1 to 7
  }

  void _verifyParentGate() {
    HapticHelper.light();
    final ans = int.tryParse(_mathController.text.trim());
    if (ans == (_num1 + _num2)) {
      HapticHelper.success();
      setState(() {
        _isUnlocked = true;
        _errorMessage = '';
      });
    } else {
      setState(() {
        _generateMathProblem();
        _mathController.clear();
        _errorMessage = 'Incorrect answer. Try again with this new question:';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final profile = gameState.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Corner 👨‍👩‍👧'),
        backgroundColor: Colors.white,
      ),
      body: !_isUnlocked ? _buildParentGate() : _buildDashboard(gameState, profile),
    );
  }

  Widget _buildParentGate() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(28),
          decoration: AppTheme.kidCardDecoration(
            color: Colors.white,
            borderColor: AppTheme.primary,
            radius: 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔒', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text(
                'Parent Verification',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please solve this simple math problem to access parent settings and learning analytics:',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textLight, fontSize: 14),
              ),
              const SizedBox(height: 20),
              Text(
                '$_num1 + $_num2 = ?',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _mathController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'Enter answer',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onSubmitted: (_) => _verifyParentGate(),
              ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _verifyParentGate,
                  child: const Text('Access Dashboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(GameState gameState, dynamic profile) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Child Profile Header Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.kidCardDecoration(
            color: Colors.white,
            borderColor: AppTheme.secondary,
            radius: 24,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: Text(profile.avatarEmoji, style: const TextStyle(fontSize: 40)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.playerName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '⭐ ${profile.totalStars} Stars  •  📚 ${profile.storiesCompleted} Stories Read',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Screen Time & Analytics Card connected to LocalDatabase
        const Text(
          'Learning & Screen Time Analytics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: '⏱️',
                title: "Today's Time",
                value: '${profile.screenTimeMinutesToday} mins',
                subtitle: 'Daily target: 30m',
                color: const Color(0xFF2EC4B6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: '📖',
                title: 'Total Reading',
                value: '${profile.totalReadingMinutes} mins',
                subtitle: 'All time',
                color: const Color(0xFFFF9F1C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: '🎓',
                title: 'Quizzes Taken',
                value: '${gameState.database.analytics.quizzesAttempted}',
                subtitle: '${gameState.database.analytics.totalQuizQuestions} questions total',
                color: const Color(0xFF4361EE),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: '🎯',
                title: 'Comprehension',
                value: gameState.database.analytics.totalQuizQuestions > 0
                    ? '${((gameState.database.analytics.totalQuizCorrect / gameState.database.analytics.totalQuizQuestions) * 100).round()}%'
                    : '100%',
                subtitle: 'Accuracy rate',
                color: const Color(0xFF06D6A0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Badges Unlocked Section
        const Text(
          'Badges & Achievements',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: profile.unlockedBadges.map<Widget>((badge) {
            return Chip(
              avatar: const Text('🏅'),
              label: Text(badge, style: const TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: const Color(0xFFFFF9E6),
              side: const BorderSide(color: Color(0xFFFFD166)),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Audio & Accessibility Settings Card
        const Text(
          'Audio & Language Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.kidCardDecoration(
            color: Colors.white,
            radius: 20,
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.music_note_rounded, color: AppTheme.primary),
                title: const Text('Background Music (BGM)'),
                trailing: Switch(
                  value: profile.isBgmEnabled,
                  activeColor: AppTheme.primary,
                  onChanged: (_) => gameState.toggleBgm(),
                ),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.volume_up_rounded, color: AppTheme.secondary),
                title: const Text('Sound Effects (SFX)'),
                trailing: Switch(
                  value: profile.isSfxEnabled,
                  activeColor: AppTheme.secondary,
                  onChanged: (_) => gameState.toggleSfx(),
                ),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.record_voice_over_rounded, color: AppTheme.primaryDark),
                title: const Text('Read-Aloud Narration'),
                trailing: Switch(
                  value: profile.isNarrationEnabled,
                  activeColor: AppTheme.primaryDark,
                  onChanged: (_) => gameState.toggleNarration(),
                ),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.translate_rounded, color: Color(0xFF7209B7)),
                title: const Text('Default Story Language'),
                trailing: DropdownButton<String>(
                  value: profile.selectedLanguage,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'hi', child: Text('हिंदी (Hindi)')),
                  ],
                  onChanged: (val) {
                    if (val != null && val != profile.selectedLanguage) {
                      gameState.toggleLanguage();
                    }
                  },
                ),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.timer_outlined, color: Color(0xFF2EC4B6)),
                title: const Text('Daily Screen Time Allowance'),
                trailing: DropdownButton<int>(
                  value: profile.screenTimeLimitMinutes,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 15, child: Text('15 minutes')),
                    DropdownMenuItem(value: 30, child: Text('30 minutes')),
                    DropdownMenuItem(value: 45, child: Text('45 minutes')),
                    DropdownMenuItem(value: 60, child: Text('60 minutes')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      gameState.setScreenTimeLimit(val);
                    }
                  },
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Narration Speed',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${profile.narrationSpeed.toStringAsFixed(1)}x',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Slider(
                      value: profile.narrationSpeed,
                      min: 0.8,
                      max: 1.5,
                      divisions: 7,
                      activeColor: AppTheme.primary,
                      onChanged: (val) => gameState.setNarrationSpeed(val),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Parental Account Management & Reset
        const Text(
          'Account & Database Reset',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.kidCardDecoration(
            color: Colors.white,
            borderColor: Colors.red.shade200,
            radius: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reset All Student Data',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFFC62828),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Clears all local database progress, quiz records, unlocked badges, and resets KathaQuest to default starter state.',
                style: TextStyle(fontSize: 12, color: AppTheme.textLight),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_forever_rounded, color: Color(0xFFC62828)),
                  label: const Text(
                    'Reset Progress to Default',
                    style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF9A9A), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    _showResetConfirmation(context, gameState);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showResetConfirmation(BuildContext context, GameState gameState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Progress?'),
        content: const Text(
          'Are you sure you want to reset all progress, stars, badges, and learning analytics? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await gameState.resetAllProgress();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All progress and database records have been reset to defaults.'),
                    backgroundColor: Color(0xFF2E7D32),
                  ),
                );
              }
            },
            child: const Text('Reset Everything', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }
}
