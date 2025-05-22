import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class TerrainObject extends SpriteComponent with CollisionCallbacks {
  TerrainObject({
    required Sprite sprite,
    required Vector2 size,
    required Vector2 position,
  }) : super(
    sprite: sprite,
    size: size,
    position: position,
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    // Add collision detection hitbox
    add(RectangleHitbox());
  }
}