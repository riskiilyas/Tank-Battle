import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:tank_battle/game/tank_battle_game.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: TankBattleGame(),
      ),
    );
  }
}
