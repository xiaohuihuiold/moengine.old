import 'package:moengine/src/engine/module/engine_module.dart';

/// 资源模块
///
/// 抽象管理本地/网络资源
abstract class ResourceModule extends EngineModule {
  @override
  bool get canRemove => false;
}

class DefaultResourceModule extends ResourceModule {}
