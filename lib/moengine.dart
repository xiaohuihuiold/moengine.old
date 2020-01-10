library moengine;

import 'package:flutter/widgets.dart';
import 'package:moengine/engine/module/audio_module.dart';
import 'package:moengine/engine/module/engine_module.dart';
import 'package:moengine/engine/module/renderer_module.dart';
import 'package:moengine/engine/module/resource_module.dart';
import 'package:moengine/engine/module/scene_module.dart';

/// Moengine引擎
class Moengine {
  /// 模块管理器
  ModuleManager moduleManager;

  Moengine({
    List<EngineModule> modules,
  }) {
    // 根据现有模块实例化管理器并执行附加操作
    moduleManager = ModuleManager._internal(modules);
    moduleManager._onAttach(this);
  }

  /// 构建游戏视图
  Widget renderGameView() {
    return getModule<RendererModule>()?.render();
  }

  /// 获取模块
  T getModule<T>() {
    return moduleManager?.getModule<T>();
  }

  /// 游戏进入后台
  void _onPause() {
    moduleManager._onPause();
  }

  /// 游戏从后台恢复
  void _onResume() {
    moduleManager._onResume();
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
  /// 模块管理器持有的引擎对象
  Moengine _moengine;

  /// 模块集合
  Map<Type, EngineModule> _modules;

  /// 获取所有模块
  Iterable<EngineModule> get allModule => _modules.values;

  /// 模块数量
  int get moduleLength => _modules.length;

  ModuleManager._internal([List<EngineModule> modules]) {
    _modules = Map();

    // 检查重复模块
    Map<Type, int> moduleCount = Map();
    modules?.forEach((EngineModule module) {
      if (module == null) {
        return;
      }
      if (module is RendererModule) {
        moduleCount[RendererModule] ??= 0;
        moduleCount[RendererModule]++;
      } else if (module is AudioModule) {
        moduleCount[AudioModule] ??= 0;
        moduleCount[AudioModule]++;
      } else if (module is ResourceModule) {
        moduleCount[ResourceModule] ??= 0;
        moduleCount[ResourceModule]++;
      } else if (module is SceneModule) {
        moduleCount[SceneModule] ??= 0;
        moduleCount[SceneModule]++;
      } else {
        moduleCount[module.runtimeType] ??= 0;
        moduleCount[module.runtimeType]++;
      }
    });
    // 当count大于1的数量超过0时代表有重复模块
    int repeatModuleCount =
        moduleCount.values.where((int count) => count > 1).length;
    assert(repeatModuleCount == 0, 'repeatModuleCount > 0');

    // 模块装载
    modules?.forEach((EngineModule module) {
      if (module == null) {
        return;
      }
      // 引擎需要的特殊模块虽然可以自定义
      // 但是查找时的类型必须是特殊模块基类
      if (module is RendererModule) {
        _modules[RendererModule] = module;
      } else if (module is AudioModule) {
        _modules[AudioModule] = module;
      } else if (module is ResourceModule) {
        _modules[ResourceModule] = module;
      } else if (module is SceneModule) {
        _modules[SceneModule] = module;
      } else {
        _modules[module.runtimeType] = module;
      }
    });

    // 设置默认模块
    _modules[RendererModule] ??= CanvasRendererModule();
    _modules[SceneModule] ??= SceneModule();
  }

  /// 用于给所有模块附加上引擎对象
  void _onAttach(Moengine moengine) {
    _moengine = moengine;
    _modules.forEach((_, EngineModule module) => module?.onAttach(_moengine));
  }

  /// 暂停所有模块
  void _onPause() {
    _modules.forEach((_, EngineModule module) => module?.onPause());
  }

  /// 恢复所有模块
  void _onResume() {
    _modules.forEach((_, EngineModule module) => module?.onResume());
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
    EngineModule module = _modules[type];
    if (module == null) {
      return true;
    }
    // 检查模块是否可以被移除
    if (!module.onRemove()) {
      return false;
    }
    _modules.remove(type);
    // 执行销毁动作
    module.onDestroy();
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
        module is ResourceModule ||
        module is SceneModule;
  }
}

/// 引擎渲染视图
class MoengineView extends StatefulWidget {
  /// 引擎对象
  final Moengine moengine;

  const MoengineView({
    Key key,
    @required this.moengine,
  }) : super(key: key);

  @override
  _MoengineViewState createState() => _MoengineViewState();
}

class _MoengineViewState extends State<MoengineView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    /// 添加观察者
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    /// 引擎销毁
    widget.moengine?._onDestroy();

    /// 移除观察者
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    /// 绑定app生命周期
    switch (state) {
      case AppLifecycleState.resumed:
        widget.moengine?._onResume();
        break;
      case AppLifecycleState.inactive:
        widget.moengine?._onPause();
        break;
      case AppLifecycleState.paused:
        widget.moengine?._onPause();
        break;
      case AppLifecycleState.suspending:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.moengine?.renderGameView();
  }
}
