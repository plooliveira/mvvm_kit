import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:mvvm_kit/mvvm_kit.dart';

part '_mirror.dart';
part '_filter.dart';
part '_extensions.dart';

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

abstract class LiveData<T> extends ChangeNotifier {
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  final List<Function(T)> _subscribers = [];

  final DataScope? scope;
  final DataScope? parentScope;

  @visibleForTesting
  List<Function(T)> get subscribers => _subscribers;

  T get value;

  T? _lastNotifyCheck;

  LiveData([T? value, this.parentScope])
    : scope = parentScope?.child() ?? DataScope() {
    _lastNotifyCheck = value;
    parentScope?.add(this);
  }

  /// Creates a LiveData from a ValueNotifier
  factory LiveData.fromValueNotifier(
    ValueNotifier<T> notifier, [
    DataScope? scope,
  ]) {
    return _ValueNotifierData(notifier, scope);
  }

  /// Creates a nullable LiveData from a Stream
  ///
  /// Returns a LiveData<T?> that updates when the stream emits values.
  /// The [initialValue] is used as the initial value of the LiveData.
  /// Note: Returns LiveData<T?> because the stream value can be null.
  static LiveData<T?> fromStream<T>(
    Stream<T> stream,
    T initialValue, [
    DataScope? scope,
  ]) {
    return _StreamData<T, T, Stream<T>>(stream, scope, value: initialValue);
  }

  T call() => value;

  late ChangeDetector<T> changeDetector = _defaultChangeDetector;

  LiveData<T> subscribe(Function(T value) callback) {
    if (!_subscribers.contains(callback)) {
      _subscribers.add(callback);
      callback(value);
    }
    return this;
  }

  void reload() {
    notifyListeners();
  }

  void unsubscribe(Function(T value) callback) {
    _subscribers.remove(callback);
  }

  void notifyIfChanged() {
    final T currentValue = value;
    if (_lastNotifyCheck == null ||
        changeDetector(currentValue, _lastNotifyCheck as T)) {
      _lastNotifyCheck = currentValue;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    super.notifyListeners();

    final value = this.value;
    for (var callback in _subscribers.toList()) {
      callback(value);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _subscribers.clear();
    scope?.dispose();
    parentScope?.remove(this);
    super.dispose();
  }
}

class MutableLiveData<T> extends LiveData<T> {
  T _value;

  @override
  T get value => _value;

  MutableLiveData(T super.value, [bool emitAll = false, super.scope])
    : _value = value {
    if (emitAll) {
      changeDetector = (T to, T from) => true;
    }
  }

  set value(T to) {
    if (changeDetector(to, _value)) {
      _value = to;
      notifyListeners();
    }
  }

  LiveData<T> get immutable => this;

  void update(Function(T value) block) {
    block(_value);
    notifyListeners();
  }
}
