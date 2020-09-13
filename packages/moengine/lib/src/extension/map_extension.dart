import 'dart:collection';

/// Map基础信息
abstract class MapInfo<K, V> {
  int get length;

  Iterable<K> get keys;

  Iterable<V> get values;

  dynamic has(List<K> keys);

  bool containsKey(K key);

  bool containsValue(V value);
}

/// 根据值Type来存放值
class TypeMap implements MapInfo<Type, dynamic> {
  final Map<Type, dynamic> _map = LinkedHashMap();

  ValueType get<ValueType>([Type type]) {
    dynamic value = _map[type ?? ValueType];
    if (value == null || value is! ValueType) {
      return null;
    }
    return value as ValueType;
  }

  void put(dynamic value, [Type type]) {
    if (value == null && type == null) {
      return;
    }
    type ??= value.runtimeType;
    _map[type] = value;
  }

  ValueType remove<ValueType>([Type type]) {
    ValueType value = get<ValueType>(type);
    _map.remove(type ?? ValueType);
    return value;
  }

  void clear() {
    _map.clear();
  }

  @override
  int get length => _map.length;

  @override
  Iterable<Type> get keys => _map.keys;

  @override
  Iterable<dynamic> get values => _map.values;

  @override
  TypeMap has(List<Type> keys, {bool hasNull = true}) {
    TypeMap typeMap = TypeMap();
    for (Type type in keys) {
      if (hasNull) {
        if (!containsKey(type)) {
          return null;
        }
      } else {
        if (get(type) == null) {
          return null;
        }
      }
      typeMap.put(get(type), type);
    }
    return typeMap;
  }

  @override
  bool containsKey(Type key) => _map.containsKey(key);

  @override
  bool containsValue(dynamic value) => _map.containsValue(value);

  @override
  String toString() {
    return _map.toString();
  }
}
