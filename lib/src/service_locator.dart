// ...existing code...
import 'dart:collection';

import 'package:flutter/foundation.dart';

typedef FactoryFunc<T> = T Function();

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
  void registerFactory<T>(FactoryFunc<T> factory) {
    _entries[T] = _Entry(factory: factory, isSingleton: false);
  }

  /// Register a singleton instance (same instance returned every time).
  void registerSingleton<T>(FactoryFunc<T> factory) {
    final instance = factory();
    if (instance == null) {
      if (kDebugMode) {
        debugPrint(
          'Warning: Singleton factory for type $T returned null. '
          'Make sure that this is intended.',
        );
      }
    } else {
      if (kDebugMode) {
        debugPrint('Registered singleton instance of type $T: $instance');
      }
    }
    _entries[T] = _Entry(instance: instance, isSingleton: true);
  }

  /// Unregister a type.
  void unregister<T>() {
    _entries.remove(T);
  }

  /// Get an instance of type T. Throws if not registered.
  T get<T>() {
    final entry = _entries[T];
    if (entry == null) {
      throw StateError(
        'No registration found for type $T in SimpleLocator.\n'
        'Register it before using: '
        'simpleLocator.registerFactory<$T>(() => My$T()); '
        'or simpleLocator.registerSingleton<$T>(() => My$T()).\n'
        'You can also override createViewModel() in your ViewState to provide a different injection strategy.',
      );
    }
    if (entry.isSingleton) {
      return entry.instance as T;
    }
    final instance = entry.factory!();
    if (instance == null) {
      if (kDebugMode) {
        debugPrint(
          'Warning: Factory for type $T returned null. '
          'Make sure that this is intended.',
        );
      }
    } else {
      if (kDebugMode) {
        debugPrint('Created new instance of type $T: $instance');
      }
    }
    return (instance as T);
  }

  /// Clear all registrations (useful in tests).
  void reset() => _entries.clear();
}
