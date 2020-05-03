import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/gestures/events.dart';
import 'package:moengine/engine/module/resource_module.dart';
import 'package:moengine/game/component/game_component.dart';
import 'package:moengine/game/game_object.dart';
import 'package:moengine/game/scene/game_scene.dart';
import 'package:moengine/moengine.dart';

class PlayScene extends GameScene with PanDetector {
  Timer _timer;

  @override
  void onAttach(Moengine moengine) {
    super.onAttach(moengine);
    print('PlayScene.onAttach');
    for (int i = 1; i < 9; i++) {
      addGameObject(createObject([
        PositionComponent(
          position: Offset(size.width / 2.0, size.height / 2.0),
          radians: (i + 1.0) / 8.0 * pi,
        ),
        SizeComponent(size: const Size(100.0, 100.0)),
        AnchorComponent(anchor: const Offset(0.5, 0.5)),
        ClipComponent(
          clipShape: ClipShape.roundRect,
          radius: const Radius.circular(0.0),
        ),
        RenderComponent(
          customRender: (_, Canvas canvas, Paint paint) {
            canvas.drawRRect(
              RRect.fromRectXY(
                Rect.fromLTWH(
                  i * 10.0,
                  i * 10.0,
                  100.0 - i * 20.0,
                  100.0 - i * 20.0,
                ),
                8.0,
                8.0,
              ),
              Paint()
                ..color = Colors.pink.withOpacity(0.8)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2.0,
            );
          },
        ),
      ]));
    }
    resourceModule
        .loadImage('assets/images/flutter.png', ResourceMode.assets)
        .then((_) {
      addGameObject(
        createObject(
          [
            PositionComponent(
              position: Offset(size.width / 2.0, size.height / 2.0),
            ),
            AnchorComponent(anchor: const Offset(0.5, 0.5)),
            TextComponent(text: '测试文本'),
            SizeComponent(size: const Size(100.0, 100.0), immutable: true),
            ClipComponent(
              clipShape: ClipShape.roundRect,
              radius: const Radius.circular(8.0),
            ),
            SpriteComponent(
              image: resourceModule.getImage(
                  'assets/images/flutter.png', ResourceMode.assets),
            ),
            RenderComponent(
              customRender: (_, Canvas canvas, Paint paint) {
                canvas.drawPaint(Paint()..color = Colors.grey.withOpacity(0.5));
              },
            ),
          ],
        ),
      );
    });
    _startAnimation();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 1), (_) {
      for (int i = 0; i < gameObjectLength; i++) {
        GameObject gameObject = getGameObjectAt(i);
        if (gameObject.getComponent<PositionComponent>() == null) {
          continue;
        }
        if (i % 2 == 0) {
          gameObject.getComponent<PositionComponent>().radians +=
              sin((i + 1.0) / gameObjectLength * 2.0) * 0.005;
        } else {
          gameObject.getComponent<PositionComponent>().radians -=
              sin((i + 1.0) / gameObjectLength * 2.0) * 0.005;
        }
      }
      update();
    });
  }

  @override
  void onUpdate(int deltaTime) {
    // print('PlayScene.onUpdate($deltaTime)');
    getGameObjectAt(gameObjectLength - 1)?.getComponent<TextComponent>()?.text =
        '$deltaTime';
  }

  @override
  void onPause() {
    print('PlayScene.onPause');
    _timer?.cancel();
    super.onPause();
  }

  @override
  void onResume() {
    super.onResume();
    print('PlayScene.onResume');
    _startAnimation();
  }

  @override
  void onDestroy() {
    print('PlayScene.onDestroy');
    _timer?.cancel();
    super.onDestroy();
  }

  @override
  void onPanUpdate(DragUpdateDetails details) {
    for (int i = 0; i < gameObjectLength; i++) {
      GameObject gameObject = getGameObjectAt(i);
      PositionComponent positionComponent =
          gameObject.getComponent<PositionComponent>();
      positionComponent.position =
          Offset(details.localPosition.dx, details.localPosition.dy);
    }
    update();
  }
}