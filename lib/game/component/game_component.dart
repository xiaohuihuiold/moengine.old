import 'dart:math';
import 'dart:ui';
import 'package:meta/meta.dart';
import 'dart:typed_data';

import 'package:moengine/game/game_object.dart';

/// 基础的游戏组件
///
/// 负责添加功能到游戏对象上
abstract class GameComponent {
  GameObject gameObject;
}

/// 组件渲染类,混合了此类的组件才需要进行渲染
mixin GameComponentRender {
  void onBefore(GameObject gameObject, Canvas canvas, Paint paint) {}

  void onAfter(GameObject gameObject, Canvas canvas, Paint paint) {}
}

/// 位置组件
///
/// 包含坐标信息
class PositionComponent extends GameComponent with GameComponentRender {
  Offset position;

  PositionComponent({this.position});

  @override
  void onBefore(GameObject gameObject, Canvas canvas, Paint paint) {
    canvas.translate(position.dx, position.dy);
  }

  @override
  void onAfter(GameObject gameObject, Canvas canvas, Paint paint) {
    canvas.translate(-position.dx, -position.dy);
  }
}

/// 二维旋转组件
///
/// 简单的绕z轴旋转
/// 弧度
class Rotate2DComponent extends GameComponent with GameComponentRender {
  double radians;

  Rotate2DComponent({this.radians});

  @override
  void onBefore(GameObject gameObject, Canvas canvas, Paint paint) {
    SizeComponent sizeComponent = gameObject.componentMap[SizeComponent];
    Size size = sizeComponent.size;
    AnchorComponent anchorComponent = gameObject.componentMap[AnchorComponent];
    canvas.translate(size.width * anchorComponent.anchor.dx,
        size.width * anchorComponent.anchor.dx);
    canvas.rotate(radians);
    canvas.translate(-size.width * anchorComponent.anchor.dx,
        -size.width * anchorComponent.anchor.dx);
  }
}

/// 缩放组件
///
/// 宽高缩放
class ScaleComponent extends GameComponent with GameComponentRender {
  Size scale;

  ScaleComponent({this.scale});

  @override
  void onBefore(GameObject gameObject, Canvas canvas, Paint paint) {
    SizeComponent sizeComponent = gameObject.componentMap[SizeComponent];
    Size size = sizeComponent.size;
    AnchorComponent anchorComponent = gameObject.componentMap[AnchorComponent];
    canvas.translate(size.width * anchorComponent.anchor.dx,
        size.width * anchorComponent.anchor.dx);
    canvas.scale(scale.width, scale.height);
    canvas.translate(-size.width * anchorComponent.anchor.dx,
        -size.width * anchorComponent.anchor.dx);
  }
}

/// 锚点组件
///
/// 旋转缩放的锚点
class AnchorComponent extends GameComponent with GameComponentRender {
  Offset anchor;

  AnchorComponent({this.anchor});

  @override
  void onBefore(GameObject gameObject, Canvas canvas, Paint paint) {
    SizeComponent sizeComponent = gameObject.componentMap[SizeComponent];
    Size size = sizeComponent.size;
    canvas.translate(-size.width * anchor.dx, -size.width * anchor.dx);
  }

  @override
  void onAfter(GameObject gameObject, Canvas canvas, Paint paint) {
    SizeComponent sizeComponent = gameObject.componentMap[SizeComponent];
    Size size = sizeComponent.size;
    canvas.translate(size.width * anchor.dx, size.width * anchor.dx);
  }
}

/// 精灵组件
///
/// 可以添加一张图片
class SpriteComponent extends GameComponent with GameComponentRender {
  Image image;
  Rect src;

  SpriteComponent({this.image, this.src});

  @override
  void onBefore(GameObject gameObject, Canvas canvas, Paint paint) {}
}

/// 大小组件
///
/// 定义的绘制区域
class SizeComponent extends GameComponent {
  Size size;

  SizeComponent({this.size});
}

/// 画笔组件
///
/// 自定义游戏画笔
class PaintComponent extends GameComponent {
  Paint paint;

  PaintComponent({this.paint});
}

/// 裁剪形状
enum ClipShape { rect, roundRect, circle }

/// 裁剪组件
///
/// 按对象尺寸裁剪
class ClipComponent extends GameComponent with GameComponentRender {
  ClipShape clipShape;
  Radius radius;

  ClipComponent({this.clipShape, this.radius});

  @override
  void onBefore(GameObject gameObject, Canvas canvas, Paint paint) {
    SizeComponent sizeComponent = gameObject.componentMap[SizeComponent];
    Size size = sizeComponent.size;
    Radius radius = Radius.zero;
    switch (clipShape) {
      case ClipShape.rect:
        break;
      case ClipShape.roundRect:
        radius = this.radius ?? Radius.zero;
        break;
      case ClipShape.circle:
        radius = Radius.circular(max<double>(size.width, size.height) / 2.0);
        break;
    }
    canvas.clipRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0.0, 0.0, size.width, size.height), radius));
  }
}

/// 变换组件
///
/// 可以实现各种变换
class TransformComponent extends GameComponent with GameComponentRender {
  Float64List transform;

  TransformComponent({this.transform});

  @override
  void onBefore(GameObject gameObject, Canvas canvas, Paint paint) {
    canvas.transform(transform);
  }
}

/// 自定义绘制组件
///
/// 简单的绘制特殊形状的组件
class RenderComponent extends GameComponent with GameComponentRender {
  Function(GameObject gameObject, Canvas canvas, Paint paint) customRender;

  RenderComponent({this.customRender});

  @override
  void onBefore(GameObject gameObject, Canvas canvas, Paint paint) {
    customRender(gameObject, canvas, paint);
  }
}

/// 文本组件
class TextComponent extends GameComponent {
  String text;
  double fontSize;
  Color color;
  String fontFamily;
  TextAlign textAlign;
  TextDirection textDirection;

  TextComponent({
    @required this.text,
    this.fontSize,
    this.color,
    this.fontFamily,
    this.textAlign,
    this.textDirection,
  });
}
