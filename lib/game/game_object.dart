import 'package:moengine/game/component/game_component.dart';

/// 游戏对象
///
/// 展示在画面上除ui之外的所有物体的基础类
class GameObject {
  /// 游戏对象所含组件
  Map<Type, GameComponent> _components;

  GameObject([List<GameComponent> components]) {
    _components = Map();
    // 检查重复组件
    Map<Type, int> componentCount = Map();
    components?.forEach((GameComponent component) {
      if (component == null) {
        return;
      }
      componentCount[component.runtimeType] ??= 0;
      componentCount[component.runtimeType]++;
    });

    // 当count大于1的数量超过0时代表有重复组件
    int repeatComponentCount =
        componentCount.values.where((int count) => count > 1).length;
    assert(repeatComponentCount == 0, 'repeatComponentCount > 0');

    components?.forEach((GameComponent component) {
      if (component == null) {
        return;
      }
      component.gameObject = this;
      _components[component.runtimeType] = component;
    });
  }

  /// 添加组件
  bool addComponent(GameComponent component) {
    if (component == null) {
      return false;
    }
    // 当已经有同类型的组件时需要先移除
    assert(
        _components[component.runtimeType] == null, 'Need to be removed first');
    _components[component.runtimeType] = component;
    component.gameObject = this;
    return true;
  }

  /// 移除组件
  bool removeComponent(Type type) {
    if (type == null) {
      return false;
    }
    GameComponent component = _components[type];
    if (component == null) {
      return true;
    }
    component.gameObject = null;
    _components.remove(type);
    return true;
  }

  /// 移除所有组件
  void removeAllComponent() {
    _components?.forEach((_, GameComponent component) {
      component?.gameObject = null;
    });
    _components?.clear();
  }

  /// 获取组件
  T getComponent<T>() {
    return _components[T] as T;
  }

  /// 获取所有组件
  Iterable<GameComponent> getAllComponent() {
    return _components.values;
  }
}
