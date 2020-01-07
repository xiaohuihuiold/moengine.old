import 'package:flutter_test/flutter_test.dart';
import 'package:moengine/engine/module/engine_module.dart';
import 'package:moengine/engine/module/renderer_module.dart';
import 'package:moengine/moengine.dart';

void main() {
  // 模块管理器测试
  test('ModuleManager test', () {
    // 测试是否能够检查重复
    Moengine(
      modules: [
        TestModule(),
        TestAModule(),
        TestARendererModule(),
      ],
    );
  });
}

class TestRendererModule extends RendererModule {}

class TestARendererModule extends RendererModule {}

class TestModule extends EngineModule {}

class TestAModule extends EngineModule {}
