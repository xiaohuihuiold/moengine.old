import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';
import 'package:flutter/widgets.dart';
import 'package:moengine/engine/module/renderer_module.dart';
import 'package:moengine/engine/module/scene_module.dart';
import 'package:moengine/game/game_object.dart';
import 'package:moengine/moengine.dart';

/// 基础的游戏场景
///
/// 根据需求提供更加合适的画面
/// 以及渲染指定的游戏对象
abstract class GameScene {
  /// 场景名
  String name;

  /// 场景大小
  @protected
  Size size;

  /// 当前场景游戏对象
  List<GameObject> gameObjects;

  /// 引擎对象
  @protected
  Moengine moengine;

  /// 模块管理器
  @protected
  ModuleManager get moduleManager => moengine?.moduleManager;

  /// 场景模块
  @protected
  SceneModule get sceneModule => moduleManager?.getModule<SceneModule>();

  /// 渲染模块
  @protected
  RendererModule get rendererModule =>
      moduleManager?.getModule<RendererModule>();

  GameScene() {
    gameObjects = List();
  }

  /// 更新
  @protected
  void update() {
    rendererModule?.update();
  }

  /// 更新状态
  @protected
  void updateState() {
    rendererModule?.updateState();
  }

  /// 场景被加入到游戏中
  ///
  /// 实例化之后加入到游戏里面,但是还没有展示出来
  @mustCallSuper
  void onAttach(Moengine moengine) {
    this.moengine = moengine;
  }

  /// 构建ui
  List<Widget> onBuildUi() {
    return null;
  }

  /// 游戏绘制区域大小改变
  @mustCallSuper
  void onResize(Size size) {
    this.size = size;
  }

  /// 游戏画面的更新
  void onUpdate(int deltaTime);

  /// 场景被暂停/移入后台
  ///
  /// 切换到新的场景,当前场景被移入后台
  void onPause() {}

  /// 场景恢复
  ///
  /// 从新的场景退回当前场景
  void onResume() {}

  /// 场景被销毁
  ///
  /// 从游戏中关闭场景或者移除场景时触发
  @mustCallSuper
  void onDestroy() {}
}

mixin MouseDetector {
  void onEnter(PointerEnterEvent event);

  void onHover(PointerHoverEvent event);

  void onExit(PointerExitEvent event);
}

mixin TapDetector {
  void onTapDown(TapDownDetails details);

  void onTapUp(TapUpDetails details);

  void onTap();

  void onTapCancel();
}

mixin SecondaryTapDetector {
  void onSecondaryTapDown(TapDownDetails details);

  void onSecondaryTapUp(TapUpDetails details);

  void onSecondaryTapCancel();
}

mixin DoubleTapDetector {
  void onDoubleTap();
}

mixin LongPressDetector {
  void onLongPress();

  void onLongPressStart(LongPressStartDetails details);

  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details);

  void onLongPressUp();

  void onLongPressEnd(LongPressEndDetails details);
}

mixin VerticalDragDetector {
  void onVerticalDragDown(DragDownDetails details);

  void onVerticalDragStart(DragStartDetails details);

  void onVerticalDragUpdate(DragUpdateDetails details);

  void onVerticalDragEnd(DragEndDetails details);

  void onVerticalDragCancel();
}

mixin HorizontalDragDetector {
  void onHorizontalDragDown(DragDownDetails details);

  void onHorizontalDragStart(DragStartDetails details);

  void onHorizontalDragUpdate(DragUpdateDetails details);

  void onHorizontalDragEnd(DragEndDetails details);

  void onHorizontalDragCancel();
}

mixin ForcePressDetector {
  void onForcePressStart(ForcePressDetails details);

  void onForcePressPeak(ForcePressDetails details);

  void onForcePressUpdate(ForcePressDetails details);

  void onForcePressEnd(ForcePressDetails details);
}

mixin PanDetector {
  void onPanDown(DragDownDetails details);

  void onPanStart(DragStartDetails details);

  void onPanUpdate(DragUpdateDetails details);

  void onPanEnd(DragEndDetails details);

  void onPanCancel();
}

mixin ScaleDetector {
  void onScaleStart(ScaleStartDetails de);

  void onScaleUpdate(ScaleUpdateDetails details);

  void onScaleEnd(ScaleEndDetails details);
}
