import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _musicVolume = 0.7;
  double _sfxVolume = 0.8;
  bool _vibrationEnabled = true;
  String _selectedDifficulty = 'Medium';
  bool _showFrameRate = false;
  String _selectedControlScheme = 'Virtual Joystick';

  final List<String> _difficulties = ['Easy', 'Medium', 'Hard', 'Extreme'];
  final List<String> _controlSchemes = [
    'Virtual Joystick',
    'Tap to Move',
    'Swipe',
    'Arrow Keys'
  ];

  @override
  Widget build(BuildContext context) {
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
                    setState(() {
                      _musicVolume = value;
                    });
                  },
                  Icons.music_note,
                ),
                _buildSliderSetting(
                  'SFX Volume',
                  _sfxVolume,
                      (value) {
                    setState(() {
                      _sfxVolume = value;
                    });
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
                  },
                  Icons.vibration,
                ),
                _buildSwitchSetting(
                  'Show Frame Rate',
                  _showFrameRate,
                      (value) {
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
                          horizontal: 30, vertical: 15),
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
      child: Text(
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
    );
  }

  Widget _buildSliderSetting(String title,
      double value,
      Function(double) onChanged,
      IconData icon,) {
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
          Slider(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue.shade400,
            inactiveColor: Colors.grey.shade800,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(String title,
      bool value,
      Function(bool) onChanged,
      IconData icon,) {
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

  Widget _buildDropdownSetting(String title,
      String currentValue,
      List<String> options,
      Function(String?) onChanged,
      IconData icon,) {
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

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }
}