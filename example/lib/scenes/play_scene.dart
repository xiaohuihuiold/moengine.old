import 'package:moengine/game/scene/game_scene.dart';
import 'package:moengine/moengine.dart';

class PlayScene extends GameScene {
  @override
  void onAttach(Moengine moengine) {
    super.onAttach(moengine);
    print('PlayScene.onAttach');
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
