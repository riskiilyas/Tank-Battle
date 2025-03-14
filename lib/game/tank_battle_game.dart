import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tank_battle/game/components/enemy_tank.dart';
import 'package:tank_battle/game/components/explosion.dart';
import 'package:tank_battle/game/components/mobile_control.dart';
import 'package:tank_battle/game/components/player_tank.dart';
import 'package:tank_battle/game/components/projectile.dart';

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

  // For background terrain
  late List<SpriteComponent> terrains = [];

  TextComponent? scoreText;
  TextComponent? healthText;

  // Key handling
  final Set<LogicalKeyboardKey> _keysPressed = {};

  // Mobile specific
  final bool isMobile;
  MobileControls? mobileControls;
  final Function() onMenuPressed;
  final Function() onChatPressed;

  TankBattleGame({
    this.isMobile = false,
    required this.onMenuPressed,
    required this.onChatPressed,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

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
      position: Vector2(50, 50),
      size: Vector2(40, 40),
    );
    add(player);

    // Configure camera to follow player
    camera.follow(player);

    // If you want to adjust zoom, you can try setting the viewfinder's zoom:
    // camera.viewfinder.zoom = 1.0;

    // Spawn enemies
    await _spawnEnemies();

    // Add UI as HUD (will be properly positioned in update)
    scoreText = TextComponent(
      text: 'Score: 0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(20, 20),
    );
    add(scoreText!);

    healthText = TextComponent(
      text: 'Health: 100%',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(20, 50),
    );
    add(healthText!);

    // Add mobile controls if on mobile platform
    if (isMobile) {
      mobileControls = MobileControls(
        onMenuPressed: onMenuPressed,
        onChatPressed: onChatPressed,
      );
      add(mobileControls!);
    }
  }

  Future<void> _addTerrainFeatures() async {
    final terrainTypes = [
      'rocks.png',
      'trees.png',
      'buildings.png',
    ];

    // Add 30 random terrain features
    for (int i = 0; i < 30; i++) {
      final terrainType = terrainTypes[random.nextInt(terrainTypes.length)];
      final terrainSprite = await loadSprite(terrainType);
      final terrainSize = Vector2(
        50 + random.nextInt(50).toDouble(),
        50 + random.nextInt(50).toDouble(),
      );
      final terrainPos = Vector2(
        random.nextDouble() * mapSize.x,
        random.nextDouble() * mapSize.y,
      );

      final terrain = SpriteComponent(
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
      );

      enemies.add(enemy);
      add(enemy);
    }
  }

  Vector2 _getRandomSpawnPosition() {
    // Make sure enemies don't spawn too close to the player
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

    // Ensure player stays within map boundaries
    player.position.x = player.position.x.clamp(0, mapSize.x);
    player.position.y = player.position.y.clamp(0, mapSize.y);

    // Update UI components to follow camera
    if (scoreText != null && healthText != null) {
      // Position UI elements relative to top-left of visible screen area
      final topLeft = camera.viewport.position - Vector2(size.x / 2, size.y / 2);
      scoreText!.position = topLeft + Vector2(20, 20);
      healthText!.position = topLeft + Vector2(20, 50);
    }

    // Update player movement based on current key states (if not on mobile)
    if (!isMobile) {
      _updatePlayerMovement();
    }

    // Check for projectile collisions
    for (var projectile in [...projectiles]) {
      // Check if projectile is out of bounds
      if (projectile.position.x < 0 ||
          projectile.position.x > mapSize.x ||
          projectile.position.y < 0 ||
          projectile.position.y > mapSize.y) {
        projectile.removeFromParent();
        projectiles.remove(projectile);
        continue;
      }

      // Check collision with enemies
      if (projectile.isPlayerProjectile) {
        for (var enemy in [...enemies]) {
          if (enemy.containsPoint(projectile.position)) {
            // Hit an enemy
            _damageEnemy(enemy);
            _createExplosion(projectile.position);
            projectile.removeFromParent();
            projectiles.remove(projectile);
            break;
          }
        }
      }
      // Check collision with player
      else if (player.containsPoint(projectile.position)) {
        _damagePlayer(10);
        _createExplosion(projectile.position);
        projectile.removeFromParent();
        projectiles.remove(projectile);
      }
    }

    // Respawn enemies if needed
    if (enemies.length < enemyCount && random.nextDouble() < 0.01) {
      _spawnSingleEnemy();
    }
  }

  void _updatePlayerMovement() {
    // Update player movement based on pressed keys
    player.setMovingForward(_keysPressed.contains(LogicalKeyboardKey.keyW));
    player.setMovingBackward(_keysPressed.contains(LogicalKeyboardKey.keyS));
    player.setRotatingLeft(_keysPressed.contains(LogicalKeyboardKey.keyA));
    player.setRotatingRight(_keysPressed.contains(LogicalKeyboardKey.keyD));
    player.setFiring(_keysPressed.contains(LogicalKeyboardKey.space));
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event,
      Set<LogicalKeyboardKey> keysPressed,
      ) {
    // Update tracked keys
    _keysPressed.clear();
    _keysPressed.addAll(keysPressed);

    // Handle restart
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.keyR &&
        playerHealth <= 0) {
      children.whereType<TextComponent>().forEach((component) {
        if (component.text.contains('GAME OVER')) {
          component.removeFromParent();
        }
      });

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
      score += 100;
      scoreText?.text = 'Score: $score';
    }
  }

  void _damagePlayer(int damage) {
    playerHealth -= damage;
    healthText?.text = 'Health: $playerHealth%';

    if (playerHealth <= 0) {
      _gameOver();
    }
  }

  void _gameOver() {
    pauseEngine();

    // Create game over overlay
    final gameOverText = TextComponent(
      text: 'GAME OVER\nScore: $score\nPress R to restart',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: camera.viewport.position + Vector2(size.x / 2, size.y / 2),
    );

    add(gameOverText);
  }

  void _createExplosion(Vector2 position) {
    final explosion = Explosion(
      position: position,
      size: Vector2(50, 50),
    );
    explosions.add(explosion);
    add(explosion);
  }

  Future<void> _spawnSingleEnemy() async {
    final spawnPosition = _getRandomSpawnPosition();

    final enemy = EnemyTank(
      position: spawnPosition,
      size: Vector2(40, 40),
      playerRef: player,
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
    // Reset game state
    score = 0;
    playerHealth = 100;

    // Update UI
    scoreText?.text = 'Score: $score';
    healthText?.text = 'Health: $playerHealth%';

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

    // Reset player position
    player.position = Vector2(mapSize.x / 2, mapSize.y / 2);

    // The camera.follow set in onLoad should continue to work

    // Spawn new enemies
    _spawnEnemies();

    // Resume the game
    resumeEngine();
  }

  // Handle touch events for mobile controls
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