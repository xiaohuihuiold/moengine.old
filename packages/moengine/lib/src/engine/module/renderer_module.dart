import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:moengine/src/engine/module/engine_module.dart';
import 'package:moengine/src/engine/module/scene_module.dart';
import 'package:moengine/src/game/component/game_component.dart';
import 'package:moengine/src/game/game_object.dart';

/// 渲染器模块基础类
///
/// 负责渲染游戏对象使用
abstract class RendererModule extends EngineModule {
  /// 缩放参数
  double scaleFactory = 1.0;

  /// 刷新函数
  ///
  /// 需要在子类中定义刷新方法
  Function() markNeedsPaint;

  /// setState
  Function(VoidCallback voidCallback) setState;

  /// 管理场景操作的模块
  @protected
  SceneModule get sceneModule => getModule<SceneModule>();

  /// 更新画面s
  void update() {
    if (markNeedsPaint != null) {
      markNeedsPaint();
    }
  }

  /// 刷新状态
  void updateState() {
    if (setState != null) {
      setState(() {});
    }
    update();
  }

  /// 渲染模块不可移除
  @override
  bool onRemove() => false;

  /// 渲染游戏画面
  @mustCallSuper
  Widget render(BuildContext context);
}

/// Canvas方式的渲染器
///
/// 使用Canvas渲染游戏对象
/// 使用flutter渲染ui
class CanvasRendererModule extends RendererModule {
  @override
  Widget render(BuildContext context) {
    return _CanvasRenderWidget(
      gameUi: sceneModule?.renderScene?.onBuildUi(context),
      sceneModule: sceneModule,
      rendererModule: this,
    );
  }
}

/// Canvas渲染部件
class _CanvasRenderWidget extends MultiChildRenderObjectWidget {
  final RendererModule rendererModule;
  final SceneModule sceneModule;

  _CanvasRenderWidget({
    Key key,
    this.rendererModule,
    this.sceneModule,
    List<Widget> gameUi = const <Widget>[],
  }) : super(key: key, children: gameUi ?? []);

  @override
  _RenderCanvas createRenderObject(BuildContext context) {
    return _RenderCanvas(
      rendererModule: rendererModule,
      sceneModule: sceneModule,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderCanvas renderObject) {
    renderObject
      ..rendererModule = rendererModule
      ..sceneModule = sceneModule;
  }
}

/// 自定义ParentData
class _CanvasParentData extends ContainerBoxParentData<RenderBox> {}

/// Canvas渲染对象
class _RenderCanvas extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _CanvasParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _CanvasParentData> {
  /// 场景模块,负责渲染回调
  SceneModule sceneModule;

  /// 渲染模块
  RendererModule _rendererModule;

  /// 画笔
  final Paint _gameObjectPaint = Paint();

  /// 绘制时间
  int _startTime;

  /// 将markNeedsPaint交给渲染模块
  set rendererModule(RendererModule rendererModule) {
    rendererModule?.markNeedsPaint = markNeedsPaint;
    _rendererModule = rendererModule;
  }

  _RenderCanvas({
    RendererModule rendererModule,
    this.sceneModule,
  }) {
    this.rendererModule = rendererModule;
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _CanvasParentData) {
      child.parentData = _CanvasParentData();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    RenderBox child = firstChild;
    while (child != null) {
      final _CanvasParentData childParentData = child.parentData;
      child.layout(constraints.loosen());
      child = childParentData.nextSibling;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // 计算一帧绘制时间
    int nowTime = DateTime.now().millisecondsSinceEpoch;
    _startTime ??= nowTime;
    int deltaTime = nowTime - _startTime;
    _startTime = nowTime;
    sceneModule?.renderScene?.onUpdate(deltaTime);
    // 绘制游戏对象
    List<GameObject> gameObjects = sceneModule?.renderScene?.gameObjects;
    if (gameObjects != null) {
      _paintGameObjects(gameObjects, context, offset);
    }
    // 绘制ui
    if (childCount != 0) {
      defaultPaint(context, offset);
    }
  }

  /// 绘制游戏对象
  void _paintGameObjects(
      List<GameObject> gameObjects, PaintingContext context, Offset offset) {
    Canvas canvas = context.canvas;

    canvas.save();
    // 裁剪游戏区域
    canvas.clipRect(
      Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
    );

    // 坐标对齐游戏视图坐标
    canvas.translate(offset.dx, offset.dy);
    // 渲染游戏对象
    gameObjects.forEach((GameObject gameObject) {
      if (gameObject == null) {
        return;
      }
      canvas.save();
      PaintComponent paintComponent = gameObject.getComponent<PaintComponent>();
      Paint drawPaint = paintComponent?.paint ?? _gameObjectPaint;
      // 测量
      Iterable<GameComponentMeasure> measures =
          gameObject.components.whereType<GameComponentMeasure>().toList();
      measures?.forEach((GameComponentMeasure gameComponentMeasure) {
        gameComponentMeasure?.onMeasure(
          gameObject,
          canvas,
          drawPaint,
          _rendererModule?.scaleFactory,
        );
      });

      // 测量之后也没有大小的话就不进行绘制
      if (gameObject.getComponent<SizeComponent>() == null) {
        return;
      }

      // 第一次绘制
      Iterable<GameComponentRender> renders =
          gameObject.components.whereType<GameComponentRender>().toList();
      renders?.forEach((GameComponentRender gameComponentRender) {
        gameComponentRender?.onBefore(
          gameObject,
          canvas,
          drawPaint,
          _rendererModule?.scaleFactory,
        );
      });

      // 第二次逆向绘制
      Iterable<GameComponentRender> reversedRenders = gameObject.components
          .whereType<GameComponentRender>()
          .toList()
          .reversed;
      reversedRenders?.forEach((GameComponentRender gameComponentRender) {
        gameComponentRender?.onAfter(
          gameObject,
          canvas,
          drawPaint,
          _rendererModule?.scaleFactory,
        );
      });

      canvas.restore();
    });

    canvas.translate(-offset.dx, -offset.dy);

    canvas.restore();
  }

  @override
  bool hitTest(BoxHitTestResult result, {ui.Offset position}) {
    if (size.contains(position)) {
      // 触发child事件则不对当前事件处理
      if (hitTestChildren(result, position: position)) {
        return false;
      } else if (hitTestSelf(position)) {
        result.add(BoxHitTestEntry(this, position));
      }
      return true;
    }
    return false;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {ui.Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
