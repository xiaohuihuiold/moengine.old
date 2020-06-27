import 'dart:ui';

import 'package:moengine/src/engine/module/engine_module.dart';

/// 渲染模块
///
/// 抽象引擎的渲染方法
abstract class RenderModule extends EngineModule {
  @override
  bool get canRemove => false;

  void onResize(Size size) {}
}

class DefaultRenderModule extends RenderModule {}
