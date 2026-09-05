import 'package:flutter/foundation.dart';

/// Gameplay states across all KathaQuest mini-games.
enum MiniGameState {
  ready,      // Pre-game countdown (3-2-1 Go!)
  playing,    // Active gameplay & physics loop
  paused,     // Suspended gameplay
  gameOver,   // Failed objectives or ran out of lives
  completed,  // Successfully reached objective/target score
}

/// State machine manager handling lifecycle transitions and callbacks.
class GameStateMachine extends ChangeNotifier {
  MiniGameState _state = MiniGameState.ready;
  String? _failureReason;
  int _starsEarned = 3;

  MiniGameState get state => _state;
  String? get failureReason => _failureReason;
  int get starsEarned => _starsEarned;

  bool get isReady => _state == MiniGameState.ready;
  bool get isPlaying => _state == MiniGameState.playing;
  bool get isPaused => _state == MiniGameState.paused;
  bool get isGameOver => _state == MiniGameState.gameOver;
  bool get isCompleted => _state == MiniGameState.completed;

  void startCountdown() {
    _state = MiniGameState.ready;
    _failureReason = null;
    notifyListeners();
  }

  void startGame() {
    _state = MiniGameState.playing;
    notifyListeners();
  }

  void pauseGame() {
    if (_state == MiniGameState.playing) {
      _state = MiniGameState.paused;
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_state == MiniGameState.paused) {
      _state = MiniGameState.playing;
      notifyListeners();
    }
  }

  void triggerGameOver(String reason) {
    if (_state != MiniGameState.completed && _state != MiniGameState.gameOver) {
      _state = MiniGameState.gameOver;
      _failureReason = reason;
      notifyListeners();
    }
  }

  void triggerCompletion({int stars = 3}) {
    if (_state != MiniGameState.gameOver && _state != MiniGameState.completed) {
      _state = MiniGameState.completed;
      _starsEarned = stars.clamp(1, 3);
      notifyListeners();
    }
  }

  void restart() {
    _state = MiniGameState.ready;
    _failureReason = null;
    _starsEarned = 3;
    notifyListeners();
  }
}
