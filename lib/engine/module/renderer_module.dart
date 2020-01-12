import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:moengine/engine/module/engine_module.dart';
import 'package:moengine/engine/module/scene_module.dart';

/// 渲染器模块基础类
///
/// 负责渲染游戏对象使用
abstract class RendererModule extends EngineModule {
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

  /// 将markNeedsPaint交给渲染模块
  set rendererModule(RendererModule rendererModule) {
    rendererModule?.markNeedsPaint = markNeedsPaint;
  }

  _RenderCanvas({
    rendererModule,
    this.sceneModule,
  });

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
    sceneModule?.renderScene?.onUpdate();
    Canvas canvas = context.canvas;
    if (childCount != 0) {
      defaultPaint(context, offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
