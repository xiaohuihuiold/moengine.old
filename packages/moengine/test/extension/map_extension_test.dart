import 'package:flutter_test/flutter_test.dart';
import 'package:moengine/src/extension/map_extension.dart';

class A {}

class B {}

class C {}

class D {}

void main() {
  group('TypeMap test', () {
    test('test put/get/remove', () {
      TypeMap typeMap = TypeMap();
      A a = A();
      typeMap.put(a);
      expect(typeMap.get<A>(), a);

      A b = A();
      typeMap.put(b);
      expect(typeMap.get<A>(), b);

      A c = A();
      typeMap.put(c, A);
      expect(typeMap.get(A), c);

      typeMap.remove(A);
      expect(typeMap.get<A>(), null);
      typeMap.put(c);
      typeMap.remove<A>();
      expect(typeMap.get<A>(), null);
    });

    test('test has', () {
      TypeMap typeMap = TypeMap();
      typeMap.put(A());
      typeMap.put(B());
      typeMap.put(C());

      expect(typeMap.has([B, C]).length, 2);
      expect(typeMap.has([B, C, A]).length, 3);
      expect(typeMap.has([C, D]), null);

      typeMap.put(null, D);
      expect(typeMap.has([C, D]).length, 2);
      expect(typeMap.has([C, D], hasNull: false), null);
    });
  });
}
