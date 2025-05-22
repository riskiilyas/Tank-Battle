import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import 'package:tank_battle/game/tank_battle_game.dart';


class PlayerTank extends SpriteComponent with HasGameRef<TankBattleGame> {
  final double _speed = 200;
  final double _rotationSpeed = 3;
  double _direction = 0;
  double _gunDirection = 0;
  bool _isFiring = false;
  double _fireRate = 0.5;
  double _timeSinceLastShot = 0;

  // Track key states
  bool _isMovingForward = false;
  bool _isMovingBackward = false;
  bool _isRotatingLeft = false;
  bool _isRotatingRight = false;

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
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Handle movement based on key states
    if (_isMovingForward) {
      final moveVector = Vector2(cos(_direction), sin(_direction)) * _speed * dt;
      position.add(moveVector);
    }

    if (_isMovingBackward) {
      final moveVector = Vector2(cos(_direction), sin(_direction)) * _speed * dt * -1;
      position.add(moveVector);
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

    // Keep player within map bounds
    position.x = position.x.clamp(0, gameRef.mapSize.x);
    position.y = position.y.clamp(0, gameRef.mapSize.y);

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

  void _fire() {
    final muzzleOffset = Vector2(size.x / 2, 0)..rotate(_gunDirection);
    final muzzlePosition = position + muzzleOffset;

    // Calculate projectile direction
    final projectileDirection = Vector2(cos(_gunDirection), sin(_gunDirection));

    gameRef.fireProjectile(muzzlePosition, projectileDirection, true);
  }

  // Methods to handle key states
  void setMovingForward(bool value) {
    _isMovingForward = value;
  }

  void setMovingBackward(bool value) {
    _isMovingBackward = value;
  }

  void setRotatingLeft(bool value) {
    _isRotatingLeft = value;
  }

  void setRotatingRight(bool value) {
    _isRotatingRight = value;
  }

  void setFiring(bool value) {
    _isFiring = value;
    if (_isFiring && _timeSinceLastShot >= _fireRate) {
      _fire();
      _timeSinceLastShot = 0;
    }
  }
}