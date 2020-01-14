import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:moengine/engine/module/engine_module.dart';
import 'package:moengine/engine/module/scene_module.dart';
import 'package:moengine/game/component/game_component.dart';
import 'package:moengine/game/game_object.dart';

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
  }

  /// 渲染模块不可移除
  @override
  bool onRemove() => false;

  @override
  void onResize(Size size) {
    sceneModule?.renderScene?.onResize(size);
  }

  /// 渲染游戏画面
  @mustCallSuper
  Widget render();
}

/// Canvas方式的渲染器
///
/// 使用Canvas渲染游戏对象
/// 使用flutter渲染ui
class CanvasRendererModule extends RendererModule {
  @override
  Widget render() {
    return _CanvasRenderWidget(
      gameUi: sceneModule?.renderScene?.onBuildUi(),
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
    // 坐标对其游戏视图坐标
    canvas.translate(offset.dx, offset.dy);
    gameObjects.forEach((GameObject gameObject) {
      if (gameObject == null) {
        return;
      }
      Map<Type, GameComponent> componentMap = gameObject.componentMap;
      if (componentMap == null) {
        return;
      }
      // 取得所有组件
      AnchorComponent anchorComponent = componentMap[AnchorComponent];
      ScaleComponent scaleComponent = componentMap[ScaleComponent];
      Rotate2DComponent rotate2dComponent = componentMap[Rotate2DComponent];
      SpriteComponent spriteComponent = componentMap[SpriteComponent];
      PositionComponent positionComponent = componentMap[PositionComponent];
      CanvasComponent canvasComponent = componentMap[CanvasComponent];

      if (positionComponent == null || spriteComponent == null) {
        // 当绘制的不是精灵,但是有自定义的渲染组件时
        if (canvasComponent != null) {
          canvasComponent.render(gameObject, canvas);
        }
        return;
      }

      // 当绘制的是精灵时
      ui.Image image = spriteComponent.image;
      Offset position = positionComponent.position;
      // 默认锚点左上角
      Offset anchor = anchorComponent?.anchor ?? Offset.zero;
      // 默认缩放原比例
      Size scale = scaleComponent?.scale ?? const Size(1.0, 1.0);
      // 默认显示整个图片
      Rect src = spriteComponent.src ??
          Rect.fromLTWH(
            0.0,
            0.0,
            image.width.toDouble(),
            image.height.toDouble(),
          );
      // 图片缩放并变换为flutter尺寸
      Size size = Size(src.width * scale.width / _rendererModule.scaleFactory,
          src.height * scale.height / _rendererModule.scaleFactory);

      canvas.save();

      // 旋转画布
      if (rotate2dComponent != null) {
        canvas.translate(position.dx, position.dy);
        canvas.rotate(rotate2dComponent.radians);
        canvas.translate(-position.dx, -position.dy);
      }

      // 根据坐标加上锚点位置确定最终坐标
      position = position.translate(
        -size.width * anchor?.dx,
        -size.height * anchor?.dy,
      );
      canvas.drawImageRect(
        image,
        src,
        ui.Rect.fromLTWH(position.dx, position.dy, size.width, size.height),
        _gameObjectPaint,
      );
      // 如果是canvas组件,则用户自行渲染
      canvas.translate(position.dx, position.dy);
      canvasComponent?.render(gameObject, canvas);
      canvas.translate(-position.dx, -position.dy);

      canvas.restore();
    });

    canvas.translate(-offset.dx, -offset.dy);
    canvas.restore();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
