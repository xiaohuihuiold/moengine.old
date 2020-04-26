import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:moengine/moengine.dart';

/// 引擎模块基础类
///
/// 负责给引擎提供可自定义的功能
abstract class EngineModule {
  /// 模块所属引擎实例
  @protected
  Moengine moengine; // ignore: unused_field

  /// 获取模块管理器
  @protected
  ModuleManager get moduleManager => moengine?.moduleManager;

  /// 模块被附加到引擎时调用
  ///
  /// [moengine] 是当前模块所属引擎实例
  @mustCallSuper
  void onAttach(Moengine moengine) {
    this.moengine = moengine;
  }

  /// 模块将要被移除时调用
  ///
  /// 返回值决定了当前模块在此时是否能够被移除
  /// 默认返回true
  bool onRemove() => true;

  /// 获取模块
  T getModule<T extends EngineModule>() {
    return moengine?.moduleManager?.getModule<T>();
  }

  /// 游戏绘制区域大小改变
  void onResize(Size size) {}

  /// 游戏被暂停/移入后台
  void onPause() {}

  /// 游戏恢复
  void onResume() {}

  /// 当模块被移除或者引擎被销毁时调用
  @mustCallSuper
  void onDestroy() {}
}
