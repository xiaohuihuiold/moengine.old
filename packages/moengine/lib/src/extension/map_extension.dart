import 'dart:collection';

/// TODO: desc
abstract class MapInfo<K, V> {
  int get length;

  Iterable<K> get keys;

  Iterable<V> get values;

  bool containsKey(K key);

  bool containsValue(V value);
}

/// TODO: desc
class TypeMap implements MapInfo<Type, dynamic> {
  final Map<Type, dynamic> _map = LinkedHashMap();

  ValueType get<ValueType>() {
    dynamic value = _map[ValueType];
    if (value == null || value is! ValueType) {
      return null;
    }
    return value as ValueType;
  }

  void put(dynamic value) {
    if (value == null) {
      return;
    }
    Type type = value.runtimeType;
    _map[type] = value;
  }

  ValueType remove<ValueType>() {
    ValueType value = get<ValueType>();
    _map.remove(ValueType);
    return value;
  }

  @override
  int get length => _map.length;

  @override
  Iterable<Type> get keys => _map.keys;

  @override
  Iterable<dynamic> get values => _map.values;

  @override
  bool containsKey(Type key) => _map.containsKey(key);

  @override
  bool containsValue(dynamic value) => _map.containsValue(value);
}

/// TODO: desc
class NameMap implements MapInfo<String, dynamic> {
  final Map<String, dynamic> _map = LinkedHashMap();

  ValueType get<ValueType>(String key) {
    dynamic value = _map[key];
    if (value == null || value is! ValueType) {
      return null;
    }
    return value as ValueType;
  }

  void put(String key, dynamic value) {
    if (key == null) {
      return;
    }
    _map[key] = value;
  }

  ValueType remove<ValueType>(String key) {
    ValueType value = get<ValueType>(key);
    _map.remove(key);
    return value;
  }

  @override
  int get length => _map.length;

  @override
  Iterable<String> get keys => _map.keys;

  @override
  Iterable<dynamic> get values => _map.values;

  @override
  bool containsKey(String key) => _map.containsKey(key);

  @override
  bool containsValue(dynamic value) => _map.containsValue(value);
}
