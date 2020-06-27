import 'package:moengine/src/engine/module/audio_module.dart';
import 'package:moengine/src/engine/module/engine_module.dart';
import 'package:moengine/src/engine/module/render_module.dart';
import 'package:moengine/src/engine/module/resource_module.dart';
import 'package:moengine/src/engine/module/scene_module.dart';
import 'package:moengine/src/moengine.dart';

/// 模块当前状态
enum _ModuleStatus {
  attached,
  resumed,
  paused,
  destroyed,
}

/// 模块管理器
///
/// 存储/获取/执行模块
class ModuleManager implements EngineModuleInterface {
  /// 模块状态
  _ModuleStatus _status;

  /// 引擎对象
  Moengine _moengine;

  /// 基础模块
  AudioModule _audioModule;
  RenderModule _renderModule;
  SceneModule _sceneModule;
  ResourceModule _resourceModule;
  final List<EngineModule> _modules = List();

  /// 扩展模块
  final Map<Type, EngineModule> _extensions = Map();

  AudioModule get audioModule => _audioModule;

  RenderModule get renderModule => _renderModule;

  SceneModule get sceneModule => _sceneModule;

  ResourceModule get resourceModule => _resourceModule;

  ModuleManager({
    AudioModule audioModule,
    RenderModule renderModule,
    SceneModule sceneModule,
    ResourceModule resourceModule,
  }) {
    _audioModule = audioModule ?? DefaultAudioModule();
    _renderModule = renderModule ?? DefaultRenderModule();
    _sceneModule = sceneModule ?? DefaultSceneModule();
    _resourceModule = resourceModule ?? DefaultResourceModule();
    _modules.addAll([
      _audioModule,
      _resourceModule,
      _sceneModule,
      _resourceModule,
    ]);
  }

  @override
  void onAttach(Moengine moengine) {
    _moengine = moengine;
    _modules.forEach((module) {
      module.onAttach(moengine);
    });
    _extensions.forEach((type, module) {
      if (module.removing) {
        return;
      }
      module.onAttach(moengine);
    });
    _status = _ModuleStatus.attached;
  }

  @override
  void onResume() {
    _modules.forEach((module) {
      module.onResume();
    });
    _extensions.forEach((type, module) {
      if (module.removing) {
        return;
      }
      module.onResume();
    });
    _status = _ModuleStatus.resumed;
  }

  @override
  void onPause() {
    _modules.forEach((module) {
      module.onPause();
    });
    _extensions.forEach((type, module) {
      if (module.removing) {
        return;
      }
      module.onPause();
    });
    _status = _ModuleStatus.paused;
  }

  @override
  bool onRemove() => true;

  @override
  void onDestroy() {
    _modules.forEach((module) {
      module.onDestroy();
    });
    _extensions.forEach((type, module) {
      if (module.removing) {
        return;
      }
      module.onDestroy();
    });
    _status = _ModuleStatus.destroyed;
  }

  ModuleType getExtension<ModuleType extends EngineModule>() {
    return _extensions[ModuleType];
  }

  bool putExtension(EngineModule module) {
    if (_extensions[module.runtimeType] != null) {
      return false;
    }
    _extensions[module.runtimeType] = module;
    switch (_status) {
      case _ModuleStatus.attached:
        module.onAttach(_moengine);
        break;
      case _ModuleStatus.resumed:
        module.onAttach(_moengine);
        module.onResume();
        break;
      case _ModuleStatus.paused:
        module.onAttach(_moengine);
        break;
      case _ModuleStatus.destroyed:
        module.onAttach(_moengine);
        module.onDestroy();
        break;
    }
    return true;
  }

  bool removeExtension<ModuleType extends EngineModule>() {
    EngineModule module = _extensions[ModuleType];
    if (module == null) {
      return true;
    }
    if (module.canRemove) {
      module.removing = true;
      module.onPause();
      module.onDestroy();
      _extensions.remove(ModuleType);
      return true;
    } else {
      return false;
    }
  }
}
