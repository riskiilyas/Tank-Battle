import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

/// A component that displays the current FPS of the game.
class FpsTextComponent extends TextComponent {
  // Update interval in seconds
  final double _updateInterval = 0.5;
  double _timeSinceLastUpdate = 0;
  int _frameCount = 0;
  double _fps = 0;

  FpsTextComponent({
    required Vector2 position,
    TextRenderer? textRenderer,
  }) : super(
    position: position,
    text: 'FPS: 0',
    textRenderer: textRenderer ??
        TextPaint(
          style: const TextStyle(
            color: Colors.yellow,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
  );

  @override
  void update(double dt) {
    super.update(dt);

    // Count frames
    _frameCount++;
    _timeSinceLastUpdate += dt;

    // Update FPS calculation periodically
    if (_timeSinceLastUpdate >= _updateInterval) {
      _fps = _frameCount / _timeSinceLastUpdate;
      text = 'FPS: ${_fps.toInt()}';

      // Reset counters
      _frameCount = 0;
      _timeSinceLastUpdate = 0;
    }
  }
}