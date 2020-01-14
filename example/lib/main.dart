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

  @override
  void initState() {
    super.initState();
    _moengine.getModule<SceneModule>().loadScene(TestGameScene());
  }

  @override
  void dispose() {
    _moengine.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        return;
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RaisedButton(
              child: const Text('Rotate'),
              onPressed: () {
                if (flutterObject.getComponent<Rotate2DComponent>() != null) {
                  flutterObject.removeComponent(Rotate2DComponent);
                } else {
                  flutterObject.addComponent(
                      Rotate2DComponent(radians: angle / 180.0 * pi));
                }
              },
            ),
            RaisedButton(
              child: const Text('Init'),
              onPressed: () async {
                removeGameObject(flutterObject);
                flutterObject = createObject(
                  [
                    SpriteComponent(
                      image: await _loadImage('assets/images/flutter.png'),
                    ),
                    ClipComponent(),
                    PositionComponent(
                      position: Offset(size.width / 2.0, size.height / 1.5),
                    ),
                    SizeComponent(size: const Size(100.0, 100.0)),
                    ScaleComponent(scale: const Size(1.0, 1.0)),
                    AnchorComponent(anchor: const Offset(0.5, 0.5)),
                    RenderComponent(render:
                        (GameObject gameObject, Canvas canvas, Paint paint) {
                      canvas.drawCircle(
                        const Offset(50.0, 50.0),
                        10.0,
                        paint..color = Colors.pink,
                      );
                    }),
                  ],
                );
                addGameObject(flutterObject);
                update();
              },
            ),
          ],
        ),
      ),
    ];
  }

  @override
  void onUpdate(int deltaTime) {}

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
