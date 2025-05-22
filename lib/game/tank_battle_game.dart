import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tank_battle/game/components/enemy_tank.dart';
import 'package:tank_battle/game/components/explosion.dart';
import 'package:tank_battle/game/components/mobile_control.dart';
import 'package:tank_battle/game/components/player_tank.dart';
import 'package:tank_battle/game/components/projectile.dart';
import 'package:tank_battle/game/components/fps_text_component.dart' as fps;
import 'package:tank_battle/game/components/terrain_object.dart';
import 'package:tank_battle/settings/game_settings.dart';

class TankBattleGame extends FlameGame with KeyboardEvents, HasCollisionDetection, TapDetector {
  late final PlayerTank player;
  final List<EnemyTank> enemies = [];
  final List<Projectile> projectiles = [];
  final List<Explosion> explosions = [];

  final mapSize = Vector2(2000, 2000);
  late SpriteComponent mapBackground;
  final random = Random();

  int enemyCount = 5;
  int score = 0;
  int playerHealth = 100;
  int enemiesDestroyed = 0;
  int totalEnemies = 0;
  bool gameCompleted = false;
  bool gameOver = false;

  // For background terrain with proper collision
  final List<TerrainObject> terrains = [];

  // UI Components
  late TextComponent scoreText;
  late TextComponent healthText;
  late TextComponent enemyCountText;
  FpsTextComponent? fpsCounter;
  TextComponent? gameStatusText;

  // Key handling
  final Set<LogicalKeyboardKey> _keysPressed = {};

  // Mobile specific
  final bool isMobile;
  MobileControls? mobileControls;
  final Function() onMenuPressed;
  final Function() onChatPressed;
  final GameSettings _gameSettings = GameSettings();

  // Level data support
  final Map<String, dynamic>? levelData;

  TankBattleGame({
    this.isMobile = false,
    required this.onMenuPressed,
    required this.onChatPressed,
    this.levelData,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Use level data if provided
    if (levelData != null) {
      enemyCount = levelData!['enemies'] ?? _gameSettings.getEnemyCount();
      totalEnemies = enemyCount;
      _applyLevelSettings();
    } else {
      // Initialize settings-based values for casual play
      enemyCount = _gameSettings.getEnemyCount();
      totalEnemies = enemyCount;
    }

    // Create the map background with a satellite view texture
    final mapSprite = await loadSprite('satellite_map.png');
    mapBackground = SpriteComponent(
      sprite: mapSprite,
      size: mapSize,
    );
    add(mapBackground);

    // Add some terrain features
    await _addTerrainFeatures();

    // Create player tank
    player = PlayerTank(
      position: Vector2(mapSize.x / 2, mapSize.y / 2),
      size: Vector2(40, 40),
    );
    add(player);

    // Configure camera to follow player
    camera.follow(player);

    // Spawn enemies
    await _spawnEnemies();

    // Setup UI
    await _setupUI();

    // Add mobile controls if on mobile platform
    if (isMobile && _gameSettings.shouldUseVirtualJoystick()) {
      mobileControls = MobileControls(
        onMenuPressed: onMenuPressed,
        onChatPressed: onChatPressed,
      );
      add(mobileControls!);
    }
  }

  void _applyLevelSettings() {
    if (levelData == null) return;

    final difficulty = levelData!['difficulty'];

    // Adjust game parameters based on level difficulty
    switch (difficulty) {
      case 'Easy':
      // Standard settings
        break;
      case 'Medium':
      // Slightly harder
        playerHealth = 75;
        break;
      case 'Hard':
      // Much harder
        playerHealth = 50;
        break;
      case 'Extreme':
      // Very difficult
        playerHealth = 25;
        break;
      case 'Boss':
      // Boss fight
        playerHealth = 100;
        // Special boss logic can be added here
        break;
    }
  }

  Future<void> _setupUI() async {
    // Score text
    scoreText = TextComponent(
      text: 'Score: 0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2)],
        ),
      ),
      position: Vector2(20, 20),
    );
    camera.viewport.add(scoreText);

    // Health text
    healthText = TextComponent(
      text: 'Health: $playerHealth%',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2)],
        ),
      ),
      position: Vector2(20, 50),
    );
    camera.viewport.add(healthText);

    // Enemy count text
    enemyCountText = TextComponent(
      text: 'Enemies: $enemyCount',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2)],
        ),
      ),
      position: Vector2(20, 80),
    );
    camera.viewport.add(enemyCountText);

    // FPS counter (if enabled)
    if (_gameSettings.showFrameRate) {
      fpsCounter = FpsTextComponent(
        position: Vector2(0, 0),
      );
      camera.viewport.add(fpsCounter!);
    }
  }

  void _updateUIPositions() {
    final viewport = camera.viewport;

    // Update FPS counter position to top right
    if (fpsCounter != null) {
      fpsCounter!.position = Vector2(viewport.size.x - 100, 20);
    }

    // Update mobile controls position if they exist
    if (mobileControls != null) {
      // mobileControls!.updatePositions(viewport.size);
    }
  }

  Future<void> _addTerrainFeatures() async {
    final terrainTypes = [
      'rocks.png',
      'trees.png',
      'buildings.png',
    ];

    // Add 30 random terrain features with collision
    for (int i = 0; i < 30; i++) {
      final terrainType = terrainTypes[random.nextInt(terrainTypes.length)];
      final terrainSprite = await loadSprite(terrainType);
      final terrainSize = Vector2(
        50 + random.nextInt(50).toDouble(),
        50 + random.nextInt(50).toDouble(),
      );

      // Ensure terrain doesn't spawn too close to player start position
      Vector2 terrainPos;
      do {
        terrainPos = Vector2(
          random.nextDouble() * (mapSize.x - terrainSize.x) + terrainSize.x / 2,
          random.nextDouble() * (mapSize.y - terrainSize.y) + terrainSize.y / 2,
        );
      } while (terrainPos.distanceTo(Vector2(mapSize.x / 2, mapSize.y / 2)) < 100);

      final terrain = TerrainObject(
        sprite: terrainSprite,
        size: terrainSize,
        position: terrainPos,
      );

      terrains.add(terrain);
      add(terrain);
    }
  }

  Future<void> _spawnEnemies() async {
    for (int i = 0; i < enemyCount; i++) {
      final spawnPosition = _getRandomSpawnPosition();

      final enemy = EnemyTank(
        position: spawnPosition,
        size: Vector2(40, 40),
        playerRef: player,
        speed: _gameSettings.getEnemySpeed(),
        health: _gameSettings.getEnemyHealth(),
        fireRate: _gameSettings.getEnemyFireRate(),
      );

      enemies.add(enemy);
      add(enemy);
    }
  }

  Vector2 _getRandomSpawnPosition() {
    const minDistanceFromPlayer = 300.0;
    Vector2 position;

    do {
      position = Vector2(
        random.nextDouble() * mapSize.x,
        random.nextDouble() * mapSize.y,
      );
    } while (position.distanceTo(player.position) < minDistanceFromPlayer);

    return position;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameOver || gameCompleted) return;

    // Update UI positions
    _updateUIPositions();

    // Update player movement based on current key states (if not on mobile)
    if (!isMobile) {
      _updatePlayerMovement();
    }

    // Handle projectile collisions
    _handleProjectileCollisions();

    // Check for game completion
    if (enemies.isEmpty && !gameCompleted) {
      _gameWon();
    }

    // Respawn enemies if needed (in continuous mode)
    if (enemies.length < enemyCount / 2 && random.nextDouble() < 0.005) {
      _spawnSingleEnemy();
    }
  }

  void _updatePlayerMovement() {
    player.setMovingForward(_keysPressed.contains(LogicalKeyboardKey.keyW) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowUp));
    player.setMovingBackward(_keysPressed.contains(LogicalKeyboardKey.keyS) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowDown));
    player.setRotatingLeft(_keysPressed.contains(LogicalKeyboardKey.keyA) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowLeft));
    player.setRotatingRight(_keysPressed.contains(LogicalKeyboardKey.keyD) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowRight));
    player.setFiring(_keysPressed.contains(LogicalKeyboardKey.space));
  }

  void _handleProjectileCollisions() {
    for (var projectile in [...projectiles]) {
      // Check if projectile is out of bounds
      if (projectile.position.x < 0 || projectile.position.x > mapSize.x ||
          projectile.position.y < 0 || projectile.position.y > mapSize.y) {
        projectile.removeFromParent();
        projectiles.remove(projectile);
        continue;
      }

      bool projectileHit = false;

      // Check collision with enemies
      if (projectile.isPlayerProjectile && !projectileHit) {
        for (var enemy in [...enemies]) {
          if (_isColliding(projectile, enemy)) {
            _damageEnemy(enemy);
            _createExplosion(projectile.position);
            projectile.removeFromParent();
            projectiles.remove(projectile);
            projectileHit = true;
            break;
          }
        }
      }

      // Check collision with player
      if (!projectile.isPlayerProjectile && !projectileHit) {
        if (_isColliding(projectile, player)) {
          _damagePlayer(10);
          _createExplosion(projectile.position);
          projectile.removeFromParent();
          projectiles.remove(projectile);
          projectileHit = true;
        }
      }

      // Check collision with terrain
      if (!projectileHit) {
        for (var terrain in terrains) {
          if (_isColliding(projectile, terrain)) {
            _createExplosion(projectile.position);
            projectile.removeFromParent();
            projectiles.remove(projectile);
            projectileHit = true;
            break;
          }
        }
      }
    }
  }

  bool _isColliding(PositionComponent a, PositionComponent b) {
    final aLeft = a.position.x - a.size.x / 2;
    final aRight = a.position.x + a.size.x / 2;
    final aTop = a.position.y - a.size.y / 2;
    final aBottom = a.position.y + a.size.y / 2;

    final bLeft = b.position.x - b.size.x / 2;
    final bRight = b.position.x + b.size.x / 2;
    final bTop = b.position.y - b.size.y / 2;
    final bBottom = b.position.y + b.size.y / 2;

    return !(aRight < bLeft || aLeft > bRight || aBottom < bTop || aTop > bBottom);
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keysPressed.clear();
    _keysPressed.addAll(keysPressed);

    // Handle restart
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyR &&
        (playerHealth <= 0 || gameCompleted)) {
      _restartGame();
      return KeyEventResult.handled;
    }

    // Handle menu key (ESC)
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      onMenuPressed();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _damageEnemy(EnemyTank enemy) {
    enemy.health -= 25;
    if (enemy.health <= 0) {
      _createExplosion(enemy.position);
      enemy.removeFromParent();
      enemies.remove(enemy);
      enemiesDestroyed++;
      score += 100;
      scoreText.text = 'Score: $score';
      enemyCountText.text = 'Enemies: ${enemies.length}';
    }
  }

  void _damagePlayer(int damage) {
    playerHealth -= damage;
    healthText.text = 'Health: $playerHealth%';

    if (playerHealth <= 0) {
      _gameOver();
    }
  }

  void _gameOver() {
    gameOver = true;
    pauseEngine();

    gameStatusText = TextComponent(
      text: 'GAME OVER\nScore: $score\nEnemies Destroyed: $enemiesDestroyed\nPress R to restart',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4)],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(camera.viewport.size.x / 2, camera.viewport.size.y / 2),
    );

    camera.viewport.add(gameStatusText!);
  }

  void _gameWon() {
    gameCompleted = true;
    pauseEngine();

    gameStatusText = TextComponent(
      text: 'VICTORY!\nAll enemies destroyed!\nScore: $score\nPress R to play again',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.green,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4)],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(camera.viewport.size.x / 2, camera.viewport.size.y / 2),
    );

    camera.viewport.add(gameStatusText!);
  }

  void _createExplosion(Vector2 position) {
    final explosion = Explosion(
      position: position,
      size: Vector2(50, 50),
    );
    explosions.add(explosion);
    add(explosion);

    // Remove explosion after animation completes
    explosion.onRemove();
    explosions.remove(explosion);
  }

  Future<void> _spawnSingleEnemy() async {
    final spawnPosition = _getRandomSpawnPosition();

    final enemy = EnemyTank(
      position: spawnPosition,
      size: Vector2(40, 40),
      playerRef: player,
      speed: _gameSettings.getEnemySpeed(),
      health: _gameSettings.getEnemyHealth(),
      fireRate: _gameSettings.getEnemyFireRate(),
    );

    enemies.add(enemy);
    add(enemy);
  }

  void fireProjectile(Vector2 position, Vector2 direction, bool isPlayerProjectile) {
    final projectile = Projectile(
      position: position.clone(),
      direction: direction,
      isPlayerProjectile: isPlayerProjectile,
    );

    projectiles.add(projectile);
    add(projectile);
  }

  void _restartGame() {
    // Clean up existing game state
    gameOver = false;
    gameCompleted = false;
    score = 0;
    playerHealth = 100;
    enemiesDestroyed = 0;

    // Remove game status text
    gameStatusText?.removeFromParent();
    gameStatusText = null;

    // Update UI
    scoreText.text = 'Score: $score';
    healthText.text = 'Health: $playerHealth%';
    enemyCountText.text = 'Enemies: $enemyCount';

    // Remove all enemies
    for (var enemy in [...enemies]) {
      enemy.removeFromParent();
    }
    enemies.clear();

    // Remove all projectiles
    for (var projectile in [...projectiles]) {
      projectile.removeFromParent();
    }
    projectiles.clear();

    // Remove all explosions
    for (var explosion in [...explosions]) {
      explosion.removeFromParent();
    }
    explosions.clear();

    // Reset player position and health
    player.position = Vector2(mapSize.x / 2, mapSize.y / 2);
    player.resetHealth();

    // Spawn new enemies
    _spawnEnemies();

    // Resume the game
    resumeEngine();
  }

  // Touch event handlers for mobile
  @override
  bool onTapDown(TapDownInfo info) {
    if (isMobile && mobileControls != null) {
      return mobileControls!.onTapDown(info);
    }
    return false;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    if (isMobile && mobileControls != null) {
      return mobileControls!.onTapUp(info);
    }
    return false;
  }

  @override
  bool onDragUpdate(DragUpdateInfo info) {
    if (isMobile && mobileControls != null) {
      return mobileControls!.onDragUpdate(info);
    }
    return false;
  }

  @override
  bool onDragEnd(DragEndInfo info) {
    if (isMobile && mobileControls != null) {
      return mobileControls!.onDragEnd(info);
    }
    return false;
  }
}