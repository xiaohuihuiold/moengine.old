import 'package:meta/meta.dart';
import 'package:moengine/src/moengine.dart';

/// 引擎模块生命周期
abstract class EngineModuleInterface {
  void onAttach(Moengine moengine);

  void onResume();

  void onPause();

  bool onRemove();

  void onDestroy();
}

/// 引擎模块基类
///
/// 实现基本的模块生命周期
abstract class EngineModule implements EngineModuleInterface {
  @protected
  Moengine _moengine;

  bool _canRemove;

  bool removing = false;

  Moengine get moengine => _moengine;

  @protected
  set canRemove(bool value) => _canRemove = value;

  bool get canRemove => _canRemove ?? onRemove();

  @override
  @mustCallSuper
  void onAttach(Moengine moengine) {
    _moengine = moengine;
  }

  @override
  void onResume() {}

  @override
  void onPause() {}

  @override
  bool onRemove() => true;

  @override
  void onDestroy() {}
}
