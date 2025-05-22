import 'package:shared_preferences/shared_preferences.dart';

class StatsService {
  static final StatsService _instance = StatsService._internal();
  factory StatsService() => _instance;
  StatsService._internal();

  // Game statistics
  int _gamesPlayed = 0;
  int _gamesWon = 0;
  int _enemiesDestroyed = 0;
  int _totalPlayTime = 0; // in seconds
  int _bestScore = 0;
  double _bestTime = 0; // in seconds

  // Getters
  int get gamesPlayed => _gamesPlayed;
  int get gamesWon => _gamesWon;
  int get enemiesDestroyed => _enemiesDestroyed;
  int get totalPlayTime => _totalPlayTime;
  int get bestScore => _bestScore;
  double get bestTime => _bestTime;

  double get winRate => _gamesPlayed > 0 ? (_gamesWon / _gamesPlayed) * 100 : 0;

  Future<void> recordGamePlayed() async {
    _gamesPlayed++;
    await _saveStats();
  }

  Future<void> recordGameWon() async {
    _gamesWon++;
    await _saveStats();
  }

  Future<void> recordEnemyDestroyed() async {
    _enemiesDestroyed++;
    await _saveStats();
  }

  Future<void> recordPlayTime(int seconds) async {
    _totalPlayTime += seconds;
    await _saveStats();
  }

  Future<void> recordScore(int score) async {
    if (score > _bestScore) {
      _bestScore = score;
      await _saveStats();
    }
  }

  Future<void> recordTime(double time) async {
    if (_bestTime == 0 || time < _bestTime) {
      _bestTime = time;
      await _saveStats();
    }
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('games_played', _gamesPlayed);
    await prefs.setInt('games_won', _gamesWon);
    await prefs.setInt('enemies_destroyed', _enemiesDestroyed);
    await prefs.setInt('total_play_time', _totalPlayTime);
    await prefs.setInt('best_score', _bestScore);
    await prefs.setDouble('best_time', _bestTime);
  }

  Future<void> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    _gamesPlayed = prefs.getInt('games_played') ?? 0;
    _gamesWon = prefs.getInt('games_won') ?? 0;
    _enemiesDestroyed = prefs.getInt('enemies_destroyed') ?? 0;
    _totalPlayTime = prefs.getInt('total_play_time') ?? 0;
    _bestScore = prefs.getInt('best_score') ?? 0;
    _bestTime = prefs.getDouble('best_time') ?? 0;
  }
}