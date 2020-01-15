import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moengine/game/component/game_component.dart';
import 'package:moengine/game/scene/game_scene.dart';
import 'package:moengine/moengine.dart';

class PlayScene extends GameScene {
  @override
  void onAttach(Moengine moengine) {
    super.onAttach(moengine);
    print('PlayScene.onAttach');
    for (int i = 0; i < 10; i++) {
      addGameObject(createObject([
        PositionComponent(position: Offset(i * 50.0, i * 50.0)),
        SizeComponent(size: const Size(50.0, 50.0)),
        RenderComponent(render: (_, Canvas canvas, Paint paint) {
          canvas.drawCircle(
            const Offset(25.0, 25.0),
            12.5,
            paint..color = Colors.pink,
          );
        }),
      ]));
    }
  }

  @override
  void onUpdate(int deltaTime) {
    print('PlayScene.onUpdate($deltaTime)');
  }

  @override
  void onPause() {
    super.onPause();
    print('PlayScene.onPause');
  }

  @override
  void onResume() {
    super.onResume();
    print('PlayScene.onResume');
  }

  @override
  void onDestroy() {
    super.onDestroy();
    print('PlayScene.onDestroy');
  }
}
