import 'package:moengine/src/engine/module/engine_module.dart';

/// 音频模块
///
/// 抽象音频缓存/播放管理方法
abstract class AudioModule extends EngineModule {
  @override
  bool get canRemove => false;
}

class DefaultAudioModule extends AudioModule{}
