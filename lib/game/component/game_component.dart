import 'dart:ui';

import 'package:moengine/game/game_object.dart';

/// 基础的游戏组件
///
/// 负责添加功能到游戏对象上
abstract class GameComponent {
  GameObject gameObject;
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
  Image image;
  Rect src;

  SpriteComponent({this.image, this.src});
}

/// 自定义绘制组件
class CanvasComponent extends GameComponent {
  Function(GameObject gameObject, Canvas canvas) render;

  CanvasComponent({this.render});
}
