import 'package:flutter/material.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTimeframe = 0; // 0: Today, 1: Week, 2: All Time

  final List<String> _timeframes = ['Today', 'This Week', 'All Time'];

  // Sample leaderboard data
  final Map<String, List<Map<String, dynamic>>> _leaderboardData = {
    'global': [
      {
        'rank': 1,
        'name': 'TankDestroyer',
        'score': 15420,
        'level': 47,
        'wins': 234,
        'kd': 3.8,
        'avatar': 'assets/images/player_tank.png',
        'badge': 'crown',
        'country': 'US',
      },
      {
        'rank': 2,
        'name': 'ArmorPiercer',
        'score': 14890,
        'level': 45,
        'wins': 198,
        'kd': 3.2,
        'avatar': 'assets/images/enemy_tank.png',
        'badge': 'medal',
        'country': 'DE',
      },
      {
        'rank': 3,
        'name': 'BattleQueen',
        'score': 14350,
        'level': 43,
        'wins': 187,
        'kd': 2.9,
        'avatar': 'assets/images/player_tank.png',
        'badge': 'bronze',
        'country': 'JP',
      },
      {
        'rank': 4,
        'name': 'SteelCommander',
        'score': 13920,
        'level': 41,
        'wins': 176,
        'kd': 2.7,
        'avatar': 'assets/images/enemy_tank.png',
        'badge': null,
        'country': 'RU',
      },
      {
        'rank': 5,
        'name': 'ThunderTank',
        'score': 13680,
        'level': 40,
        'wins': 165,
        'kd': 2.5,
        'avatar': 'assets/images/player_tank.png',
        'badge': null,
        'country': 'BR',
      },
    ],
    'friends': [
      {
        'rank': 1,
        'name': 'TankMaster42',
        'score': 8920,
        'level': 32,
        'wins': 89,
        'kd': 2.1,
        'avatar': 'assets/images/player_tank.png',
        'badge': null,
        'country': 'US',
      },
      {
        'rank': 2,
        'name': 'You',
        'score': 7650,
        'level': 28,
        'wins': 67,
        'kd': 1.8,
        'avatar': 'assets/images/enemy_tank.png',
        'badge': null,
        'country': 'US',
        'isPlayer': true,
      },
      {
        'rank': 3,
        'name': 'SharpShooter99',
        'score': 6890,
        'level': 25,
        'wins': 58,
        'kd': 1.6,
        'avatar': 'assets/images/player_tank.png',
        'badge': null,
        'country': 'CA',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LEADERBOARD',
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
          PopupMenuButton<int>(
            icon: const Icon(Icons.access_time),
            onSelected: (value) {
              setState(() {
                _selectedTimeframe = value;
              });
            },
            itemBuilder: (context) => _timeframes.asMap().entries.map((entry) {
              return PopupMenuItem<int>(
                value: entry.key,
                child: Row(
                  children: [
                    if (_selectedTimeframe == entry.key)
                      const Icon(Icons.check, color: Colors.green, size: 16),
                    if (_selectedTimeframe != entry.key)
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Text(entry.value),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(text: 'GLOBAL'),
            Tab(text: 'FRIENDS'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.amber.shade900.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          children: [
            // Timeframe indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.black54,
              child: Text(
                'Leaderboard - ${_timeframes[_selectedTimeframe]}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Leaderboard content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLeaderboardList('global'),
                  _buildLeaderboardList('friends'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(String type) {
    final data = _leaderboardData[type] ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final player = data[index];
        final isPlayer = player['isPlayer'] ?? false;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isPlayer ? Colors.blue.shade700.withOpacity(0.3) : Colors.black54,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPlayer ? Colors.blue.shade400 : Colors.amber.shade700,
              width: isPlayer ? 2 : 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rank
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getRankColor(player['rank']),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${player['rank']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Avatar with badge
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(player['avatar']),
                      backgroundColor: Colors.grey.shade800,
                    ),
                    if (player['badge'] != null)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _getBadgeColor(player['badge']),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Icon(
                            _getBadgeIcon(player['badge']),
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    player['name'],
                    style: TextStyle(
                      color: isPlayer ? Colors.blue.shade200 : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (player['country'] != null)
                  Text(
                    _getCountryFlag(player['country']),
                    style: const TextStyle(fontSize: 20),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatChip('LVL ${player['level']}', Colors.purple),
                    const SizedBox(width: 8),
                    _buildStatChip('${player['wins']} W', Colors.green),
                    const SizedBox(width: 8),
                    _buildStatChip('${player['kd']} K/D', Colors.orange),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${player['score']}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Score',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade600; // Gold
      case 2:
        return Colors.grey.shade400; // Silver
      case 3:
        return Colors.brown.shade600; // Bronze
      default:
        return Colors.blue.shade700;
    }
  }

  Color _getBadgeColor(String? badge) {
    switch (badge) {
      case 'crown':
        return Colors.amber;
      case 'medal':
        return Colors.grey;
      case 'bronze':
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  IconData _getBadgeIcon(String? badge) {
    switch (badge) {
      case 'crown':
        return Icons.star;
      case 'medal':
        return Icons.military_tech;
      case 'bronze':
        return Icons.workspace_premium;
      default:
        return Icons.circle;
    }
  }

  String _getCountryFlag(String country) {
    switch (country) {
      case 'US':
        return '🇺🇸';
      case 'DE':
        return '🇩🇪';
      case 'JP':
        return '🇯🇵';
      case 'RU':
        return '🇷🇺';
      case 'BR':
        return '🇧🇷';
      case 'CA':
        return '🇨🇦';
      default:
        return '🌍';
    }
  }
}