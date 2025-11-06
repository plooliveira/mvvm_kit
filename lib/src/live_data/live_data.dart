import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:mvvm_kit/mvvm_kit.dart';

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

  @visibleForTesting
  List<Function(T)> get subscribers => _subscribers;

  T get value;

  T? _lastNotifyCheck;

  LiveData([T? value, DataScope? scope])
    :
      _lastNotifyCheck = value {
    scope?.add(this);
  }

  T call() => value;

  late ChangeDetector<T> changeDetector = _defaultChangeDetector;

  LiveData<T> mirror() => LiveDataMirror(this);

  LiveData<S> transform<S>(S Function(LiveData<T> data) transform) =>
      TransformedLiveDataMirror(this, transform: transform);

  HotswapLiveData<T> hotswappable() => HotswapLiveData(this);

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
    super.dispose();
  }
}

extension ListLiveData<D> on LiveData<Iterable<D>> {
  bool get isEmpty => value.isEmpty;

  bool get isNotEmpty => value.isNotEmpty;

  int get length => value.length;

  Iterable<T> map<T>(T Function(D value) toElement) => value.map(toElement);

  void forEach(void Function(D element) action) => value.forEach(action);

  Iterable<T> expand<T>(Iterable<T> Function(D element) toElements) =>
      value.expand(toElements);

  LiveData<Iterable<D>> filtered(bool Function(D value) check) =>
      AutoDisposeFilter(this, check);

  LiveData<Iterable<D>> notNull() =>
      AutoDisposeFilter<D>(this, (value) => value != null);
}
