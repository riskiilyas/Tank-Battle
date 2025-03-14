import 'dart:math';
import 'package:tank_battle/game/components/player_tank.dart';
import 'package:tank_battle/game/tank_battle_game.dart';
import 'package:flame/components.dart';

class EnemyTank extends SpriteComponent with HasGameRef<TankBattleGame> {
  final PlayerTank playerRef;
  final double _speed = 100;
  final double _rotationSpeed = 2;
  double _direction = 0;
  int health = 50;

  final double _firingRange = 300;
  final double _fireRate = 1.5;
  double _timeSinceLastShot = 0;

  // AI state variables
  double _patrolTimer = 0;
  double _patrolDuration = 3.0;
  bool _isChasing = false;
  Vector2 _patrolTarget = Vector2.zero();

  EnemyTank({
    required Vector2 position,
    required Vector2 size,
    required this.playerRef,
  }) : super(
    position: position,
    size: size,
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('enemy_tank.png');
    angle = _direction;

    // Initialize patrol target
    _setNewPatrolTarget();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update firing cooldown
    if (_timeSinceLastShot < _fireRate) {
      _timeSinceLastShot += dt;
    }

    final distanceToPlayer = position.distanceTo(playerRef.position);

    // Decision making: chase player or patrol
    if (distanceToPlayer < 400) {
      _isChasing = true;
    } else if (distanceToPlayer > 600) {
      _isChasing = false;
    }

    if (_isChasing) {
      _chasePlayer(dt);
    } else {
      _patrol(dt);
    }

    // Try to fire if player is in range
    if (distanceToPlayer < _firingRange && _timeSinceLastShot >= _fireRate) {
      _fireAtPlayer();
      _timeSinceLastShot = 0;
    }
  }

  void _chasePlayer(double dt) {
    // Calculate angle to player
    final toPlayer = playerRef.position - position;
    final targetAngle = atan2(toPlayer.y, toPlayer.x);

    // Rotate towards player
    _rotateTowards(targetAngle, dt);

    // Move forward
    final moveVector = Vector2(cos(_direction), sin(_direction)) * _speed * dt;
    position.add(moveVector);

    // Keep within map bounds
    position.x = position.x.clamp(0, gameRef.mapSize.x);
    position.y = position.y.clamp(0, gameRef.mapSize.y);
  }

  void _patrol(double dt) {
    _patrolTimer += dt;

    if (_patrolTimer >= _patrolDuration) {
      _setNewPatrolTarget();
      _patrolTimer = 0;
    }

    // Calculate angle to patrol target
    final toTarget = _patrolTarget - position;
    final targetAngle = atan2(toTarget.y, toTarget.x);

    // Rotate towards target
    _rotateTowards(targetAngle, dt);

    // Move forward
    final moveVector = Vector2(cos(_direction), sin(_direction)) * (_speed * 0.5) * dt;
    position.add(moveVector);

    // Keep within map bounds
    position.x = position.x.clamp(0, gameRef.mapSize.x);
    position.y = position.y.clamp(0, gameRef.mapSize.y);
  }

  void _rotateTowards(double targetAngle, double dt) {
    var angleDiff = targetAngle - _direction;

    // Normalize the angle difference
    while (angleDiff > pi) angleDiff -= 2 * pi;
    while (angleDiff < -pi) angleDiff += 2 * pi;

    // Determine rotation direction
    if (angleDiff.abs() < _rotationSpeed * dt) {
      _direction = targetAngle;
    } else if (angleDiff > 0) {
      _direction += _rotationSpeed * dt;
    } else {
      _direction -= _rotationSpeed * dt;
    }

    // Update sprite rotation
    angle = _direction;
  }

  void _setNewPatrolTarget() {
    final random = gameRef.random;

    // Set a new patrol destination within a reasonable distance
    final angle = random.nextDouble() * 2 * pi;
    final distance = 100 + random.nextDouble() * 150;

    _patrolTarget = position + Vector2(cos(angle), sin(angle)) * distance;

    // Make sure the target is within map bounds
    _patrolTarget.x = _patrolTarget.x.clamp(0, gameRef.mapSize.x);
    _patrolTarget.y = _patrolTarget.y.clamp(0, gameRef.mapSize.y);

    // Randomize patrol duration
    _patrolDuration = 2.0 + random.nextDouble() * 3.0;
  }

  void _fireAtPlayer() {
    // Calculate direction to player
    final toPlayer = playerRef.position - position;
    final fireDirection = Vector2(toPlayer.x, toPlayer.y)..normalize();

    // Calculate muzzle position
    final muzzleOffset = Vector2(size.x / 2, 0)..rotate(_direction);
    final muzzlePosition = position + muzzleOffset;

    // Fire projectile
    gameRef.fireProjectile(muzzlePosition, fireDirection, false);
  }
}
