import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tank_battle/widgets/animated_particle.dart';
import 'package:tank_battle/widgets/particles_painter.dart';
import 'package:tank_battle/widgets/grid_painter.dart';

// Base authentication screen with shared styling and background
class BaseAuthScreen extends StatefulWidget {
  final Widget child;
  final String title;
  final bool showBackButton;

  const BaseAuthScreen({
    Key? key,
    required this.child,
    required this.title,
    this.showBackButton = true,
  }) : super(key: key);

  @override
  State<BaseAuthScreen> createState() => _BaseAuthScreenState();
}

class _BaseAuthScreenState extends State<BaseAuthScreen> with SingleTickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  final List<AnimatedParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Animation controller for moving background elements
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    )..repeat();

    // Create animated particles
    for (int i = 0; i < 20; i++) {
      _particles.add(_createParticle());
    }
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  AnimatedParticle _createParticle() {
    return AnimatedParticle(
      position: Offset(
        _random.nextDouble() * 1.2 - 0.1, // -0.1 to 1.1 to allow offscreen particles
        _random.nextDouble() * 1.2 - 0.1,
      ),
      size: _random.nextDouble() * 15 + 5,
      color: Colors.blue.withOpacity(_random.nextDouble() * 0.3 + 0.1),
      speed: _random.nextDouble() * 0.02 + 0.01,
      angle: _random.nextDouble() * 2 * pi,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimationController,
        builder: (context, _) {
          // Update particle positions
          for (var particle in _particles) {
            particle.update(_backgroundAnimationController.value);

            // Wrap particles that go offscreen
            if (particle.position.dx < -0.1) particle.position = Offset(1.1, particle.position.dy);
            if (particle.position.dx > 1.1) particle.position = Offset(-0.1, particle.position.dy);
            if (particle.position.dy < -0.1) particle.position = Offset(particle.position.dx, 1.1);
            if (particle.position.dy > 1.1) particle.position = Offset(particle.position.dx, -0.1);
          }

          return Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Colors.blue.shade900.withOpacity(0.7),
                    ],
                  ),
                ),
              ),

              // Animated particles
              CustomPaint(
                size: Size.infinite,
                painter: ParticlesPainter(particles: _particles),
              ),

              // Background grid pattern
              CustomPaint(
                size: Size.infinite,
                painter: GridPainter(animationValue: _backgroundAnimationController.value),
              ),

              // Main content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      // Title bar
                      Row(
                        children: [
                          if (widget.showBackButton)
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          Expanded(
                            child: Text(
                              widget.title,
                              textAlign: widget.showBackButton ? TextAlign.center : TextAlign.center,
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
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
                          ),
                          if (widget.showBackButton) const SizedBox(width: 48), // Balance the back button
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Main content
                      Expanded(child: widget.child),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}