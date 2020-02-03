import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:moengine/engine/exception/engine_exception.dart';
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

  /// 场景大小
  Size size;

  SceneModule({
    List<GameScene> scenes,
  }) {
    _scenes = List();
    if (scenes == null) {
      return;
    }
    bool hasRepeat = Set.from(scenes).length < scenes.length;
    assert(hasRepeat, 'Scenes count >1');
    if (!(hasRepeat)) {
      throw ElementRepeatException();
    }
  }

  /// 加载新的场景
  ///
  /// 如果场景对象已经存在的话,则提升到顶部
  Future<T> loadScene<T>(GameScene scene, {bool remove = false}) async {
    if (scene == null) {
      return null;
    }
    GameScene topScene;
    // 暂停顶层场景
    if (sceneLength > 0) {
      topScene = _scenes[sceneLength - 1];
      topScene?.onPause();
    }
    // 如果场景已经存在的话
    // 提升到顶部
    int sceneIndex = _scenes.indexOf(scene);
    if (sceneIndex >= 0) {
      GameScene tempScene = _scenes[sceneIndex];
      // 移除旧场景并放到新的后面
      _scenes.removeAt(sceneIndex);
      _scenes.add(tempScene);
      // 恢复场景
      tempScene?.onResume();
      rendererModule?.updateState();
      if (remove) {
        removeScene(topScene);
      }
      return scene.removed;
    }
    // 如果是新的场景则直接添加到最后
    _scenes.add(scene);
    scene.onAttach(moengine);
    rendererModule?.updateState();
    if (remove) {
      removeScene(topScene);
    }
    return scene.removed;
  }

  /// 移除顶层场景
  bool removeTopScene<T extends Object>([T result]) {
    if (_scenes == null || _scenes.isEmpty) {
      return false;
    }
    GameScene scene = _scenes[sceneLength - 1];
    _scenes.remove(scene);
    scene?.onDestroy();
    renderScene?.onResume();
    rendererModule?.updateState();
    // 返回给调用场景的数据
    scene?.removeCompleter?.complete(result);
    return true;
  }

  /// 根据对象移除场景
  bool removeScene<T extends Object>(GameScene scene, [T result]) {
    if (scene == null) {
      return false;
    }
    // 顶部的场景则调用移除顶部场景的方法
    if (_scenes.indexOf(scene) == sceneLength - 1) {
      return removeTopScene();
    }
    _scenes.remove(scene);
    scene.onDestroy();
    rendererModule?.updateState();
    // 返回给调用场景的数据
    scene?.removeCompleter?.complete(result);
    return true;
  }

  /// 移除所有场景
  void clearScene() {
    _scenes.forEach((GameScene scene) {
      scene?.onDestroy();
      scene?.removeCompleter?.completeError(null);
    });
    _scenes.clear();
    rendererModule?.updateState();
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

  @override
  void onResize(Size size) {
    this.size = size;
    renderScene?.onResize(size);
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
