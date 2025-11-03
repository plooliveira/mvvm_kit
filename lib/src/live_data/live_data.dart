import 'package:flutter/material.dart';

import 'package:mvvm_kit/src/live_data/filter.dart';
import 'package:mvvm_kit/src/live_data/mirror.dart';
import 'package:mvvm_kit/src/live_data/scope.dart';

bool _allChangeDetector<T>(T to, T from) => true;

abstract class LiveData<T> extends ChangeNotifier {
  final DataScope? parentScope;
  final DataScope? scope;

  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  final List<Function(T)> _subscribers = [];

  T get value;

  T? _lastNotifyCheck;

  LiveData([T? value, DataScope? scope])
    : parentScope = scope,
      scope = scope?.child(),
      _lastNotifyCheck = value {
    scope?.add(this);
  }

  T call() => value;

  late bool Function(T, T) changeDetector = _defaultChangeDetector;

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
    scope?.dispose();
    parentScope?.remove(this);
    super.dispose();
  }
}

class MutableLiveData<T> extends LiveData<T> {
  T _value;

  @override
  T get value => _value;

  MutableLiveData(T super.value, [bool emitAll = false]) : _value = value {
    if (emitAll) {
      changeDetector = _allChangeDetector;
    }
  }

  set value(T to) {
    if (changeDetector(to, _value)) {
      _value = to;
      notifyListeners();
    }
  }

  LiveData<T> get immutable => this;

  void editValue(Function(T value) block) {
    block(_value);
    notifyListeners();
  }
}

extension MutableDataScope on DataScope {
  MutableLiveData<T> mutable<T>(T start) {
    return add(MutableLiveData(start));
  }
}

extension ListLiveData<D, L extends Iterable<D>> on LiveData<L> {
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
      AutoDisposeFilter(this, (value) => value != null);
}

bool _defaultChangeDetector<T>(T to, T from) {
  if (to is List && from is List) {
    if (to.length != from.length) return true;

    for (var i = 0; i < to.length; i++) {
      if (to[i] != from[i]) {
        return true;
      }
    }
  }

  if (to is Map && from is Map) {
    if (to.length != from.length) return true;

    for (var key in to.keys) {
      if (!from.containsKey(key) || from[key] != to[key]) {
        return true;
      }
    }
  }

  if (to is Iterable && from is Iterable) {
    final toItr = to.toList();
    final fromItr = from.toList();
    if (toItr.length != fromItr.length) return true;
    for (var i = 0; i < toItr.length; i++) {
      if (toItr[i] != fromItr[i]) {
        return true;
      }
    }
  }

  return to != from;
}
