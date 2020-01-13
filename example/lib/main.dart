import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moengine/engine/module/scene_module.dart';
import 'package:moengine/game/component/game_component.dart';
import 'package:moengine/game/game_object.dart';
import 'package:moengine/game/scene/game_scene.dart';
import 'package:moengine/moengine.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moengine Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Moengine _moengine = Moengine();

  SceneModule _sceneModule;

  @override
  void initState() {
    super.initState();
    _sceneModule = _moengine.getModule<SceneModule>();
    _sceneModule.loadScene(TestGameScene());
  }

  @override
  Widget build(BuildContext context) {
    // TODO: ui结构改变,module没更新
    return Scaffold(
      body: MoengineView(
        moengine: _moengine,
      ),
    );
  }
}

class TestGameScene extends GameScene with PanDetector {
  GameObject flutterObject;

  double angle = 0.0;

  @override
  void onAttach(Moengine moengine) {
    super.onAttach(moengine);
    Timer.periodic(Duration(milliseconds: 1), (_) {
      if (flutterObject == null) {
        return;
      }
      if (flutterObject.getComponent<Rotate2DComponent>() == null) {
        flutterObject
            .addComponent(Rotate2DComponent(radians: angle / 180.0 * pi));
      }
      flutterObject.getComponent<Rotate2DComponent>().radians =
          angle / 180.0 * pi;
      update();
      angle += 0.1;
    });
  }

  @override
  List<Widget> onBuildUi() {
    return [
      Center(
        child: RaisedButton(
          child: const Text('Init'),
          onPressed: () async {
            gameObjects.remove(flutterObject);
            flutterObject = GameObject(
              [
                SpriteComponent(
                  image: await _loadImage('assets/images/flutter.png'),
                ),
                PositionComponent(
                  position: Offset(size.width / 2.0, size.height / 1.5),
                ),
                ScaleComponent(scale: const Size(1.0, 1.0)),
                AnchorComponent(anchor: const Offset(0.5, 0.5)),
                CanvasComponent(render: (Canvas canvas) {
                  canvas.drawCircle(
                    Offset.zero,
                    10.0,
                    Paint()..color = Colors.pink,
                  );
                }),
              ],
            );
            gameObjects.add(flutterObject);
            update();
          },
        ),
      ),
    ];
  }

  @override
  void onUpdate() {}

  @override
  void onPanCancel() {}

  @override
  void onPanDown(DragDownDetails details) {}

  @override
  void onPanEnd(DragEndDetails details) {}

  @override
  void onPanStart(DragStartDetails details) {}

  @override
  void onPanUpdate(DragUpdateDetails details) {
    Offset position = details.localPosition;
    if (flutterObject == null) {
      return;
    }
    PositionComponent positionComponent =
        flutterObject.getComponent<PositionComponent>();
    positionComponent.position = Offset(position.dx, position.dy);
    update();
  }

  /// 加载图片
  final Map<String, ui.Image> _imageCache = Map();

  Future<ui.Image> _loadImage(String path) async {
    ui.Image image = _imageCache[path.trim()];
    if (image != null) {
      return image;
    }
    ui.Codec codec = await ui.instantiateImageCodec(
        (await rootBundle.load(path)).buffer.asUint8List());
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    image = frameInfo.image;
    _imageCache[path.trim()] = image;
    return image;
  }
}
