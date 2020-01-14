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
    gameObjects.forEach((GameObject gameObject) {
      if (gameObject == null) {
        return;
      }
      Map<Type, GameComponent> componentMap = gameObject.componentMap;
      List<CustomComponent> customComponents = gameObject.customComponents;
      if (componentMap == null || componentMap.isEmpty) {
        return;
      }
      Paint drawPaint = _gameObjectPaint;
      // 取得所有组件
      AnchorComponent anchorComponent = componentMap[AnchorComponent];
      ScaleComponent scaleComponent = componentMap[ScaleComponent];
      Rotate2DComponent rotate2dComponent = componentMap[Rotate2DComponent];
      SpriteComponent spriteComponent = componentMap[SpriteComponent];
      SizeComponent sizeComponent = componentMap[SizeComponent];
      PositionComponent positionComponent = componentMap[PositionComponent];
      RenderComponent canvasComponent = componentMap[RenderComponent];
      ClipComponent clipComponent = componentMap[ClipComponent];
      PaintComponent paintComponent = componentMap[PaintComponent];

      // 设置自定义画笔
      if (paintComponent != null) {
        drawPaint = paintComponent.paint;
      }
      // 没有坐标的物体不绘制
      if (positionComponent == null) {
        return;
      }
      // 不是精灵并且也没有大小的物体也不进行绘制
      if (spriteComponent == null && sizeComponent == null) {
        return;
      }

      // 绘制坐标
      Offset position = positionComponent.position;
      // 锚点,默认锚点左上角
      Offset anchor = anchorComponent?.anchor ?? Offset.zero;
      // 游戏对象尺寸
      Size size = sizeComponent?.size;

      // 精灵组件
      ui.Image image = spriteComponent?.image;
      // 精灵图片读取范围,默认显示整个图片
      Rect src = spriteComponent?.src;
      if (src == null && image != null) {
        src = Rect.fromLTWH(
          0.0,
          0.0,
          image.width.toDouble(),
          image.height.toDouble(),
        );
      }
      // 图片缩放并变换为flutter尺寸
      if (src != null) {
        size ??= Size(
          src.width / _rendererModule.scaleFactory,
          src.height / _rendererModule.scaleFactory,
        );
      }

      // 当没有尺寸组件,并且也没有从精灵组件读取到宽高时则不进行绘制
      if (size == null) {
        return;
      }

      canvas.save();

      // 旋转画布
      if (rotate2dComponent != null) {
        canvas.translate(position.dx, position.dy);
        canvas.rotate(rotate2dComponent.radians);
        canvas.translate(-position.dx, -position.dy);
      }

      // 缩放画布
      if (scaleComponent != null) {
        canvas.translate(position.dx, position.dy);
        canvas.scale(scaleComponent.scale.width, scaleComponent.scale.height);
        canvas.translate(-position.dx, -position.dy);
      }

      // 根据坐标加上锚点位置确定最终坐标
      position = position.translate(
        -size.width * anchor?.dx,
        -size.height * anchor?.dy,
      );

      Rect dst =
          Rect.fromLTWH(position.dx, position.dy, size.width, size.height);

      // 执行裁剪
      if (clipComponent != null) {
        canvas.clipRect(dst);
      }

      // 绘制精灵
      if (spriteComponent != null && spriteComponent.image != null) {
        canvas.drawImageRect(
          image,
          src,
          dst,
          drawPaint,
        );
      }

      // 如果是canvas组件,则用户自行渲染
      canvas.translate(position.dx, position.dy);
      canvasComponent?.render(gameObject, canvas, drawPaint);
      canvas.translate(-position.dx, -position.dy);

      // 自定义组件渲染
      canvas.translate(position.dx, position.dy);
      customComponents.forEach((CustomComponent customComponent) {
        customComponent.render(gameObject, canvas, drawPaint);
      });
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
