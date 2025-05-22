import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tank_battle/services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settings = SettingsService();
  bool _isLoading = true;

  // Settings values
  late double _musicVolume;
  late double _sfxVolume;
  late bool _vibrationEnabled;
  late String _selectedDifficulty;
  late bool _showFrameRate;
  late String _selectedControlScheme;

  final List<String> _difficulties = ['Easy', 'Medium', 'Hard', 'Extreme'];
  final List<String> _controlSchemes = [
    'Virtual Joystick',
    'Tap to Move',
    'Swipe',
    'Arrow Keys'
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Initialize settings service if not already initialized
    if (!_settings.isInitialized) {
      await _settings.init();
    }

    // Load saved settings
    setState(() {
      _musicVolume = _settings.musicVolume;
      _sfxVolume = _settings.sfxVolume;
      _vibrationEnabled = _settings.vibrationEnabled;
      _selectedDifficulty = _settings.difficulty;
      _showFrameRate = _settings.showFrameRate;
      _selectedControlScheme = _settings.controlScheme;
      _isLoading = false;
    });
  }

  // Provide haptic feedback when toggling settings
  void _triggerHapticFeedback() {
    if (_vibrationEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        backgroundColor: Colors.black87,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Reset button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _showResetConfirmationDialog,
            tooltip: 'Reset to Defaults',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.blue.shade900.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('AUDIO'),
                _buildSliderSetting(
                  'Music Volume',
                  _musicVolume,
                      (value) {
                    _triggerHapticFeedback();
                    setState(() {
                      _musicVolume = value;
                    });
                    // Apply music volume in real-time (no need to wait for save)
                    // TODO: Implement audio service integration if needed
                  },
                  Icons.music_note,
                ),
                _buildSliderSetting(
                  'SFX Volume',
                  _sfxVolume,
                      (value) {
                    _triggerHapticFeedback();
                    setState(() {
                      _sfxVolume = value;
                    });
                    // TODO: Implement audio service integration if needed
                  },
                  Icons.volume_up,
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('GAMEPLAY'),
                _buildDropdownSetting(
                  'Difficulty',
                  _selectedDifficulty,
                  _difficulties,
                      (value) {
                    _triggerHapticFeedback();
                    setState(() {
                      _selectedDifficulty = value!;
                    });
                  },
                  Icons.speed,
                ),
                _buildDropdownSetting(
                  'Control Scheme',
                  _selectedControlScheme,
                  _controlSchemes,
                      (value) {
                    _triggerHapticFeedback();
                    setState(() {
                      _selectedControlScheme = value!;
                    });
                  },
                  Icons.gamepad,
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('MISCELLANEOUS'),
                _buildSwitchSetting(
                  'Vibration',
                  _vibrationEnabled,
                      (value) {
                    setState(() {
                      _vibrationEnabled = value;
                    });
                    if (value) {
                      HapticFeedback.mediumImpact();
                    }
                  },
                  Icons.vibration,
                ),
                _buildSwitchSetting(
                  'Show Frame Rate',
                  _showFrameRate,
                      (value) {
                    _triggerHapticFeedback();
                    setState(() {
                      _showFrameRate = value;
                    });
                  },
                  Icons.speed,
                ),
                const SizedBox(height: 30),

                Center(
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'SAVE SETTINGS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 2,
              color: Colors.amber.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(
      String title,
      double value,
      Function(double) onChanged,
      IconData icon,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blue.shade900, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '${(value * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.blue.shade400,
              inactiveColor: Colors.grey.shade800,
              thumbColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(
      String title,
      bool value,
      Function(bool) onChanged,
      IconData icon,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blue.shade900, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue.shade400,
            activeTrackColor: Colors.blue.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting(
      String title,
      String currentValue,
      List<String> options,
      Function(String?) onChanged,
      IconData icon,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blue.shade900, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(color: Colors.blue.shade800),
            ),
            child: DropdownButton<String>(
              value: currentValue,
              onChanged: onChanged,
              dropdownColor: Colors.black87,
              style: const TextStyle(color: Colors.white),
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          'Reset Settings?',
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will restore all settings to their default values.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
            ),
            child: const Text('Reset'),
            onPressed: () {
              Navigator.pop(context);
              _resetToDefaults();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _resetToDefaults() async {
    setState(() => _isLoading = true);

    await _settings.resetToDefaults();

    // Reload settings from service
    await _loadSettings();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings reset to defaults'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      await _settings.applySettings(
        musicVolume: _musicVolume,
        sfxVolume: _sfxVolume,
        vibrationEnabled: _vibrationEnabled,
        difficulty: _selectedDifficulty,
        showFrameRate: _showFrameRate,
        controlScheme: _selectedControlScheme,
      );

      setState(() => _isLoading = false);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );

      // Optional: Return to previous screen
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: $e'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}