// Add shared_preferences package to pubspec.yaml:
// shared_preferences: ^2.2.3
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // Singleton instance
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  // Keys for SharedPreferences
  static const String _musicVolumeKey = 'music_volume';
  static const String _sfxVolumeKey = 'sfx_volume';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _difficultyKey = 'difficulty';
  static const String _showFrameRateKey = 'show_frame_rate';
  static const String _controlSchemeKey = 'control_scheme';

  // Default values
  static const double defaultMusicVolume = 0.7;
  static const double defaultSfxVolume = 0.8;
  static const bool defaultVibrationEnabled = true;
  static const String defaultDifficulty = 'Medium';
  static const bool defaultShowFrameRate = false;
  static const String defaultControlScheme = 'Virtual Joystick';

  late SharedPreferences _prefs;
  bool _initialized = false;

  // Initialize the service
  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  // Check if service is initialized
  bool get isInitialized => _initialized;

  // Getters
  double get musicVolume => _prefs.getDouble(_musicVolumeKey) ?? defaultMusicVolume;
  double get sfxVolume => _prefs.getDouble(_sfxVolumeKey) ?? defaultSfxVolume;
  bool get vibrationEnabled => _prefs.getBool(_vibrationEnabledKey) ?? defaultVibrationEnabled;
  String get difficulty => _prefs.getString(_difficultyKey) ?? defaultDifficulty;
  bool get showFrameRate => _prefs.getBool(_showFrameRateKey) ?? defaultShowFrameRate;
  String get controlScheme => _prefs.getString(_controlSchemeKey) ?? defaultControlScheme;

  // Setters
  Future<bool> setMusicVolume(double value) => _prefs.setDouble(_musicVolumeKey, value);
  Future<bool> setSfxVolume(double value) => _prefs.setDouble(_sfxVolumeKey, value);
  Future<bool> setVibrationEnabled(bool value) => _prefs.setBool(_vibrationEnabledKey, value);
  Future<bool> setDifficulty(String value) => _prefs.setString(_difficultyKey, value);
  Future<bool> setShowFrameRate(bool value) => _prefs.setBool(_showFrameRateKey, value);
  Future<bool> setControlScheme(String value) => _prefs.setString(_controlSchemeKey, value);

  // Apply settings (useful when applying multiple settings at once)
  Future<void> applySettings({
    double? musicVolume,
    double? sfxVolume,
    bool? vibrationEnabled,
    String? difficulty,
    bool? showFrameRate,
    String? controlScheme,
  }) async {
    if (musicVolume != null) await setMusicVolume(musicVolume);
    if (sfxVolume != null) await setSfxVolume(sfxVolume);
    if (vibrationEnabled != null) await setVibrationEnabled(vibrationEnabled);
    if (difficulty != null) await setDifficulty(difficulty);
    if (showFrameRate != null) await setShowFrameRate(showFrameRate);
    if (controlScheme != null) await setControlScheme(controlScheme);
  }

  // Reset all settings to default
  Future<void> resetToDefaults() async {
    await setMusicVolume(defaultMusicVolume);
    await setSfxVolume(defaultSfxVolume);
    await setVibrationEnabled(defaultVibrationEnabled);
    await setDifficulty(defaultDifficulty);
    await setShowFrameRate(defaultShowFrameRate);
    await setControlScheme(defaultControlScheme);
  }
}