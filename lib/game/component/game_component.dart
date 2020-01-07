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
  double x;
  double y;
}

/// 二维旋转组件
///
/// 简单的绕z轴旋转
/// 弧度
class Rotate2DComponent extends GameComponent {
  double radians;
}

/// 缩放组件
///
/// 宽高缩放
class ScaleComponent extends GameComponent {
  double w;
  double h;
}

/// 锚点组件
///
/// 旋转缩放的锚点
class AnchorComponent extends GameComponent {
  Offset anchor;
}

/// 精灵组件
///
/// 可以添加一张图片
class SpriteComponent extends GameComponent {
  Image image;
  double width;
  double height;
}

/// 自定义绘制组件
class CanvasComponent extends GameComponent {
  Function(Canvas canvas) render;
}
