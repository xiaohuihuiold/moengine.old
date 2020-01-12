import 'package:flutter/material.dart';
import 'package:moengine/engine/module/scene_module.dart';
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
    return Scaffold(
      body: MoengineView(
        moengine: _moengine,
      ),
    );
  }
}

class TestGameScene extends GameScene with PanDetector{
  int count = 0;

  @override
  void onAttach(Moengine moengine) {
    super.onAttach(moengine);
  }

  @override
  List<Widget> onBuildUi() {
    return [
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Hello Game:$count'),
            GestureDetector(
              child: const Text('ADD'),
              onTap: () {
                count++;
                rendererModule?.updateState();
              },
            ),
          ],
        ),
      ),
    ];
  }

  @override
  void onUpdate() {
    print('onUpdated');
  }

  @override
  void onPanCancel() {
    // TODO: implement onPanCancel
  }

  @override
  void onPanDown(DragDownDetails details) {
    // TODO: implement onPanDown
  }

  @override
  void onPanEnd(DragEndDetails details) {
    // TODO: implement onPanEnd
  }

  @override
  void onPanStart(DragStartDetails details) {
    // TODO: implement onPanStart
  }

  @override
  void onPanUpdate(DragUpdateDetails details) {
    // TODO: implement onPanUpdate
    print(details.globalPosition);
  }
}
