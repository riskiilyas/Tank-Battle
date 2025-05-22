import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'dart:math';
import 'package:tank_battle/game/tank_battle_game.dart';

import 'enemy_tank.dart';

class PlayerTank extends SpriteComponent with HasGameRef<TankBattleGame>, CollisionCallbacks {
  final double _speed = 200;
  final double _rotationSpeed = 3;
  double _direction = 0;
  double _gunDirection = 0;
  bool _isFiring = false;
  final double _fireRate = 0.5;
  double _timeSinceLastShot = 0;
  int maxHealth = 100;
  int currentHealth = 100;

  // Track key states
  bool _isMovingForward = false;
  bool _isMovingBackward = false;
  bool _isRotatingLeft = false;
  bool _isRotatingRight = false;

  // Store previous position for collision handling
  Vector2 _previousPosition = Vector2.zero();

  PlayerTank({
    required Vector2 position,
    required Vector2 size,
  }) : super(
    position: position,
    size: size,
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('player_tank.png');
    angle = _direction;
    _previousPosition = position.clone();

    // Add collision detection
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Store current position before movement
    _previousPosition = position.clone();

    // Handle movement based on key states
    if (_isMovingForward) {
      final moveVector = Vector2(cos(_direction), sin(_direction)) * _speed * dt;
      position.add(moveVector);
    }

    if (_isMovingBackward) {
      final moveVector = Vector2(cos(_direction), sin(_direction)) * _speed * dt * -0.5;
      position.sub(moveVector);
    }

    // Handle rotation based on key states
    if (_isRotatingLeft) {
      _direction -= _rotationSpeed * dt;
      angle = _direction;
      _gunDirection = _direction;
    }

    if (_isRotatingRight) {
      _direction += _rotationSpeed * dt;
      angle = _direction;
      _gunDirection = _direction;
    }

    // Check and enforce map bounds PROPERLY
    _enforceBounds();

    // Update firing cooldown
    if (_timeSinceLastShot < _fireRate) {
      _timeSinceLastShot += dt;
    }

    // Handle firing
    if (_isFiring && _timeSinceLastShot >= _fireRate) {
      _fire();
      _timeSinceLastShot = 0;
    }
  }

  void _enforceBounds() {
    final halfWidth = size.x / 2;
    final halfHeight = size.y / 2;

    // Calculate bounds with proper margins
    final leftBound = halfWidth;
    final rightBound = gameRef.mapSize.x - halfWidth;
    final topBound = halfHeight;
    final bottomBound = gameRef.mapSize.y - halfHeight;

    bool boundsViolated = false;

    // Check and fix horizontal bounds
    if (position.x < leftBound) {
      position.x = leftBound;
      boundsViolated = true;
    } else if (position.x > rightBound) {
      position.x = rightBound;
      boundsViolated = true;
    }

    // Check and fix vertical bounds
    if (position.y < topBound) {
      position.y = topBound;
      boundsViolated = true;
    } else if (position.y > bottomBound) {
      position.y = bottomBound;
      boundsViolated = true;
    }

    // If bounds were violated, we've already corrected the position
    if (boundsViolated) {
      // Optional: Add visual/audio feedback when hitting bounds
      // gameRef.showBoundaryEffect();
    }
  }

  @override
  bool onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    // Handle collision with terrain objects and enemies
    if (other is SpriteComponent && gameRef.terrains.contains(other)) {
      // Collision with terrain - revert to previous position
      position = _previousPosition.clone();
      return true;
    }

    if (other is EnemyTank) {
      // Collision with enemy tank - revert to previous position
      position = _previousPosition.clone();
      // Optional: Take damage from collision
      // takeDamage(5);
      return true;
    }

    return true;
  }

  void _fire() {
    final muzzleOffset = Vector2(size.x / 2, 0)..rotate(_gunDirection);
    final muzzlePosition = position + muzzleOffset;

    // Calculate projectile direction
    final projectileDirection = Vector2(cos(_gunDirection), sin(_gunDirection));

    gameRef.fireProjectile(muzzlePosition, projectileDirection, true);
  }

  void resetHealth() {
    currentHealth = maxHealth;
  }

  void takeDamage(int damage) {
    currentHealth = (currentHealth - damage).clamp(0, maxHealth);
  }

  // Methods to handle key states
  void setMovingForward(bool value) => _isMovingForward = value;
  void setMovingBackward(bool value) => _isMovingBackward = value;
  void setRotatingLeft(bool value) => _isRotatingLeft = value;
  void setRotatingRight(bool value) => _isRotatingRight = value;

  void setFiring(bool value) {
    _isFiring = value;
    if (_isFiring && _timeSinceLastShot >= _fireRate) {
      _fire();
      _timeSinceLastShot = 0;
    }
  }
}