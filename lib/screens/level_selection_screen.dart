import 'package:flutter/material.dart';
import 'package:tank_battle/screens/game_screen.dart';
import 'package:tank_battle/widgets/game_button.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  int selectedLevel = 1;

  final List<Map<String, dynamic>> levels = [
    {
      'level': 1,
      'name': 'Desert Storm',
      'description': 'Basic tank combat in open desert terrain',
      'difficulty': 'Easy',
      'enemies': 3,
      'unlocked': true,
      'stars': 3,
      'bestTime': '2:34',
      'background': 'desert',
    },
    {
      'level': 2,
      'name': 'Urban Warfare',
      'description': 'Fight through city streets with cover',
      'difficulty': 'Easy',
      'enemies': 4,
      'unlocked': true,
      'stars': 2,
      'bestTime': '3:12',
      'background': 'city',
    },
    {
      'level': 3,
      'name': 'Forest Ambush',
      'description': 'Navigate dense forest with limited visibility',
      'difficulty': 'Medium',
      'enemies': 5,
      'unlocked': true,
      'stars': 1,
      'bestTime': '4:56',
      'background': 'forest',
    },
    {
      'level': 4,
      'name': 'Mountain Pass',
      'description': 'High altitude combat with narrow paths',
      'difficulty': 'Medium',
      'enemies': 6,
      'unlocked': true,
      'stars': 0,
      'bestTime': null,
      'background': 'mountain',
    },
    {
      'level': 5,
      'name': 'Arctic Base',
      'description': 'Frozen battlefield with reduced traction',
      'difficulty': 'Hard',
      'enemies': 7,
      'unlocked': false,
      'stars': 0,
      'bestTime': null,
      'background': 'arctic',
    },
    {
      'level': 6,
      'name': 'Nuclear Zone',
      'description': 'Radioactive wasteland with dangerous terrain',
      'difficulty': 'Hard',
      'enemies': 8,
      'unlocked': false,
      'stars': 0,
      'bestTime': null,
      'background': 'nuclear',
    },
    {
      'level': 7,
      'name': 'Space Station',
      'description': 'Zero gravity combat in orbital facility',
      'difficulty': 'Extreme',
      'enemies': 10,
      'unlocked': false,
      'stars': 0,
      'bestTime': null,
      'background': 'space',
    },
    {
      'level': 8,
      'name': 'Final Boss',
      'description': 'Face the ultimate tank commander',
      'difficulty': 'Boss',
      'enemies': 1,
      'unlocked': false,
      'stars': 0,
      'bestTime': null,
      'background': 'boss',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SELECT LEVEL',
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
              Colors.green.shade900.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          children: [
            // Level grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final level = levels[index];
                  return _buildLevelCard(level);
                },
              ),
            ),

            // Selected level info and play button
            if (selectedLevel > 0) _buildSelectedLevelInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(Map<String, dynamic> level) {
    final isSelected = selectedLevel == level['level'];
    final isUnlocked = level['unlocked'] as bool;

    return GestureDetector(
      onTap: isUnlocked ? () {
        setState(() {
          selectedLevel = level['level'];
        });
      } : null,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? (isSelected ? Colors.blue.shade700 : Colors.black54)
              : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.blue.shade300
                : (isUnlocked ? Colors.green.shade700 : Colors.grey.shade600),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.blue.shade400.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Stack(
          children: [
            // Lock overlay for locked levels
            if (!isUnlocked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock,
                    color: Colors.grey,
                    size: 48,
                  ),
                ),
              ),

            // Level content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Level number and difficulty
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(level['difficulty']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${level['level']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (isUnlocked) _buildStarsDisplay(level['stars']),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Level name
                  Text(
                    level['name'],
                    style: TextStyle(
                      color: isUnlocked ? Colors.white : Colors.grey.shade400,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Difficulty badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(level['difficulty']).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _getDifficultyColor(level['difficulty']),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      level['difficulty'],
                      style: TextStyle(
                        color: _getDifficultyColor(level['difficulty']),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Enemy count and best time
                  if (isUnlocked) ...[
                    Row(
                      children: [
                        const Icon(Icons.group, color: Colors.red, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${level['enemies']}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        const Spacer(),
                        if (level['bestTime'] != null) ...[
                          const Icon(Icons.timer, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            level['bestTime'],
                            style: const TextStyle(color: Colors.amber, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarsDisplay(int stars) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Icon(
          index < stars ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      case 'Extreme':
        return Colors.purple;
      case 'Boss':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSelectedLevelInfo() {
    final level = levels.firstWhere((l) => l['level'] == selectedLevel);
    final isUnlocked = level['unlocked'] as bool;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade700, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level['description'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUnlocked) _buildStarsDisplay(level['stars']),
            ],
          ),

          const SizedBox(height: 12),

          // Level stats
          Row(
            children: [
              _buildStatChip('Difficulty', level['difficulty'],
                  _getDifficultyColor(level['difficulty'])),
              const SizedBox(width: 8),
              _buildStatChip('Enemies', '${level['enemies']}', Colors.red),
              if (level['bestTime'] != null) ...[
                const SizedBox(width: 8),
                _buildStatChip('Best Time', level['bestTime'], Colors.amber),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Play button
          SizedBox(
            width: double.infinity,
            child: GameButton(
              text: isUnlocked ? 'PLAY LEVEL' : 'LOCKED',
              icon: isUnlocked ? Icons.play_arrow : Icons.lock,
              onPressed: isUnlocked ? () => _playLevel(level) : () {},
              color: isUnlocked ? Colors.green.shade700 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _playLevel(Map<String, dynamic> level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          levelData: level,
        ),
      ),
    );
  }
}