import 'package:moengine/engine/exception/engine_exception.dart';
import 'package:moengine/game/component/game_component.dart';

/// 游戏对象
///
/// 展示在画面上除ui之外的所有物体的基础类
class GameObject {
  /// 游戏对象所含组件
  Map<Type, GameComponent> _componentMap = Map();

  Map<Type, GameComponent> get componentMap => _componentMap;

  set componentMap(Map<Type, GameComponent> value) =>
      _componentMap = value ?? Map();

  /// 游戏组件
  List<GameComponent> _components = List();

  List<GameComponent> get components => _components;

  set components(List<GameComponent> value) => _components = value ?? List();

  GameObject([List<GameComponent> components]) {
    // 检查重复组件
    Map<Type, int> componentCount = Map();
    components?.forEach((GameComponent component) {
      componentCount[component.runtimeType] ??= 0;
      componentCount[component.runtimeType]++;
    });

    // 当count大于1的数量超过0时代表有重复组件
    int repeatComponentCount =
        componentCount.values.where((int count) => count > 1).length;
    assert(repeatComponentCount == 0, 'repeatComponentCount > 0');
    if (!(repeatComponentCount == 0)) {
      throw ElementRepeatException();
    }

    // 添加组件到对象
    components?.forEach((GameComponent component) {
      if (component == null) {
        return;
      }
      component.gameObject = this;
      this.components.add(component);
      componentMap[component.runtimeType] = component;
    });
  }

  /// 添加组件
  bool addComponent(GameComponent component) {
    if (component == null) {
      return false;
    }
    // 当已经有同类型的组件时需要先移除
    assert(componentMap[component.runtimeType] == null,
        'Need to be removed first');
    if (!(componentMap[component.runtimeType] == null)) {
      return false;
    }
    component.gameObject = this;
    components.add(component);
    componentMap[component.runtimeType] = component;
    return true;
  }

  /// 移除组件
  bool removeComponent(Type typeOrComponent) {
    if (typeOrComponent == null) {
      return false;
    }
    GameComponent component = componentMap[typeOrComponent];
    if (component == null) {
      return true;
    }
    component.gameObject = null;
    components.remove(componentMap.remove(typeOrComponent));
    return true;
  }

  /// 根据下标移除组件
  bool removeComponentAt(int index) {
    if (index < 0 || index > components.length - 1) {
      return false;
    }
    componentMap.remove(components.removeAt(index)?.runtimeType);
    return true;
  }

  /// 移除所有组件
  void removeAllComponent() {
    components.forEach((GameComponent component) {
      component?.gameObject = null;
    });
    components.clear();
    componentMap.clear();
  }

  /// 获取组件
  T getComponent<T extends GameComponent>() {
    return componentMap[T];
  }

  /// 根据下标获取组件
  T getComponentAt<T extends GameComponent>(int index) {
    if (index < 0 || index > components.length - 1) {
      return null;
    }
    return components[index];
  }
}
