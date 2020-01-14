import 'package:meta/meta.dart';
import 'package:moengine/engine/module/engine_module.dart';
import 'package:moengine/engine/module/renderer_module.dart';
import 'package:moengine/game/scene/game_scene.dart';

/// 场景模块
///
/// 用于场景的切换
class SceneModule extends EngineModule {
  /// 场景列表
  List<GameScene> _scenes;

  /// 渲染模块
  @protected
  RendererModule get rendererModule =>
      moduleManager?.getModule<RendererModule>();

  /// 需要渲染的场景
  GameScene get renderScene {
    if (sceneLength == 0) {
      return null;
    }
    return _scenes[sceneLength - 1];
  }

  /// 场景数量
  int get sceneLength => _scenes.length;

  SceneModule({
    List<GameScene> scenes,
  }) {
    _scenes = List();
    if (scenes == null) {
      return;
    }
    assert(Set.from(scenes).length < scenes.length, 'Scenes count >1');
  }

  /// 加载新的场景
  ///
  /// 如果场景对象已经存在的话,则提升到顶部
  bool loadScene(GameScene scene) {
    if (scene == null) {
      return false;
    }
    int sceneIndex = _scenes.indexOf(scene);
    if (sceneIndex >= 0) {
      GameScene tempScene = _scenes[sceneIndex];
      // 暂停场景
      _scenes[sceneLength - 1]?.onPause();
      // 移除旧场景并放到新的后面
      _scenes.removeAt(sceneIndex);
      _scenes.add(tempScene);
      // 恢复场景
      tempScene.onResume();
      rendererModule?.update();
      return true;
    }
    _scenes.add(scene);
    scene.onAttach(moengine);
    rendererModule?.update();
    return true;
  }

  /// 移除顶层场景
  bool removeTopScene() {
    if (_scenes == null || _scenes.isEmpty) {
      return false;
    }
    GameScene scene = _scenes[sceneLength - 1];
    _scenes.removeLast();
    scene?.onDestroy();
    rendererModule?.update();
    return true;
  }

  /// 根据对象移除场景
  bool removeScene(GameScene scene) {
    if (scene == null) {
      return false;
    }
    _scenes.remove(scene);
    scene.onDestroy();
    rendererModule?.update();
    return true;
  }

  /// 获取指定下标的场景
  GameScene getSceneAt(int index) {
    if (index < 0 || index >= _scenes.length) {
      return null;
    }
    return _scenes[index];
  }

  /// 场景模块不可移除
  @override
  bool onRemove() => false;

  /// 当游戏暂停时暂停渲染场景
  @override
  void onPause() {
    renderScene?.onPause();
  }

  /// 当游戏恢复时恢复渲染场景
  @override
  void onResume() {
    renderScene?.onResume();
  }

  /// 销毁并移除所有场景
  @override
  void onDestroy() {
    super.onDestroy();
    List<GameScene> scenes =
        List<GameScene>.generate(_scenes.length, (int index) => _scenes[index]);
    _scenes.clear();
    scenes.forEach((GameScene scene) => scene?.onDestroy());
  }
}
