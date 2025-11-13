import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../mvvm_kit.dart';

part '_mirror.dart';
part '_filter.dart';
part '_extensions.dart';

/// A function that determines if a value has changed.
///
/// Returns `true` if [a] and [b] are different values.
typedef ChangeDetector<T> = bool Function(T a, T b);
const _deepEquality = DeepCollectionEquality();

bool _defaultChangeDetector<T>(T to, T from) {
  if (identical(to, from)) return false;
  try {
    return !_deepEquality.equals(to, from);
  } catch (_) {
    return to != from;
  }
}

/// An observable data holder for the MVVM pattern.
///
/// [LiveData] is the core class of the mvvm_kit package. It holds a value
/// and notifies observers when that value changes. Use it with [Watch] or
/// [GroupWatch] widgets to automatically rebuild UI when data changes.
///
/// This is an abstract class. Use [MutableLiveData] for data you can modify,
/// or create instances using factory methods like [LiveData.fromValueNotifier]
/// and [LiveData.fromStream].
///
/// Example:
/// ```dart
/// class CounterViewModel extends ViewModel {
///   final _counter = MutableLiveData(0);
///   LiveData<int> get counter => _counter;
///
///   void increment() => _counter.value++;
/// }
///
/// // In your widget:
/// Watch(
///   viewModel.counter,
///   builder: (context, value) => Text('$value'),
/// )
/// ```
///
/// See also:
/// * [MutableLiveData], for creating mutable observable data
/// * [Watch], for observing a single LiveData in widgets
/// * [GroupWatch], for observing multiple LiveData objects
abstract class LiveData<T> extends ChangeNotifier {
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  final List<Function(T)> _subscribers = [];

  final DataScope? scope;
  final DataScope? parentScope;

  @visibleForTesting
  List<Function(T)> get subscribers => _subscribers;

  /// The current value held by this LiveData.
  ///
  /// Accessing this getter returns the current value without triggering
  /// any notifications. To observe changes, use [Watch] widget or [subscribe].
  T get value;

  T? _lastNotifyCheck;

  LiveData([T? value, this.parentScope])
    : scope = parentScope?.child() ?? DataScope() {
    _lastNotifyCheck = value;
    parentScope?.add(this);
  }

  /// Converts a [ValueNotifier] into a [LiveData].
  ///
  /// Creates a new LiveData that observes the given [notifier] and
  /// automatically synchronizes when the notifier's value changes.
  /// The original [ValueNotifier] remains independent and functional.
  ///
  /// Example:
  /// ```dart
  /// final notifier = ValueNotifier<int>(0);
  /// final liveData = LiveData.fromValueNotifier(notifier);
  /// notifier.value = 1; // liveData updates automatically
  /// ```
  factory LiveData.fromValueNotifier(
    ValueNotifier<T> notifier, [
    DataScope? scope,
  ]) {
    return _ValueNotifierData(notifier, scope);
  }

  /// Creates a nullable LiveData from a [Stream].
  ///
  /// Returns a `LiveData<T?>` that updates automatically when the stream
  /// emits new values. The [initialValue] is used until the first stream
  /// emission.
  ///
  /// Note: Returns `LiveData<T?>` because stream values can be null.
  ///
  /// Example:
  /// ```dart
  /// final stream = Stream.periodic(Duration(seconds: 1), (i) => i);
  /// final liveData = LiveData.fromStream(stream, 0);
  /// ```
  static LiveData<T?> fromStream<T>(
    Stream<T> stream,
    T initialValue, [
    DataScope? scope,
  ]) {
    return _StreamData<T, T, Stream<T>>(stream, scope, value: initialValue);
  }

  /// Shorthand for accessing [value].
  ///
  /// Allows calling the LiveData instance as a function to get its value.
  ///
  /// Example:
  /// ```dart
  /// final data = MutableLiveData(42);
  /// print(data()); // prints: 42
  /// ```
  T call() => value;

  /// Function that determines if the value has changed.
  ///
  /// Override this to customize change detection behavior. By default,
  /// uses deep equality for collections and standard equality for other types.
  late ChangeDetector<T> changeDetector = _defaultChangeDetector;

  /// Subscribes to value changes with a callback function.
  ///
  /// The [callback] is immediately invoked with the current value, then
  /// called again whenever the value changes. Returns this LiveData instance
  /// for method chaining.
  ///
  /// Use [unsubscribe] to remove the callback later.
  ///
  /// Example:
  /// ```dart
  /// liveData.subscribe((value) {
  ///   print('Value changed to: $value');
  /// });
  /// ```
  LiveData<T> subscribe(Function(T value) callback) {
    if (!_subscribers.contains(callback)) {
      _subscribers.add(callback);
      callback(value);
    }
    return this;
  }

  /// Forces notification of all observers even if the value hasn't changed.
  ///
  /// Useful when you need to trigger a UI rebuild or callback execution
  /// without actually changing the underlying value.
  void reload() {
    notifyListeners();
  }

  /// Removes a previously registered callback.
  ///
  /// Use this to stop receiving notifications from a [subscribe] callback.
  ///
  /// Example:
  /// ```dart
  /// void onValueChanged(int value) => print(value);
  ///
  /// liveData.subscribe(onValueChanged);
  /// // later...
  /// liveData.unsubscribe(onValueChanged);
  /// ```
  void unsubscribe(Function(T value) callback) {
    _subscribers.remove(callback);
  }

  /// Notifies all observers only if the value has changed.
  ///
  /// Compares the current value with the last notified value using
  /// [changeDetector]. Only triggers notifications if they differ.
  /// This is used internally but can be useful when extending LiveData.
  ///
  /// Use [reload] if you want to force notification regardless of changes.
  void notifyIfChanged() {
    final T currentValue = value;
    if (_lastNotifyCheck == null ||
        changeDetector(currentValue, _lastNotifyCheck as T)) {
      _lastNotifyCheck = currentValue;
      notifyListeners();
    }
  }

  /// Notifies all observers and executes all subscribed callbacks.
  ///
  /// This override ensures that both Flutter's [ChangeNotifier] listeners
  /// and [subscribe] callbacks are invoked with the current value.
  ///
  /// Typically you don't need to call this directly - use [reload] or
  /// modify values through [MutableLiveData.value] instead.
  @override
  void notifyListeners() {
    super.notifyListeners();

    final value = this.value;
    for (var callback in _subscribers.toList()) {
      callback(value);
    }
  }

  /// Disposes this LiveData and cleans up all resources.
  ///
  /// Clears all subscribers, disposes the internal [scope], and removes
  /// this LiveData from its [parentScope]. After calling dispose, this
  /// LiveData should not be used anymore.
  ///
  /// The [ViewModel] automatically disposes all LiveData instances
  /// registered in its scope, so manual disposal is usually not needed.
  @override
  void dispose() {
    _isDisposed = true;
    _subscribers.clear();
    scope?.dispose();
    parentScope?.remove(this);
    super.dispose();
  }
}

/// A mutable version of [LiveData] that allows changing its value.
///
/// [MutableLiveData] extends [LiveData] with the ability to modify the
/// stored value. When the value is set, all observers are automatically
/// notified (if the value actually changed according to [changeDetector]).
///
/// This is the most commonly used LiveData type in ViewModels for
/// managing state that changes over time.
///
/// Example:
/// ```dart
/// class CounterViewModel extends ViewModel {
///   final _counter = MutableLiveData(0);
///   LiveData<int> get counter => _counter;
///
///   void increment() {
///     _counter.value++; // Automatically notifies observers
///   }
/// }
/// ```
///
/// See also:
/// * [LiveData], the immutable base class
/// * [ViewModel.mutable], for creating MutableLiveData in a ViewModel scope
class MutableLiveData<T> extends LiveData<T> {
  T _value;

  @override
  T get value => _value;

  /// Creates a [MutableLiveData] with an initial value.
  ///
  /// The [emitAll] parameter, when set to `true`, forces notifications
  /// for every assignment, even if the value hasn't changed. By default,
  /// notifications only occur when the value actually changes.
  ///
  /// Example:
  /// ```dart
  /// final counter = MutableLiveData(0);
  /// final alwaysNotify = MutableLiveData(0, true);
  /// ```
  MutableLiveData(T super.value, [bool emitAll = false, super.scope])
    : _value = value {
    if (emitAll) {
      changeDetector = (T to, T from) => true;
    }
  }

  /// Sets a new value and notifies observers if it has changed.
  ///
  /// Uses [changeDetector] to determine if the value has actually changed.
  /// Only notifies observers when the new value differs from the current one
  /// (unless [emitAll] was set to `true` in the constructor).
  ///
  /// Example:
  /// ```dart
  /// final name = MutableLiveData('John');
  /// name.value = 'Jane'; // Notifies observers
  /// name.value = 'Jane'; // Does NOT notify (same value)
  /// ```
  set value(T to) {
    if (changeDetector(to, _value)) {
      _value = to;
      notifyListeners();
    }
  }

  /// Returns this MutableLiveData as a [LiveData] reference.
  ///
  /// This doesn't create a true immutable copy, but returns the same
  /// instance typed as [LiveData]. Useful for exposing the LiveData
  /// through a public getter while keeping the mutable field private.
  ///
  /// Note: Callers can still cast back to MutableLiveData if needed.
  ///
  /// Example:
  /// ```dart
  /// class MyViewModel extends ViewModel {
  ///   final _data = MutableLiveData(0);
  ///   LiveData<int> get data => _data.immutable;
  ///   // or simply: LiveData<int> get data => _data;
  /// }
  /// ```
  LiveData<T> get immutable => this;

  /// Updates the value by applying a transformation function.
  ///
  /// This is useful when you need to modify a complex object in place
  /// without replacing it entirely. The [block] function receives the
  /// current value and can modify it. After the block executes, all
  /// observers are notified.
  ///
  /// Example:
  /// ```dart
  /// final list = MutableLiveData<List<int>>([1, 2, 3]);
  /// list.update((value) => value.add(4)); // Adds 4 and notifies
  /// ```
  void update(Function(T value) block) {
    block(_value);
    notifyListeners();
  }
}
