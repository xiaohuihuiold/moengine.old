library moengine;

import 'package:moengine/engine/module/audio_module.dart';
import 'package:moengine/engine/module/engine_module.dart';
import 'package:moengine/engine/module/renderer_module.dart';
import 'package:moengine/engine/module/resource_module.dart';

/// Moengine引擎
class Moengine {
  /// 模块管理器
  ModuleManager moduleManager;

  Moengine({
    List<EngineModule> modules,
  }) {
    moduleManager = ModuleManager._fromModules(modules);
    moduleManager.onAttach(this);
  }
}

/// 模块管理器
///
/// 无论如何都是被第一个加载的模块
/// 可以管理引擎模块的添加移除生命周期
class ModuleManager extends EngineModule {
  /// 模块集合
  Map<Type, EngineModule> _modules;

  ModuleManager._internal();

  /// 通过模块列表创建模块
  factory ModuleManager._fromModules(List<EngineModule> modules) {
    ModuleManager moduleManager = ModuleManager._internal();
    moduleManager._modules = Map();

    // 检查重复模块
    Map<Type, int> modulesCount = Map();
    modules?.forEach((EngineModule module) {
      if (module is RendererModule) {
        modulesCount[RendererModule] ??= 0;
        modulesCount[RendererModule]++;
      } else if (module is AudioModule) {
        modulesCount[AudioModule] ??= 0;
        modulesCount[AudioModule]++;
      } else if (module is ResourceModule) {
        modulesCount[ResourceModule] ??= 0;
        modulesCount[ResourceModule]++;
      } else {
        modulesCount[module.runtimeType] ??= 0;
        modulesCount[module.runtimeType]++;
      }
    });
    // 当count大于1的数量超过0时代表有重复模块
    int repeatModuleCount =
        modulesCount.values.where((int count) => count > 1).length;
    assert(repeatModuleCount == 0, 'repeatModuleCount > 0');

    // 模块装载
    modules?.forEach((EngineModule module) {
      // 引擎需要的特殊模块虽然可以自定义
      // 但是查找时的类型必须是特殊模块基类
      if (module is RendererModule) {
        moduleManager._modules[RendererModule] = module;
      } else if (module is AudioModule) {
        moduleManager._modules[AudioModule] = module;
      } else if (module is ResourceModule) {
        moduleManager._modules[ResourceModule] = module;
      } else {
        moduleManager._modules[module.runtimeType] = module;
      }
    });
    return moduleManager;
  }

  @override
  void onAttach(Moengine moengine) {
    super.onAttach(moengine);
    _modules.forEach((_, EngineModule module) => module?.onAttach(moengine));
  }

  /// 不可移除
  @override
  bool onRemove() => false;

  @override
  void onDestroy() {
    _modules.forEach((_, EngineModule module) => module?.onDestroy());
  }
}
