import 'package:example/scenes/start_scene.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moengine/engine/module/scene_module.dart';
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
  final Moengine _moengine = Moengine(
    orientations: [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ],
    overlays:[
    ],
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _moengine.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GameTest'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            color: Colors.pink,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 5.0),
                  RaisedButton(
                    child: const Text('Launch'),
                    onPressed: () {
                      _moengine.getModule<SceneModule>().clearScene();
                      _moengine
                          .getModule<SceneModule>()
                          .loadScene(StartScene());
                    },
                  ),
                  const SizedBox(width: 5.0),
                ],
              ),
            ),
          ),
          Expanded(
            child: MoengineView(
              moengine: _moengine,
            ),
          ),
        ],
      ),
    );
  }
}
