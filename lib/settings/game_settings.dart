import 'package:tank_battle/services/settings_service.dart';

/// Game settings class that uses SettingsService to apply settings to the game.
class GameSettings {
  static final GameSettings _instance = GameSettings._internal();
  factory GameSettings() => _instance;
  GameSettings._internal();

  final SettingsService _settings = SettingsService();

  // Audio settings
  double get musicVolume => _settings.musicVolume;
  double get sfxVolume => _settings.sfxVolume;

  // Gameplay settings
  bool get vibrationEnabled => _settings.vibrationEnabled;
  String get difficulty => _settings.difficulty;
  String get controlScheme => _settings.controlScheme;
  bool get showFrameRate => _settings.showFrameRate;

  // Difficulty-based game parameters
  double getDifficultyMultiplier() {
    switch (difficulty) {
      case 'Easy':
        return 0.75;
      case 'Medium':
        return 1.0;
      case 'Hard':
        return 1.5;
      case 'Extreme':
        return 2.0;
      default:
        return 1.0;
    }
  }

  // Enemy settings based on difficulty
  int getEnemyCount() {
    switch (difficulty) {
      case 'Easy':
        return 3;
      case 'Medium':
        return 5;
      case 'Hard':
        return 8;
      case 'Extreme':
        return 12;
      default:
        return 5;
    }
  }

  int getEnemyHealth() {
    switch (difficulty) {
      case 'Easy':
        return 30;
      case 'Medium':
        return 50;
      case 'Hard':
        return 75;
      case 'Extreme':
        return 100;
      default:
        return 50;
    }
  }

  double getEnemySpeed() {
    switch (difficulty) {
      case 'Easy':
        return 80;
      case 'Medium':
        return 100;
      case 'Hard':
        return 120;
      case 'Extreme':
        return 150;
      default:
        return 100;
    }
  }

  double getEnemyFireRate() {
    switch (difficulty) {
      case 'Easy':
        return 2.0;
      case 'Medium':
        return 1.5;
      case 'Hard':
        return 1.0;
      case 'Extreme':
        return 0.75;
      default:
        return 1.5;
    }
  }

  // Control scheme helpers
  bool shouldUseVirtualJoystick() {
    return controlScheme == 'Virtual Joystick';
  }

  bool shouldUseTapToMove() {
    return controlScheme == 'Tap to Move';
  }

  bool shouldUseSwipeControls() {
    return controlScheme == 'Swipe';
  }

  bool shouldUseKeyboardControls() {
    return controlScheme == 'Arrow Keys';
  }

  // Initialize settings
  Future<void> init() async {
    if (!_settings.isInitialized) {
      await _settings.init();
    }
  }
}