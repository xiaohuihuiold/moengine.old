import 'package:meta/meta.dart';
import 'package:flutter/widgets.dart';
import 'package:moengine/engine/module/renderer_module.dart';
import 'package:moengine/engine/module/scene_module.dart';
import 'package:moengine/game/game_object.dart';
import 'package:moengine/moengine.dart';

/// 基础的游戏场景
///
/// 根据需求提供更加合适的画面
/// 以及渲染指定的游戏对象
abstract class GameScene {
  /// 场景名
  String name;

  /// 当前场景游戏对象
  List<GameObject> gameObjects;

  /// 引擎对象
  @protected
  Moengine moengine;

  /// 模块管理器
  @protected
  ModuleManager get moduleManager => moengine?.moduleManager;

  /// 场景模块
  @protected
  SceneModule get sceneModule => moduleManager?.getModule<SceneModule>();

  /// 渲染模块
  @protected
  RendererModule get rendererModule =>
      moduleManager?.getModule<RendererModule>();

  GameScene() {
    gameObjects = List();
  }

  /// 场景被加入到游戏中
  ///
  /// 实例化之后加入到游戏里面,但是还没有展示出来
  @mustCallSuper
  void onAttach(Moengine moengine) {
    this.moengine = moengine;
  }

  /// 构建ui
  List<Widget> onBuildUi() {
    return null;
  }

  /// 游戏绘制区域大小改变
  void onResize(Size size) {}

  /// 游戏画面的更新
  void onUpdate();

  /// 场景被暂停/移入后台
  ///
  /// 切换到新的场景,当前场景被移入后台
  void onPause() {}

  /// 场景恢复
  ///
  /// 从新的场景退回当前场景
  void onResume() {}

  /// 场景被销毁
  ///
  /// 从游戏中关闭场景或者移除场景时触发
  @mustCallSuper
  void onDestroy() {}
}
