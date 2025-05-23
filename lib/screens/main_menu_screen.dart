import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tank_battle/screens/friends_list_screen.dart';
import 'package:tank_battle/screens/game_screen.dart';
import 'package:tank_battle/screens/leaderboard_screen.dart';
import 'package:tank_battle/screens/online_play_screen.dart';
import 'package:tank_battle/screens/settings_screen.dart';
import 'package:tank_battle/widgets/game_button.dart';

import 'level_selection_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPlayCasual() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GameScreen(),
      ),
    );
  }

  void _onPlayOnline() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OnlinePlayScreen(),
      ),
    );
  }

  void _onFriendList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FriendsListScreen(),
      ),
    );
  }

  void _onSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _onExit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          "Exit Game",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to exit?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.green)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Exit", style: TextStyle(color: Colors.red)),
            onPressed: () => SystemNavigator.pop(),
          ),
        ],
      ),
    );
  }

  void _showNotImplementedDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          "Coming Soon!",
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "$feature will be available in the next update!",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            child: const Text("OK", style: TextStyle(color: Colors.amber)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required int index,
    bool smallScreen = false,
    Color color = Colors.blue,
  }) {
    if (smallScreen) {
      return Expanded(
        child: SizedBox(
          width: 300,
          child: GameButton(
            text: text,
            icon: icon,
            onPressed: onPressed,
            color: color,
          ),
        ),
      );
    }

    return SizedBox(
      width: 400,
      child: GameButton(
        text: text,
        icon: icon,
        onPressed: onPressed,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600 || screenHeight < 400;

    // If the screen is very small, we'll use a different layout
    if (isSmallScreen) {
      return _buildCompactLayout(screenWidth);
    }

    // Otherwise use the normal horizontal layout
    return _buildHorizontalLayout(screenWidth);
  }

  Widget _buildHorizontalLayout(double screenWidth) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/satellite_map.png'),
            fit: BoxFit.cover,
            opacity: 0.7,
            colorFilter: ColorFilter.mode(
              Colors.black54,
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Left side with title, subtitle and tank image
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Game Title
                      const Text(
                        "TANK BATTLE",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                            Shadow(
                              color: Colors.red,
                              offset: Offset(-1, -1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Subtitle
                      const Text(
                        "DOMINATE THE BATTLEFIELD",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.amber,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Tank Image
                      Expanded(
                        child: Center(
                          child: Image.asset(
                            'assets/images/player_tank.png',
                            fit: BoxFit.contain,
                            width: screenWidth * 0.3,
                          ),
                        ),
                      ),
                      // Version info
                      const Text(
                        "v1.0.0 | © 2025 Tank Battle",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Right side with menu buttons
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    border: Border(
                      left: BorderSide(
                        color: Colors.blue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildMenuButtons(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLayout(double screenWidth) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/satellite_map.png'),
            fit: BoxFit.cover,
            opacity: 0.7,
            colorFilter: ColorFilter.mode(
              Colors.black54,
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with title and tank icon
              Expanded(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "TANK BATTLE",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                ),
                                Shadow(
                                  color: Colors.red,
                                  offset: Offset(-1, -1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            "DOMINATE THE BATTLEFIELD",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber,
                              letterSpacing: 1,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Image.asset(
                              'assets/images/player_tank.png',
                              width: 200,
                              height: 200,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Menu Buttons
                    Expanded(
                      child: Center(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth * 0.8,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _buildMenuButtons(smallScreen: true),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Version info
              const Text(
                "v1.0.0 | © 2025 Tank Battle",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  void _onLevelSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LevelSelectionScreen(),
      ),
    );
  }

  void _onLeaderboard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LeaderboardScreen(),
      ),
    );
  }

  List<Widget> _buildMenuButtons({bool smallScreen = false}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 600 || smallScreen;

    return [
      SizedBox(height: isSmallScreen ? 0 : 10),
      _buildMenuButton(
          text: "PLAY CASUAL",
          icon: Icons.play_arrow,
          onPressed: _onPlayCasual,
          index: 0,
          color: Colors.green.shade700,
          smallScreen: smallScreen),
      SizedBox(height: isSmallScreen ? 3 : 10),
      _buildMenuButton(
          text: "LEVEL SELECT",
          icon: Icons.view_module,
          onPressed: _onLevelSelection,
          index: 1,
          color: Colors.blue.shade700,
          smallScreen: smallScreen),
      SizedBox(height: isSmallScreen ? 3 : 10),
      _buildMenuButton(
          text: "PLAY ONLINE",
          icon: Icons.public,
          onPressed: _onPlayOnline,
          index: 2,
          color: Colors.purple.shade700,
          smallScreen: smallScreen),
      SizedBox(height: isSmallScreen ? 3 : 10),
      _buildMenuButton(
          text: "LEADERBOARD",
          icon: Icons.leaderboard,
          onPressed: _onLeaderboard,
          index: 3,
          color: Colors.amber.shade700,
          smallScreen: smallScreen),
      SizedBox(height: isSmallScreen ? 3 : 10),
      _buildMenuButton(
          text: "FRIEND LIST",
          icon: Icons.people,
          onPressed: _onFriendList,
          index: 4,
          color: Colors.orange.shade700,
          smallScreen: smallScreen),
      SizedBox(height: isSmallScreen ? 3 : 10),
      _buildMenuButton(
          text: "SETTINGS",
          icon: Icons.settings,
          onPressed: _onSettings,
          index: 5,
          color: Colors.teal.shade700,
          smallScreen: smallScreen),
      SizedBox(height: isSmallScreen ? 3 : 10),
      _buildMenuButton(
          text: "EXIT",
          icon: Icons.exit_to_app,
          onPressed: _onExit,
          index: 6,
          color: Colors.red.shade700,
          smallScreen: smallScreen),
      SizedBox(height: isSmallScreen ? 0 : 10),
    ];
  }
}
