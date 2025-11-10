import 'dart:async';
import 'package:flutter/material.dart';

import 'package:mvvm_kit/mvvm_kit.dart';

abstract class ViewModel extends _LifecycleViewModel {
  ViewModel() {
    _actionInProgress = mutable(false);
  }

  LiveData<bool> get actionInProgress => _actionInProgress;
  late final MutableLiveData<bool> _actionInProgress;

  void startAction() => _actionInProgress.value = true;

  void finishAction() => _actionInProgress.value = false;
}

abstract class _LifecycleViewModel extends ChangeNotifier {
  final DataScope dataScope = DataScope();

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

  MutableLiveData<T> mutable<T>(T value) => dataScope.mutable(value);

  T register<T extends LiveData>(T value) => dataScope.add(value);

  void onActive() {}

  void onInactive() {}

  @override
  void dispose() {
    dataScope.dispose();
    super.dispose();
  }

  Future ensureActive() async {
    while (!_isActive) {
      await _isActiveCompleter.future;
    }
  }
}
