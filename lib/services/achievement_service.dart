import 'package:shared_preferences/shared_preferences.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int points;
  bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    this.isUnlocked = false,
  });
}

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final List<Achievement> _achievements = [
    Achievement(
      id: 'first_kill',
      title: 'First Blood',
      description: 'Destroy your first enemy tank',
      icon: '🎯',
      points: 10,
    ),
    Achievement(
      id: 'survivor',
      title: 'Survivor',
      description: 'Complete a level without taking damage',
      icon: '🛡️',
      points: 25,
    ),
    Achievement(
      id: 'speed_demon',
      title: 'Speed Demon',
      description: 'Complete a level in under 2 minutes',
      icon: '⚡',
      points: 30,
    ),
    Achievement(
      id: 'tank_destroyer',
      title: 'Tank Destroyer',
      description: 'Destroy 100 enemy tanks',
      icon: '💥',
      points: 50,
    ),
    Achievement(
      id: 'completionist',
      title: 'Completionist',
      description: 'Complete all levels with 3 stars',
      icon: '⭐',
      points: 100,
    ),
  ];

  List<Achievement> get achievements => _achievements;

  Future<void> checkAchievement(String achievementId) async {
    final achievement = _achievements.firstWhere((a) => a.id == achievementId);
    if (!achievement.isUnlocked) {
      achievement.isUnlocked = true;
      await _saveAchievements();
      // Show achievement notification
    }
  }

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedIds = _achievements.where((a) => a.isUnlocked).map((a) => a.id).toList();
    await prefs.setStringList('unlocked_achievements', unlockedIds);
  }

  Future<void> loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedIds = prefs.getStringList('unlocked_achievements') ?? [];

    for (var achievement in _achievements) {
      achievement.isUnlocked = unlockedIds.contains(achievement.id);
    }
  }
}