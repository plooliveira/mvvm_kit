import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm_kit/mvvm_kit.dart';

// Helper classes for testing
class _TestClass {}

abstract class _AbstractService {}

class _ServiceImpl implements _AbstractService {}

void main() {
  group('SimpleLocator', () {
    late SL sut;

    setUp(() {
      sut = SL();
    });

    tearDown(() {
      sut.reset();
    });

    test(
      'registerSingleton should return the same instance every time get is called',
      () {
        // Arrange
        sut.registerSingleton(() => _TestClass());

        // Act
        final instance1 = sut.get<_TestClass>();
        final instance2 = sut.get<_TestClass>();

        // Assert
        expect(instance1, isA<_TestClass>());
        expect(instance2, isA<_TestClass>());
        expect(instance1, same(instance2));
        sut.reset();
      },
    );

    test(
      'registerFactory should return a new instance every time get is called',
      () {
        // Arrange
        sut.registerFactory(() => _TestClass());

        // Act
        final instance1 = sut.get<_TestClass>();
        final instance2 = sut.get<_TestClass>();

        // Assert
        expect(instance1, isA<_TestClass>());
        expect(instance2, isA<_TestClass>());
        expect(instance1, isNot(same(instance2)));
        sut.reset();
      },
    );

    test('get should throw StateError for an unregistered type', () {
      // Assert
      expect(() => sut.get<_TestClass>(), throwsA(isA<StateError>()));
    });

    test('unregister should remove a registration', () {
      // Arrange
      sut.registerFactory(() => _TestClass());
      expect(sut.get<_TestClass>(), isA<_TestClass>()); // Verify it's there

      // Act
      sut.unregister<_TestClass>();

      // Assert
      expect(() => sut.get<_TestClass>(), throwsA(isA<StateError>()));
      sut.reset();
    });

    test('reset should clear all registrations', () {
      // Arrange
      sut.registerFactory(() => _TestClass());
      sut.registerSingleton<_AbstractService>(() => _ServiceImpl());

      // Act
      sut.reset();

      // Assert
      expect(() => sut.get<_TestClass>(), throwsA(isA<StateError>()));
      expect(() => sut.get<_AbstractService>(), throwsA(isA<StateError>()));
    });

    test('should overwrite a singleton with a factory', () {
      // Arrange
      sut.registerSingleton(() => _TestClass());
      sut.registerFactory(() => _TestClass()); // Overwrite

      // Act
      final instance1 = sut.get<_TestClass>();
      final instance2 = sut.get<_TestClass>();

      // Assert
      expect(instance1, isNot(same(instance2)));
      sut.reset();
    });

    test('should overwrite a factory with a singleton', () {
      // Arrange
      sut.registerFactory(() => _TestClass());
      sut.registerSingleton(() => _TestClass()); // Overwrite

      // Act
      final instance1 = sut.get<_TestClass>();
      final instance2 = sut.get<_TestClass>();

      // Assert
      expect(instance1, same(instance2));
      sut.reset();
    });

    test('should register a concrete implementation for an abstract type', () {
      // Arrange
      sut.registerSingleton<_AbstractService>(() => _ServiceImpl());

      // Act
      final instance = sut.get<_AbstractService>();

      // Assert
      expect(instance, isA<_ServiceImpl>());
      sut.reset();
    });
  });
}
