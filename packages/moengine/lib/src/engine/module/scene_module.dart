import 'package:moengine/src/engine/module/engine_module.dart';

/// 场景模块
///
/// 抽象Scene动作方法
abstract class SceneModule extends EngineModule {
  @override
  bool get canRemove => false;
}

class DefaultSceneModule extends SceneModule {}
