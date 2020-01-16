import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:moengine/game/game_object.dart';

/// 基础的游戏组件
///
/// 负责添加功能到游戏对象上
abstract class GameComponent {
  GameObject gameObject;

  void render(GameObject gameObject, Canvas canvas, Paint paint) {}
}

/// 位置组件
///
/// 包含坐标信息
class PositionComponent extends GameComponent {
  Offset position;

  PositionComponent({this.position});
}

/// 二维旋转组件
///
/// 简单的绕z轴旋转
/// 弧度
class Rotate2DComponent extends GameComponent {
  double radians;

  Rotate2DComponent({this.radians});
}

/// 缩放组件
///
/// 宽高缩放
class ScaleComponent extends GameComponent {
  Size scale;

  ScaleComponent({this.scale});
}

/// 锚点组件
///
/// 旋转缩放的锚点
class AnchorComponent extends GameComponent {
  Offset anchor;

  AnchorComponent({this.anchor});
}

/// 精灵组件
///
/// 可以添加一张图片
class SpriteComponent extends GameComponent {
  ui.Image image;
  Rect src;

  SpriteComponent({this.image, this.src});
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
class ClipComponent extends GameComponent {
  ClipShape clipShape;
  Radius radius;

  ClipComponent({this.clipShape, this.radius});
}

/// 变换组件
///
/// 可以实现各种变换
class TransformComponent extends GameComponent {
  Float64List transform;

  TransformComponent({this.transform});
}

/// 自定义绘制组件
///
/// 简单的绘制特殊形状的组件
class RenderComponent extends GameComponent {
  Function(GameObject gameObject, Canvas canvas, Paint paint) customRender;

  RenderComponent({this.customRender});
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

/// 自定义组件
///
/// 可以自定义更多的组件
abstract class CustomComponent extends GameComponent {
  @override
  void render(GameObject gameObject, Canvas canvas, Paint paint);
}
