import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm_kit/mvvm_kit.dart';

// Helper classes for testing
class _TestClass {}

abstract class _AbstractService {}

class _ServiceImpl implements _AbstractService {}

class _LazyTestClass {
  static int creationCount = 0;
  _LazyTestClass() {
    creationCount++;
  }
}

// Mocks for Injector tests
class _Dependency {}

class _ServiceWithDependency {
  final _Dependency dependency;
  _ServiceWithDependency(this.dependency);
}

class _ServiceA {}

class _ServiceB {
  final _ServiceA dependency;
  _ServiceB(this.dependency);
}

class _ServiceC {
  final _ServiceB dependency;
  _ServiceC(this.dependency);
}

abstract class _AbstractRepository {}

class _RepositoryImpl implements _AbstractRepository {}

class _ViewModel {
  final _AbstractRepository repository;
  _ViewModel(this.repository);
}

void main() {
  group('Service Locator', () {
    late SL sut;

    setUp(() {
      sut = SL();
    });

    tearDown(() {
      sut.reset();
      _LazyTestClass.creationCount = 0;
    });

    test(
      'registerSingleton should return the same instance every time get is called',
      () {
        // Arrange
        sut.registerSingleton(_TestClass());

        // Act
        final instance1 = sut.get<_TestClass>();
        final instance2 = sut.get<_TestClass>();

        // Assert
        expect(instance1, isA<_TestClass>());
        expect(instance2, isA<_TestClass>());
        expect(instance1, same(instance2));
      },
    );

    test(
      'registerFactory should return a new instance every time get is called',
      () {
        // Arrange
        sut.registerFactory((_) => _TestClass());

        // Act
        final instance1 = sut.get<_TestClass>();
        final instance2 = sut.get<_TestClass>();

        // Assert
        expect(instance1, isA<_TestClass>());
        expect(instance2, isA<_TestClass>());
        expect(instance1, isNot(same(instance2)));
      },
    );

    test(
      'should create instance only on first get and return same instance subsequently',
      () {
        // Arrange
        sut.registerLazySingleton((_) => _LazyTestClass());

        // Assert
        expect(_LazyTestClass.creationCount, 0);

        // Act
        final instance1 = sut.get<_LazyTestClass>();

        expect(_LazyTestClass.creationCount, 1);
        expect(instance1, isA<_LazyTestClass>());

        final instance2 = sut.get<_LazyTestClass>();

        expect(_LazyTestClass.creationCount, 1);
        expect(instance2, same(instance1));
      },
    );

    test('should resolve dependencies when created', () {
      final dependency = _Dependency();
      sut.registerSingleton(dependency);
      sut.registerLazySingleton((i) => _ServiceWithDependency(i()));

      final instance = sut.get<_ServiceWithDependency>();

      expect(instance, isA<_ServiceWithDependency>());
      expect(instance.dependency, same(dependency));
    });

    test('get should throw StateError for an unregistered type', () {
      expect(() => sut.get<_TestClass>(), throwsA(isA<StateError>()));
    });

    test('unregister on non-registered type should not throw', () {
      expect(() => sut.unregister<_Dependency>(), returnsNormally);
    });

    test('registerSingleton without overwrite when exists should throw', () {
      sut.registerSingleton(_TestClass());
      expect(
        () => sut.registerSingleton(_TestClass()),
        throwsA(isA<StateError>()),
      );
    });

    test(
      'registerLazySingleton without overwrite when exists should throw',
      () {
        sut.registerLazySingleton((_) => _TestClass());
        expect(
          () => sut.registerLazySingleton((_) => _TestClass()),
          throwsA(isA<StateError>()),
        );
      },
    );
    // ...existing code...

    test('unregister should remove a registration', () {
      // Arrange
      sut.registerFactory((_) => _TestClass());
      expect(sut.get<_TestClass>(), isA<_TestClass>()); // Verify it's there

      // Act
      sut.unregister<_TestClass>();

      // Assert
      expect(() => sut.get<_TestClass>(), throwsA(isA<StateError>()));
    });

    test('reset should clear all registrations', () {
      // Arrange
      sut.registerFactory((_) => _TestClass());
      sut.registerSingleton<_AbstractService>(_ServiceImpl());

      // Act
      sut.reset();

      // Assert
      expect(() => sut.get<_TestClass>(), throwsA(isA<StateError>()));
      expect(() => sut.get<_AbstractService>(), throwsA(isA<StateError>()));
    });

    test('should overwrite a singleton with a factory', () {
      // Arrange
      sut.registerSingleton(_TestClass());
      final instance1 = sut.get<_TestClass>();
      sut.registerFactory((_) => _TestClass()); // Overwrite

      final instance2 = sut.get<_TestClass>();

      // Assert
      expect(instance1, isNot(same(instance2)));
    });

    test('should overwrite a factory with a singleton', () {
      // Arrange
      sut.registerFactory((_) => _TestClass());
      final instance1 = sut.get<_TestClass>();
      sut.registerSingleton(_TestClass(), overwrite: true); // Overwrite
      final instance2 = sut.get<_TestClass>();

      // Assert
      expect(instance1, isNot(same(instance2)));
    });

    test('should overwrite a factory with a lazy singleton', () {
      // Arrange
      sut.registerFactory((_) => _TestClass());
      final instance1 = sut.get<_TestClass>();
      sut.registerLazySingleton((_) => _TestClass(), overwrite: true);
      final instance2 = sut.get<_TestClass>();

      // Assert
      expect(instance1, isNot(same(instance2)));
    });

    test('should register a concrete implementation for an abstract type', () {
      // Arrange
      sut.registerSingleton<_AbstractService>(_ServiceImpl());

      // Act
      final instance = sut.get<_AbstractService>();

      // Assert
      expect(instance, isA<_ServiceImpl>());
    });

    group('Injector', () {
      test('should resolve transitive dependencies for a factory', () {
        sut.registerFactory((i) => _ServiceA());
        sut.registerFactory((i) => _ServiceB(i()));
        sut.registerFactory((i) => _ServiceC(i()));

        final serviceC = sut.get<_ServiceC>();

        expect(serviceC, isA<_ServiceC>());
        expect(serviceC.dependency, isA<_ServiceB>());
        expect(serviceC.dependency.dependency, isA<_ServiceA>());
      });

      test('should resolve transitive dependencies for a lazy singleton', () {
        sut.registerLazySingleton((i) => _ServiceA());
        sut.registerLazySingleton((i) => _ServiceB(i()));
        sut.registerLazySingleton((i) => _ServiceC(i()));
        final serviceC = sut.get<_ServiceC>();

        expect(serviceC, isA<_ServiceC>());
        expect(serviceC.dependency, isA<_ServiceB>());
        expect(serviceC.dependency.dependency, isA<_ServiceA>());
      });

      test(
        'should resolve a concrete implementation for an abstraction (interface)',
        () {
          sut.registerFactory((i) => _ViewModel(i()));
          sut.registerFactory<_AbstractRepository>((i) => _RepositoryImpl());
          final viewModel = sut.get<_ViewModel>();
          expect(viewModel, isA<_ViewModel>());
          expect(viewModel.repository, isA<_RepositoryImpl>());
        },
      );
    });
  });
}
