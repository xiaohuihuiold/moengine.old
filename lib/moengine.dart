library moengine;

import 'package:flutter/widgets.dart';
import 'package:moengine/engine/exception/engine_exception.dart';
import 'package:moengine/engine/module/audio_module.dart';
import 'package:moengine/engine/module/engine_module.dart';
import 'package:moengine/engine/module/renderer_module.dart';
import 'package:moengine/engine/module/resource_module.dart';
import 'package:moengine/engine/module/scene_module.dart';
import 'package:moengine/game/scene/game_scene.dart';

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
    return moduleManager.getModule<T>();
  }

  /// 绘制区域大小变化
  void _onResize(Size size) {
    moduleManager._onResize(size);
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
  void destroy() {
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
  Map<Type, EngineModule> _moduleMap;

  /// 获取所有模块
  Iterable<EngineModule> get modules => _moduleMap.values;

  /// 模块数量
  int get moduleLength => _moduleMap.length;

  /// 系统模块
  RendererModule _rendererModule;
  AudioModule _audioModule;
  ResourceModule _resourceModule;
  SceneModule _sceneModule;

  ModuleManager._internal([List<EngineModule> modules]) {
    _moduleMap = Map();

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
    if (!(repeatModuleCount == 0)) {
      throw ElementRepeatException();
    }

    // 模块装载
    modules?.forEach((EngineModule module) {
      if (module == null) {
        return;
      }
      // 引擎需要的特殊模块虽然可以自定义
      // 但是查找时的类型必须是特殊模块基类
      if (module is RendererModule) {
        _rendererModule = module;
      } else if (module is AudioModule) {
        _audioModule = module;
      } else if (module is ResourceModule) {
        _resourceModule = module;
      } else if (module is SceneModule) {
        _sceneModule = module;
      } else {
        _moduleMap[module.runtimeType] = module;
      }
    });

    // 设置默认模块
    _rendererModule ??= CanvasRendererModule();
    _sceneModule ??= SceneModule();

    _moduleMap[RendererModule] = _rendererModule;
    _moduleMap[AudioModule] = _audioModule;
    _moduleMap[ResourceModule] = _resourceModule;
    _moduleMap[SceneModule] = _sceneModule;
  }

  /// 用于给所有模块附加上引擎对象
  void _onAttach(Moengine moengine) {
    _moengine = moengine;
    _moduleMap.forEach((_, EngineModule module) => module?.onAttach(_moengine));
  }

  /// 绘制区域大小变化
  void _onResize(Size size) {
    _moduleMap.forEach((_, EngineModule module) => module?.onResize(size));
  }

  /// 暂停所有模块
  void _onPause() {
    _moduleMap.forEach((_, EngineModule module) => module?.onPause());
  }

  /// 恢复所有模块
  void _onResume() {
    _moduleMap.forEach((_, EngineModule module) => module?.onResume());
  }

  /// 用于销毁所有模块
  void _onDestroy() {
    _moduleMap.forEach((_, EngineModule module) => module?.onDestroy());
    _rendererModule = null;
    _audioModule = null;
    _resourceModule = null;
    _sceneModule = null;
    _moduleMap.clear();
  }

  /// 添加模块
  /// [module] 添加一个模块
  bool addModule(EngineModule module) {
    if (module == null || _isEngineModule(module)) {
      return false;
    }
    // 当已经有同类型的模块时需要先移除
    assert(_moduleMap[module.runtimeType] == null, 'Need to be removed first');
    if (!(_moduleMap[module.runtimeType] == null)) {
      throw ElementRepeatException();
    }

    _moduleMap[module.runtimeType] = module;
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
    EngineModule module = _moduleMap[type];
    if (module == null) {
      return true;
    }
    // 检查模块是否可以被移除
    if (!module.onRemove()) {
      return false;
    }
    _moduleMap.remove(type);
    // 执行销毁动作
    module.onDestroy();
    return true;
  }

  /// 获取一个模块
  T getModule<T>() {
    switch (T) {
      case RendererModule:
        return _rendererModule as T;
      case AudioModule:
        return _audioModule as T;
      case ResourceModule:
        return _resourceModule as T;
      case SceneModule:
        return _sceneModule as T;
    }
    return _moduleMap[T] as T;
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
  Size _widgetSize;

  GameScene get _scene =>
      widget.moengine?.getModule<SceneModule>()?.renderScene;

  @override
  void initState() {
    super.initState();
    RendererModule rendererModule =
        widget.moengine?.getModule<RendererModule>();

    // 更新状态
    rendererModule?.setState = setState;

    // 添加观察者
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // 不要在这里销毁引擎
    Moengine moengine = widget.moengine;
    RendererModule rendererModule = moengine?.getModule<RendererModule>();

    // 清除状态
    rendererModule?.setState = null;

    // 移除观察者
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Moengine moengine = widget.moengine;
    // 绑定app生命周期
    switch (state) {
      case AppLifecycleState.resumed:
        moengine?._onResume();
        break;
      case AppLifecycleState.inactive:
        moengine?._onPause();
        break;
      case AppLifecycleState.paused:
        moengine?._onPause();
        break;
      default:
        break;
    }
  }

  /// 当一帧绘制完成后
  ///
  /// 主要是检测绘制区域变化
  void _onUpdated(Duration timeStamp) {
    Moengine moengine = widget.moengine;
    RenderBox renderBox = context.findRenderObject();

    // 检测大小是否改变
    Size renderSize = renderBox.size;
    if (_widgetSize != renderSize) {
      _widgetSize = renderSize;
      moengine?._onResize(_widgetSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    Moengine moengine = widget.moengine;
    RendererModule rendererModule = moengine?.getModule<RendererModule>();
    GameScene scene = _scene;
    // 添加帧回调
    WidgetsBinding.instance.addPostFrameCallback(_onUpdated);
    rendererModule?.scaleFactory = MediaQuery.of(context).devicePixelRatio;
    return MouseRegion(
      onEnter: scene is MouseDetector ? (scene as MouseDetector).onEnter : null,
      onHover: scene is MouseDetector ? (scene as MouseDetector).onHover : null,
      onExit: scene is MouseDetector ? (scene as MouseDetector).onExit : null,
      child: GestureDetector(
        // tap
        onTapDown:
            scene is TapDetector ? (scene as TapDetector).onTapDown : null,
        onTapUp: scene is TapDetector ? (scene as TapDetector).onTapUp : null,
        onTap: scene is TapDetector ? (scene as TapDetector).onTap : null,
        onTapCancel:
            scene is TapDetector ? (scene as TapDetector).onTapCancel : null,
        // secondary
        onSecondaryTapDown: scene is SecondaryTapDetector
            ? (scene as SecondaryTapDetector).onSecondaryTapDown
            : null,
        onSecondaryTapUp: scene is SecondaryTapDetector
            ? (scene as SecondaryTapDetector).onSecondaryTapUp
            : null,
        onSecondaryTapCancel: scene is SecondaryTapDetector
            ? (scene as SecondaryTapDetector).onSecondaryTapCancel
            : null,
        // double tap
        onDoubleTap: scene is DoubleTapDetector
            ? (scene as DoubleTapDetector).onDoubleTap
            : null,
        // long press
        onLongPress: scene is LongPressDetector
            ? (scene as LongPressDetector).onLongPress
            : null,
        onLongPressStart: scene is LongPressDetector
            ? (scene as LongPressDetector).onLongPressStart
            : null,
        onLongPressMoveUpdate: scene is LongPressDetector
            ? (scene as LongPressDetector).onLongPressMoveUpdate
            : null,
        onLongPressUp: scene is LongPressDetector
            ? (scene as LongPressDetector).onLongPressUp
            : null,
        onLongPressEnd: scene is LongPressDetector
            ? (scene as LongPressDetector).onLongPressEnd
            : null,
        // vertical drag
        onVerticalDragDown: scene is VerticalDragDetector
            ? (scene as VerticalDragDetector).onVerticalDragDown
            : null,
        onVerticalDragStart: scene is VerticalDragDetector
            ? (scene as VerticalDragDetector).onVerticalDragStart
            : null,
        onVerticalDragUpdate: scene is VerticalDragDetector
            ? (scene as VerticalDragDetector).onVerticalDragUpdate
            : null,
        onVerticalDragEnd: scene is VerticalDragDetector
            ? (scene as VerticalDragDetector).onVerticalDragEnd
            : null,
        onVerticalDragCancel: scene is VerticalDragDetector
            ? (scene as VerticalDragDetector).onVerticalDragCancel
            : null,
        // horizontal drag
        onHorizontalDragDown: scene is HorizontalDragDetector
            ? (scene as HorizontalDragDetector).onHorizontalDragDown
            : null,
        onHorizontalDragStart: scene is HorizontalDragDetector
            ? (scene as HorizontalDragDetector).onHorizontalDragStart
            : null,
        onHorizontalDragUpdate: scene is HorizontalDragDetector
            ? (scene as HorizontalDragDetector).onHorizontalDragUpdate
            : null,
        onHorizontalDragEnd: scene is HorizontalDragDetector
            ? (scene as HorizontalDragDetector).onHorizontalDragEnd
            : null,
        onHorizontalDragCancel: scene is HorizontalDragDetector
            ? (scene as HorizontalDragDetector).onHorizontalDragCancel
            : null,
        // force press
        onForcePressStart: scene is ForcePressDetector
            ? (scene as ForcePressDetector).onForcePressStart
            : null,
        onForcePressPeak: scene is ForcePressDetector
            ? (scene as ForcePressDetector).onForcePressPeak
            : null,
        onForcePressUpdate: scene is ForcePressDetector
            ? (scene as ForcePressDetector).onForcePressUpdate
            : null,
        onForcePressEnd: scene is ForcePressDetector
            ? (scene as ForcePressDetector).onForcePressEnd
            : null,
        // pan
        onPanDown:
            scene is PanDetector ? (scene as PanDetector).onPanDown : null,
        onPanStart:
            scene is PanDetector ? (scene as PanDetector).onPanStart : null,
        onPanUpdate:
            scene is PanDetector ? (scene as PanDetector).onPanUpdate : null,
        onPanEnd: scene is PanDetector ? (scene as PanDetector).onPanEnd : null,
        onPanCancel:
            scene is PanDetector ? (scene as PanDetector).onPanCancel : null,
        // scale
        onScaleStart: scene is ScaleDetector
            ? (scene as ScaleDetector).onScaleStart
            : null,
        onScaleUpdate: scene is ScaleDetector
            ? (scene as ScaleDetector).onScaleUpdate
            : null,
        onScaleEnd:
            scene is ScaleDetector ? (scene as ScaleDetector).onScaleEnd : null,
        behavior: HitTestBehavior.opaque,
        child: moengine?.renderGameView(),
      ),
    );
  }
}
