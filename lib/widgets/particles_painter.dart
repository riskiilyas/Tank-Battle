import 'package:flutter/material.dart';
import 'package:tank_battle/widgets/animated_particle.dart';

class ParticlesPainter extends CustomPainter {
  final List<AnimatedParticle> particles;

  ParticlesPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      final center = Offset(
        particle.position.dx * size.width,
        particle.position.dy * size.height,
      );

      canvas.drawCircle(center, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}