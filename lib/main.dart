import 'package:flutter/material.dart';
import 'package:tank_battle/screens/game_screen.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Tank Battle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameScreen(),
    ),
  );
}