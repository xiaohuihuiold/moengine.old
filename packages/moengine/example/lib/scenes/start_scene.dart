import 'package:example/scenes/play_scene.dart';
import 'package:flutter/material.dart';
import 'package:moengine/moengine.dart';

class StartScene extends GameScene {
  @override
  List<Widget> onBuildUi(BuildContext context) {
    return [
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomLeft,
            colors: [
              Colors.blue.withRed(160),
              Colors.blueAccent,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                elevation: 0.0,
                child: const Text(
                  'Play',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                onPressed: () {
                  sceneModule?.loadScene(PlayScene());
                },
              ),
              RaisedButton(
                elevation: 0.0,
                child: const Text(
                  'About',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('About'),
                        content: const Text('No message'),
                        actions: <Widget>[
                          FlatButton(
                            child: const Text('Back'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              RaisedButton(
                elevation: 0.0,
                child: const Text(
                  'Exit',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                onPressed: () {
                  sceneModule?.removeTopScene();
                },
              ),
            ],
          ),
        ),
      ),
    ];
  }

  @override
  void onAttach(Moengine moengine) {
    super.onAttach(moengine);
    print('StartScene.onAttach');
  }

  @override
  void onUpdate(int deltaTime) {
    // print('StartScene.onUpdate($deltaTime)');
  }

  @override
  void onPause() {
    super.onPause();
    print('StartScene.onPause');
  }

  @override
  void onResume() {
    super.onResume();
    print('StartScene.onResume');
  }

  @override
  void onDestroy() {
    super.onDestroy();
    print('StartScene.onDestroy');
  }
}
