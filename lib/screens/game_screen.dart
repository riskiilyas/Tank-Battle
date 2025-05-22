import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:tank_battle/game/tank_battle_game.dart';
import 'package:tank_battle/screens/main_menu_screen.dart';

/// Helper function to detect if we're on a mobile platform
bool isMobilePlatform() {
  if (kIsWeb) {
    // For web, check if the viewport is small enough to be considered mobile
    // This is an approximation and might need adjustment
    final screenWidth = WidgetsBinding.instance.window.physicalSize.width /
        WidgetsBinding.instance.window.devicePixelRatio;
    final screenHeight = WidgetsBinding.instance.window.physicalSize.height /
        WidgetsBinding.instance.window.devicePixelRatio;
    return screenWidth < 600 || screenHeight < 600;
  }

  // For native platforms, simply check if we're on iOS or Android
  return Platform.isIOS || Platform.isAndroid;
}

class GameScreen extends StatefulWidget {
  final Map<String, dynamic>? levelData;

  const GameScreen({Key? key, this.levelData}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late TankBattleGame _game;
  bool _showChatPanel = false;
  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];

  @override
  void initState() {
    super.initState();
    _game = TankBattleGame(
      isMobile: isMobilePlatform(),
      onMenuPressed: _showMenuDialog,
      onChatPressed: _toggleChatPanel,
      levelData: widget.levelData, // Pass level data to game
    );
  }


  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _showMenuDialog() {
    _game.pauseEngine();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          'PAUSED',
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        content: const Text(
          'What would you like to do?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _game.resumeEngine();
            },
            child: const Text(
              'RESUME',
              style: TextStyle(color: Colors.green),
            ),
          ),
          TextButton(
            onPressed: () => _restartGame(),
            child: const Text(
              'RESTART',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainMenuScreen(),
                ),
              );
            },
            child: const Text(
              'QUIT TO MENU',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    // Close the dialog and restart the game
    Navigator.pop(context);

    // Create a new game instance to fully reset the state
    setState(() {
      _game = TankBattleGame(
        isMobile: isMobilePlatform(),
        onMenuPressed: _showMenuDialog,
        onChatPressed: _toggleChatPanel,
      );
    });
  }

  void _toggleChatPanel() {
    setState(() {
      _showChatPanel = !_showChatPanel;

      // If opening chat panel, pause the game
      if (_showChatPanel) {
        _game.pauseEngine();
      } else {
        _game.resumeEngine();
      }
    });
  }

  void _sendChatMessage() {
    if (_chatController.text.trim().isNotEmpty) {
      setState(() {
        _chatMessages.add(
          ChatMessage(
            sender: 'You',
            message: _chatController.text.trim(),
            isPlayer: true,
          ),
        );
        _chatController.clear();
      });

      // Simulate a response after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _chatMessages.add(
              ChatMessage(
                sender: 'TankMaster42',
                message: _getRandomResponse(),
                isPlayer: false,
              ),
            );
          });
        }
      });
    }
  }

  String _getRandomResponse() {
    final responses = [
      'Got your back!',
      'Enemy on the left flank!',
      'Need backup at the center.',
      'Good shot!',
      'Watch out for mines!',
      'Moving to position B.',
      'Roger that!',
      'Hold your position!',
      'Nice one!',
      'Taking heavy fire!',
    ];

    return responses[DateTime.now().microsecond % responses.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Game
          GameWidget(game: _game),

          // Chat Panel (slide in from right when active)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            right: _showChatPanel ? 0 : -300,
            top: 0,
            bottom: 0,
            width: 300,
            child: Container(
              color: Colors.black87,
              child: Column(
                children: [
                  // Chat header
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.blue.shade900,
                    child: Row(
                      children: [
                        const Text(
                          'TEAM CHAT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: _toggleChatPanel,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // Chat messages
                  Expanded(
                    child: _chatMessages.isEmpty
                        ? const Center(
                      child: Text(
                        'No messages yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                        : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _chatMessages.length,
                      itemBuilder: (context, index) {
                        final message = _chatMessages[index];
                        return _buildChatBubble(message);
                      },
                    ),
                  ),

                  // Chat input
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black54,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade800,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            onSubmitted: (_) => _sendChatMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.blue),
                          onPressed: _sendChatMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
        message.isPlayer ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isPlayer)
            CircleAvatar(
              backgroundColor: Colors.blue.shade700,
              radius: 16,
              child: const Text('T', style: TextStyle(color: Colors.white)),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: message.isPlayer ? Colors.blue.shade700 : Colors.grey.shade700,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isPlayer)
                    Text(
                      message.sender,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Text(
                    message.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (message.isPlayer)
            CircleAvatar(
              backgroundColor: Colors.green.shade700,
              radius: 16,
              child: const Text('Y', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String sender;
  final String message;
  final bool isPlayer;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.isPlayer,
  });
}