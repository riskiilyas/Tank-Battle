import 'package:flutter/material.dart';
import 'dart:math';

class GridPainter extends CustomPainter {
  final double animationValue;

  GridPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const gridSize = 50.0;
    final offset = (animationValue * gridSize) % gridSize;

    // Draw vertical lines
    for (double x = -offset; x < size.width + gridSize; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = -offset; y < size.height + gridSize; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}