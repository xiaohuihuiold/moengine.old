import 'dart:math';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';
import 'dart:typed_data';

import 'package:moengine/game/game_object.dart';

/// 数据组件
mixin GameComponentData {}

/// 渲染组件,混合了此类的组件才需要进行渲染
mixin GameComponentRender {
  void onBefore(
      GameObject gameObject, Canvas canvas, Paint paint, double scaleFactory) {}

  void onAfter(
      GameObject gameObject, Canvas canvas, Paint paint, double scaleFactory) {}
}

/// 测量组件
mixin GameComponentMeasure {
  void onMeasure(
      GameObject gameObject, Canvas canvas, Paint paint, double scaleFactory) {}
}

/// 基础的游戏组件
///
/// 负责添加功能到游戏对象上
abstract class GameComponent {
  GameObject gameObject;
}

/// 位置组件
///
/// 包含坐标,旋转,缩放
class PositionComponent extends GameComponent with GameComponentRender {
  Offset position;
  double radians;
  Size scale;

  PositionComponent({
    this.position = const Offset(0.0, 0.0),
    this.radians = 0.0,
    this.scale = const Size(1.0, 1.0),
  });

  @override
  void onBefore(
      GameObject gameObject, Canvas canvas, Paint paint, double scaleFactory) {
    canvas.translate(position.dx, position.dy);
    canvas.rotate(radians);
    canvas.scale(scale.width, scale.height);
  }

  @override
  void onAfter(
      GameObject gameObject, Canvas canvas, Paint paint, double scaleFactory) {
    canvas.translate(-position.dx, -position.dy);
  }
}

/// 锚点组件
///
/// 旋转缩放的锚点
class AnchorComponent extends GameComponent with GameComponentRender {
  Offset anchor;

  AnchorComponent({
    this.anchor = const Offset(0.0, 0.0),
  });

  @override
  void onBefore(
      GameObject gameObject, Canvas canvas, Paint paint, double scaleFactory) {
    SizeComponent sizeComponent = gameObject.getComponent<SizeComponent>();
    Size size = sizeComponent.size;
    canvas.translate(-size.width * anchor.dx, -size.height * anchor.dy);
  }

  @override
  void onAfter(
      GameObject gameObject, Canvas canvas, Paint paint, double scaleFactory) {
    SizeComponent sizeComponent = gameObject.getComponent<SizeComponent>();
    Size size = sizeComponent.size;
    canvas.translate(size.width * anchor.dx, size.height * anchor.dy);
  }
}

/// 裁剪形状
enum ClipShape { rect, roundRect, circle }

/// 裁剪组件
///
/// 按对象尺寸裁剪
class ClipComponent extends GameComponent with GameComponentRender {
  ClipShape clipShape;
  Radius radius;

  ClipComponent({
    this.clipShape = ClipShape.rect,
    this.radius,
  });

  @override
  void onBefore(
      GameObject gameObject, Canvas canvas, Paint paint, double scaleFactory) {
    SizeComponent sizeComponent = gameObject.getComponent<SizeComponent>();
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

  TransformComponent({
    this.transform,
  });

  @override
  void onBefore(
      GameObject gameObject, Canvas canvas, Paint paint, double scaleFactory) {
    canvas.transform(transform);
  }
}

/// 精灵组件
///
/// 可以添加一张图片
class SpriteComponent extends GameComponent
    with GameComponentRender, GameComponentMeasure {
  Image image;
  Rect src;

  SpriteComponent({
    this.image,
    this.src,
  });

  @override
  void onMeasure(
      GameObject gameObject, Canvas canvas, Paint paint, double scaleFactory) {
    if (image == null) {
      return;
    }
    Size size = Size(src?.width ?? (image.width.toDouble() / scaleFactory),
        src?.height ?? (image.height.toDouble() / scaleFactory));
    SizeComponent sizeComponent = gameObject.getComponent<SizeComponent>();
    if (sizeComponent == null) {
      gameObject.addComponent(SizeComponent(size: size));
    } else if (!sizeComponent.immutable) {
      sizeComponent.size = size;
    }
  }

  @override
  void onBefore(
      GameObject gameObject, Canvas canvas, Paint paint, double scaleFactory) {
    if (image == null) {
      return;
    }
    SizeComponent sizeComponent = gameObject.getComponent<SizeComponent>();
    Size size = sizeComponent.size;
    Rect dst = Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    canvas.drawImageRect(
      image,
      src ??
          (Rect.fromLTWH(
            0.0,
            0.0,
            size.width * scaleFactory,
            size.height * scaleFactory,
          )),
      dst,
      paint,
    );
  }
}

/// 文本组件
class TextComponent extends GameComponent
    with GameComponentRender, GameComponentMeasure {
  String text;
  double fontSize;
  Color color;
  String fontFamily;
  TextAlign textAlign;
  TextDirection textDirection;
  TextPainter _textPainter;

  TextComponent({
    @required this.text,
    this.fontSize,
    this.color = const Color(0xff000000),
    this.fontFamily,
    this.textAlign,
    this.textDirection,
  });

  void _layout() {
    _textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontFamily: fontFamily,
        ),
      ),
      textAlign: textAlign ?? TextAlign.left,
      textDirection: textDirection ?? TextDirection.ltr,
    );
    _textPainter.layout();
  }

  @override
  void onMeasure(
      GameObject gameObject, Canvas canvas, Paint paint, double scaleFactory) {
    _layout();
    Size size = _textPainter.size;
    SizeComponent sizeComponent = gameObject.getComponent<SizeComponent>();
    if (sizeComponent == null) {
      gameObject.addComponent(SizeComponent(size: size));
    } else if (!sizeComponent.immutable) {
      sizeComponent.size = size;
    }
  }

  @override
  void onBefore(
      GameObject gameObject, Canvas canvas, Paint paint, double scaleFactory) {
    _layout();
    _textPainter.paint(canvas, Offset.zero);
  }
}

/// 自定义绘制组件
///
/// 简单的绘制特殊形状的组件
class RenderComponent extends GameComponent with GameComponentRender {
  Function(GameObject gameObject, Canvas canvas, Paint paint) customRender;

  RenderComponent({
    this.customRender,
  });

  @override
  void onBefore(
      GameObject gameObject, Canvas canvas, Paint paint, double scaleFactory) {
    customRender(gameObject, canvas, paint);
  }
}

/// 大小组件
///
/// 定义的绘制区域
class SizeComponent extends GameComponent with GameComponentData {
  Size size;
  bool immutable;

  SizeComponent({
    this.size = Size.zero,
    this.immutable = false,
  });
}

/// 画笔组件
///
/// 自定义游戏画笔
class PaintComponent extends GameComponent with GameComponentData {
  Paint paint;

  PaintComponent({
    this.paint,
  });
}
