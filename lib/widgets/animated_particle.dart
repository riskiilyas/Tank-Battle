import 'dart:ui';
import 'dart:math';

class AnimatedParticle {
  Offset position;
  final double size;
  final Color color;
  final double speed;
  final double angle;
  double _time = 0;

  AnimatedParticle({
    required this.position,
    required this.size,
    required this.color,
    required this.speed,
    required this.angle,
  });

  void update(double animationValue) {
    _time = animationValue * 100; // Scale animation value

    // Move particle based on its angle and speed
    final dx = cos(angle) * speed * _time;
    final dy = sin(angle) * speed * _time;

    position = Offset(
      position.dx + dx * 0.01,
      position.dy + dy * 0.01,
    );
  }
}