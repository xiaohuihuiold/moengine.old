import 'package:meta/meta.dart';
import 'package:moengine/moengine.dart';

/// 引擎模块基础类
/// 负责给引擎提供可自定义的功能
abstract class EngineModule {
  /// 模块所属引擎实例
  @protected
  Moengine moengine; // ignore: unused_field

  /// 模块被附加到引擎时调用
  ///
  /// [moengine] 是当前模块所属引擎实例
  void onAttach(Moengine moengine) {
    this.moengine = moengine;
  }

  /// 模块将要被移除时调用
  ///
  /// 返回值决定了当前模块在此时是否能够被移除
  /// 默认返回true
  bool onRemove() => true;

  /// 当模块被移除或者引擎被销毁时调用
  void onDestroy();
}
