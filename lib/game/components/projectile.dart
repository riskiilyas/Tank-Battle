import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tank_battle/game/tank_battle_game.dart';

class Projectile extends CircleComponent with HasGameRef<TankBattleGame> {
  final Vector2 direction;
  final double _speed = 400;
  final bool isPlayerProjectile;

  Projectile({
    required Vector2 position,
    required this.direction,
    required this.isPlayerProjectile,
  }) : super(
    position: position,
    radius: 4,
    anchor: Anchor.center,
    paint: Paint()..color = isPlayerProjectile ? Colors.blueAccent : Colors.red,
  );

  @override
  void update(double dt) {
    super.update(dt);

    // Move in direction
    position.add(direction * _speed * dt);
  }
}
