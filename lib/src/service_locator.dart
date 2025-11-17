// ...existing code...
import 'dart:collection';

typedef FactoryFunc<T> = T Function();

class _Entry {
  final FactoryFunc? factory;
  final Object? instance;
  final bool isSingleton;

  _Entry({this.factory, this.instance, required this.isSingleton});
}

class SimpleLocator {
  final Map<Type, _Entry> _entries = HashMap();

  /// Register a factory that will produce a new instance each time.
  void registerFactory<T>(FactoryFunc<T> factory) {
    _entries[T] = _Entry(factory: factory, isSingleton: false);
  }

  /// Register a singleton instance (same instance returned every time).
  void registerSingleton<T>(FactoryFunc<T> factory) {
    _entries[T] = _Entry(instance: factory(), isSingleton: true);
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
    return (entry.factory!() as T);
  }

  /// Clear all registrations (useful in tests).
  void reset() => _entries.clear();
}

/// Global instance to use throughout the app/tests.
final SimpleLocator simpleLocator = SimpleLocator();
