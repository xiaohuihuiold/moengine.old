import 'package:moengine/game/component/game_component.dart';

/// 游戏对象
///
/// 展示在画面上除ui之外的所有物体的基础类
class GameObject {
  /// 游戏对象所含组件
  Map<Type, GameComponent> _components = Map();

  Map<Type, GameComponent> get components => _components;

  set components(Map<Type, GameComponent> component) =>
      _components = component ?? Map();

  /// 获取所有组件
  Iterable<GameComponent> get allComponent => components.values;

  GameObject([List<GameComponent> components]) {
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
      this.components[component.runtimeType] = component;
    });
  }

  /// 添加组件
  bool addComponent(GameComponent component) {
    if (component == null) {
      return false;
    }
    // 当已经有同类型的组件时需要先移除
    assert(
        components[component.runtimeType] == null, 'Need to be removed first');
    components[component.runtimeType] = component;
    component.gameObject = this;
    return true;
  }

  /// 移除组件
  bool removeComponent(Type type) {
    if (type == null) {
      return false;
    }
    GameComponent component = components[type];
    if (component == null) {
      return true;
    }
    component.gameObject = null;
    components.remove(type);
    return true;
  }

  /// 移除所有组件
  void removeAllComponent() {
    components.forEach((_, GameComponent component) {
      component?.gameObject = null;
    });
    components.clear();
  }

  /// 获取组件
  T getComponent<T>() {
    return components[T] as T;
  }
}
