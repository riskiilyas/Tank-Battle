import 'package:flame/components.dart';
import 'package:tank_battle/game/tank_battle_game.dart';


class Explosion extends SpriteAnimationComponent with HasGameRef<TankBattleGame> {
  Explosion({
    required Vector2 position,
    required Vector2 size,
  }) : super(
    position: position,
    size: size,
    anchor: Anchor.center,
    removeOnFinish: true
  );

  @override
  Future<void> onLoad() async {
    final spriteSheet = await gameRef.loadSprite('explosion_sheet.png');
    final animation = SpriteAnimation.fromFrameData(
      spriteSheet.image,
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: 0.1,
        textureSize: Vector2(64, 64),
        loop: false,
      ),
    );

    this.animation = animation;
  }
}