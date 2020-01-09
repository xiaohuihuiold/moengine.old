import 'package:meta/meta.dart';
import 'package:flutter/widgets.dart';
import 'package:moengine/game/game_object.dart';

/// 基础的游戏场景
///
/// 根据需求提供更加合适的画面
/// 以及渲染指定的游戏对象
abstract class GameScene {
  /// 场景名
  String name;

  /// 当前场景游戏对象
  @protected
  List<GameObject> gameObjects;

  /// 当前场景ui
  @protected
  List<Widget> gameUi;

  /// 场景被创建
  ///
  /// 当场景被实例化时
  void onCreate() {}

  /// 场景被加入到游戏中
  ///
  /// 实例化之后加入到游戏里面,但是还没有展示出来
  void onAttach() {}

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
  void onDestroy() {}
}
