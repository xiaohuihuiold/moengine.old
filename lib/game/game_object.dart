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

  /// 游戏自定义组件
  List<CustomComponent> _customComponents = List();

  List<CustomComponent> get customComponents => _customComponents;

  set customComponents(List<CustomComponent> value) =>
      _customComponents = value ?? List();

  /// 获取所有组件
  Iterable<GameComponent> get components => componentMap.values;

  GameObject([List<GameComponent> components]) {
    // 检查重复组件
    // 跳过自定义组件
    Map<Type, int> componentCount = Map();
    components?.forEach((GameComponent component) {
      if (component == null || component is CustomComponent) {
        return;
      }
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

    components?.forEach((GameComponent component) {
      if (component == null) {
        return;
      }
      // 自定义组件放入自定义组件列表
      if (component is CustomComponent &&
          !customComponents.contains(component)) {
        component.gameObject = this;
        customComponents.add(component);
        return;
      }
      component.gameObject = this;
      componentMap[component.runtimeType] = component;
    });
  }

  /// 添加组件
  bool addComponent(GameComponent component) {
    if (component == null) {
      return false;
    }
    // 自定义组件放入自定义组件列表
    if (component is CustomComponent) {
      bool hasComponent = customComponents.contains(component);
      assert(!hasComponent, 'Need to be removed first');
      if (!(!hasComponent)) {
        throw ElementRepeatException();
      }
      customComponents.add(component);
      return true;
    }
    // 当已经有同类型的组件时需要先移除
    assert(componentMap[component.runtimeType] == null,
        'Need to be removed first');
    if (!(componentMap[component.runtimeType] == null)) {
      return false;
    }
    componentMap[component.runtimeType] = component;
    component.gameObject = this;
    return true;
  }

  /// 移除组件
  bool removeComponent(dynamic typeOrComponent) {
    if (typeOrComponent == null) {
      return false;
    }
    // 是自定义组件时移除自定义组件
    if (typeOrComponent is CustomComponent) {
      customComponents.remove(typeOrComponent);
      return true;
    }
    // 不是type时不做操作
    if (typeOrComponent is! Type) {
      return false;
    }
    GameComponent component = componentMap[typeOrComponent];
    if (component == null) {
      return true;
    }
    component.gameObject = null;
    componentMap.remove(typeOrComponent);
    return true;
  }

  /// 根据下标移除组件
  bool removeComponentAt(int index) {
    if (index < 0 || index > customComponents.length - 1) {
      return false;
    }
    customComponents.removeAt(index);
    return true;
  }

  /// 移除所有组件
  void removeAllComponent() {
    componentMap.forEach((_, GameComponent component) {
      component?.gameObject = null;
    });
    componentMap.clear();
    customComponents.forEach((GameComponent component) {
      component?.gameObject = null;
    });
    customComponents.clear();
  }

  /// 获取组件
  T getComponent<T extends GameComponent>() {
    return componentMap[T];
  }

  /// 根据下标获取组件
  T getComponentAt<T extends CustomComponent>(int index) {
    if (index < 0 || index > customComponents.length - 1) {
      return null;
    }
    return customComponents[index];
  }
}
