import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';
import 'package:moengine/src/moengine.dart';

/// 引擎模块基类
abstract class EngineModule {
  @protected
  Moengine _moengine;

  Moengine get moengine => _moengine;

  /// 能否被移除
  bool _canRemove;

  @protected
  set canRemove(bool value) => _canRemove = value;

  bool get canRemove => _canRemove ?? onRemove();

  /// 生命周期
  @mustCallSuper
  void onAttach(Moengine moengine) {
    _moengine = moengine;
  }

  void onResume() {}

  void onPause() {}

  void onResize(Size size) {}

  bool onRemove() => true;

  void onDestroy() {}
}
