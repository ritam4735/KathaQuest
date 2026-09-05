import 'dart:math';
import 'package:flutter/foundation.dart';

/// Centralized in-game scoring system for real-time tracking, streak multipliers,
/// star calculations, and reward distributions.
class GameScoreManager extends ChangeNotifier {
  final int targetScore;
  final int bestScore;

  int _score = 0;
  int _combo = 0;
  int _highestCombo = 0;
  int _itemsCollected = 0;
  int _obstaclesHit = 0;
  int _lives = 3;
  final int maxLives;

  GameScoreManager({
    required this.targetScore,
    this.bestScore = 0,
    this.maxLives = 3,
  }) : _lives = maxLives;

  int get score => _score;
  int get combo => _combo;
  int get highestCombo => _highestCombo;
  int get itemsCollected => _itemsCollected;
  int get obstaclesHit => _obstaclesHit;
  int get lives => _lives;
  bool get isDead => _lives <= 0;

  double get progressRatio => (targetScore > 0) ? (_score / targetScore).clamp(0.0, 1.0) : 0.0;

  void addPoints(int points, {bool isItem = false}) {
    if (isItem) {
      _itemsCollected++;
      _combo++;
      _highestCombo = max(_highestCombo, _combo);
    }
    final double multiplier = (_combo >= 8) ? 3.0 : ((_combo >= 5) ? 2.0 : ((_combo >= 3) ? 1.5 : 1.0));
    final delta = (points > 0) ? (points * multiplier).round() : points;
    _score = max(0, _score + delta);
    notifyListeners();
  }

  void loseLife([int amount = 1]) {
    _lives = max(0, _lives - amount);
    _combo = 0; // Break combo streak on damage
    _obstaclesHit += amount;
    notifyListeners();
  }

  void resetCombo() {
    if (_combo > 0) {
      _combo = 0;
      notifyListeners();
    }
  }

  void healLife([int amount = 1]) {
    _lives = min(maxLives, _lives + amount);
    notifyListeners();
  }

  /// Calculates star rating (1 to 3 stars) based on score achievement and remaining health.
  int calculateStars() {
    if (_lives <= 0) return 0;
    if (_score >= (targetScore * 1.3).round() && _lives >= 2) {
      return 3;
    } else if (_score >= targetScore) {
      return 2;
    } else {
      return 1;
    }
  }

  int calculateCoinsReward() {
    final baseCoins = (_score / 5).round().clamp(10, 100);
    final bonus = calculateStars() * 10;
    return baseCoins + bonus;
  }

  void reset() {
    _score = 0;
    _combo = 0;
    _highestCombo = 0;
    _itemsCollected = 0;
    _obstaclesHit = 0;
    _lives = maxLives;
    notifyListeners();
  }
}
