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
    // 根据现有模块实例化管理器并执行附加操作
    moduleManager = ModuleManager._fromModules(modules);
    moduleManager._onAttach(this);
  }

  /// 当引擎被销毁时调用
  void _onDestroy() {
    moduleManager._onDestroy();
  }
}

/// 模块管理器
///
/// 无论如何都是被第一个加载的模块
/// 可以管理引擎模块的添加移除生命周期
class ModuleManager {
  /// 模块集合
  Map<Type, EngineModule> _modules;

  /// 模块管理器持有的引擎对象
  Moengine _moengine;

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

  /// 用于给所有模块附加上引擎对象
  void _onAttach(Moengine moengine) {
    _moengine = moengine;
    _modules.forEach((_, EngineModule module) => module?.onAttach(_moengine));
  }

  /// 用于销毁所有模块
  void _onDestroy() {
    _modules.forEach((_, EngineModule module) => module?.onDestroy());
    _modules.clear();
  }

  /// 添加模块
  /// [module] 添加一个模块
  bool addModule(EngineModule module) {
    if (module == null || _isEngineModule(module)) {
      return false;
    }
    // 当已经有同类型的模块时需要先移除
    assert(_modules[module.runtimeType] == null, 'Need to be removed first');
    _modules[module.runtimeType] = module;
    // 新添加的模块执行附加动作
    module.onAttach(_moengine);
    return true;
  }

  /// 移除一个模块
  /// [module] 移除的模块
  bool removeModule(Type type) {
    if (type == null) {
      return false;
    }
    if (_modules[type] == null) {
      return true;
    }
    EngineModule module = _modules[type];
    // 检查模块是否可以被移除
    if (!module.onRemove()) {
      return false;
    }
    // 执行销毁动作
    module.onDestroy();
    _modules.remove(type);
    return true;
  }

  /// 获取一个模块
  T getModule<T>() {
    return _modules[T] as T;
  }

  /// 检查是否是引擎模块
  bool _isEngineModule(EngineModule module) {
    return module is RendererModule ||
        module is AudioModule ||
        module is ResourceModule;
  }
}
