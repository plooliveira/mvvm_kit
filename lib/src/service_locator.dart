// ...existing code...
import 'dart:collection';

import 'package:mvvm_kit/src/helpers/debugger.dart';

/// Function type for factory methods with an injector parameter.
typedef FactoryFunc<T> = T Function(Injector i);
typedef Injector = D Function<D>();

class _Entry {
  final FactoryFunc? factory;
  final Object? instance;
  final bool isSingleton;

  _Entry({this.factory, this.instance, required this.isSingleton});
}

/// A minimalist service locator for straightforward dependency injection.
/// No async support, no scopes, no modules, no tags. Just simple registration and retrieval of instances.
///
/// Usage:
/// ```dart
/// // Registering a factory (new instance each time)
/// SL.I.registerFactory<MyService>(() => MyServiceImpl());
///
/// // Registering a singleton (same instance every time)
/// SL.I.registerSingleton<MyRepository>(() => MyRepositoryImpl());
///
/// // Retrieving instances
/// final service = SL.I.get<MyService>();
/// final repository = SL.I.get<MyRepository>();
/// ```
/// Throws a [StateError] if the requested type is not registered.
class SL {
  /// Singleton instance.
  static final SL instance = SL._internal();

  /// Shortcut to the singleton instance.
  static SL get I => instance;

  SL._internal();
  factory SL() => instance;

  final Map<Type, _Entry> _entries = HashMap();

  /// Register a factory that will produce a new instance each time.
  /// The factory has access to the injector for resolving dependencies.
  void registerFactory<T>(FactoryFunc<T> factory) {
    _entries[T] = _Entry(factory: factory, isSingleton: false);
  }

  /// Register a singleton instance (same instance returned every time).
  /// Please note that the instance is created at registration time with no access to the injector.
  /// This means that dependencies must be provided manually and cannot be injected automatically.
  /// To register a singleton that requires dependencies, consider using [registerLazySingleton] instead.
  void registerSingleton<T>(T instance, {bool overwrite = false}) {
    if (!overwrite && _entries.containsKey(T)) {
      throw StateError(
        'A registration for type $T already exists in SimpleLocator. '
        'To overwrite it, set overwrite: true in registerSingleton.',
      );
    }
    debugLog(
      'Warning: Singleton factory for type $T returned null. '
      'Make sure that this is intended.',
      condition: instance == null,
    );
    debugLog(
      'Warning: Overwriting existing registration for type $T in locator.',
      condition: _entries[T] != null,
    );
    debugLog('Registered singleton instance of type $T: $instance');

    _entries[T] = _Entry(instance: instance, isSingleton: true);
  }

  /// Register a lazy singleton (instance created on first use).
  /// The factory has access to the injector for resolving dependencies.
  void registerLazySingleton<T>(
    FactoryFunc<T> factory, {
    bool overwrite = false,
  }) {
    if (!overwrite && _entries.containsKey(T)) {
      throw StateError(
        'A registration for type $T already exists in SL locator. '
        'To overwrite it, set overwrite: true in registerSingleton.',
      );
    }

    debugLog(
      'Warning: Overwriting existing registration for type $T in locator.',
      condition: _entries[T] != null,
    );

    debugLog('Registered lazy singleton factory for type $T');

    _entries[T] = _Entry(factory: factory, isSingleton: true);
  }

  /// Unregister a type.
  void unregister<T>() {
    _entries.remove(T);
  }

  /// Get an instance of type T. Throws if not registered.
  T get<T>() {
    var entry = _entries[T];
    if (entry == null) {
      throw StateError(
        'No registration found for type $T in SimpleLocator.\n'
        'Register it before using: '
        'SL.I.registerFactory<$T>(() => My$T()); '
        'or SL.I.registerSingleton<$T>( My$T());\n'
        'or SL.I.registerLazySingleton<$T>(() => My$T());\n',
      );
    }
    if (entry.isSingleton) {
      if (entry.instance == null) {
        _entries[T] = _Entry(instance: entry.factory!(get), isSingleton: true);
      }
      entry = _entries[T];
      return entry!.instance as T;
    }
    final instance = entry.factory!(get);

    debugLog(
      'Warning: Factory for type $T returned null. '
      'Make sure that this is intended.',
      condition: instance == null,
    );
    debugLog('Created new instance of type $T: $instance');

    return (instance as T);
  }

  /// Clear all registrations (useful in tests).
  void reset() => _entries.clear();
}
