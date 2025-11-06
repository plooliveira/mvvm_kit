import 'dart:async';
import 'package:flutter/material.dart';

import 'package:mvvm_kit/mvvm_kit.dart';

abstract class ViewModel extends LifecycleViewModel {
  LiveData<bool> get actionInProgress => _actionInProgress;
  late final MutableLiveData<bool> _actionInProgress = observable(false);

  void startAction() => _actionInProgress.value = true;

  void finishAction() => _actionInProgress.value = false;
}

abstract class LifecycleViewModel extends ChangeNotifier {
  final DataScope dataScope = DataScope();

  final List<ChangeNotifier> _observed = [];

  bool _isActive = false;

  bool get isActive => _isActive;

  set isActive(bool active) {
    if (active != _isActive) {
      if (active) {
        _isActiveCompleter.complete();
        onActive();
      } else {
        _isActiveCompleter = Completer();
        onInactive();
      }
    }
    _isActive = active;
  }

  Completer _isActiveCompleter = Completer();

  MutableLiveData<T> observable<T>(T value) {
    final MutableLiveData<T> observable = MutableLiveData(value);
    _observed.add(observable);
    return observable;
  }

  T observed<T extends ChangeNotifier>(T value) {
    _observed.add(value);
    return value;
  }

  void onActive() {}

  void onInactive() {}

  @override
  void dispose() {
    for (var observed in _observed.reversed) {
      observed.dispose();
    }
    _observed.clear();

    dataScope.dispose();

    super.dispose();
  }

  Future ensureActive() async {
    while (!_isActive) {
      await _isActiveCompleter.future;
    }
  }
}
