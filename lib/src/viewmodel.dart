import 'dart:async';
import 'package:flutter/material.dart';

import '../mvvm_kit.dart';

/// Base class for ViewModels in the MVVM pattern.
///
/// [ViewModel] manages the business logic for the UI layer.
/// It extends [ChangeNotifier] and provides lifecycle management, automatic
/// disposal of [LiveData] through [DataScope], and built-in action tracking.
///
/// Key features:
/// * Automatic lifecycle management with [onActive] and [onInactive]
/// * Built-in [isLoading] for tracking long-running operations
/// * Automatic disposal of all registered [LiveData] instances
/// * Methods [mutable] and [register] for creating observable data
///
/// Example:
/// ```dart
/// class CounterViewModel extends ViewModel {
///   final _counter = mutable(0);
///   LiveData<int> get counter => _counter;
///
///   void increment() {
///     _counter.value++;
///   }
///
///   @override
///   void onActive() {
///     // Called when the view becomes active
///   }
/// }
/// ```
///
/// See also:
/// * [ViewWidget] and [ViewState], for connecting ViewModels to widgets
/// * [LiveData] and [MutableLiveData], for observable data
/// * [DataScope], for managing LiveData lifecycle
abstract class ViewModel extends _LifecycleViewModel {
  ViewModel() {
    _isLoading = mutable(false);
  }

  /// Observable flag indicating if a long-running action is in progress.
  ///
  /// Use [beginLoading] and [completeLoading] to control this flag.
  /// Useful for showing loading indicators in the UI.
  ///
  /// Example:
  /// ```dart
  /// Future<void> loadData() async {
  ///   startAction();
  ///   try {
  ///     await repository.fetchData();
  ///   } finally {
  ///     finishAction();
  ///   }
  /// }
  /// ```
  LiveData<bool> get isLoading => _isLoading;
  late final MutableLiveData<bool> _isLoading;

  /// Marks the start of a long-running action.
  ///
  /// Sets [isLoading] to `true`. Always pair with [completeLoading]
  /// to avoid leaving the action state active indefinitely.
  void beginLoading() => _isLoading.value = true;

  /// Marks the end of a long-running action.
  ///
  /// Sets [isLoading] to `false`.
  void completeLoading() => _isLoading.value = false;

  Future<T> executeAsync<T>(Future<T> Function() action) async {
    beginLoading();
    try {
      return await action();
    } finally {
      completeLoading();
    }
  }
}

abstract class _LifecycleViewModel {
  /// Scope for managing the lifecycle of [LiveData] instances.
  ///
  /// All LiveData created with [mutable] or [register] are automatically
  /// added to this scope and disposed when the ViewModel is disposed.
  final DataScope scope = DataScope();

  bool _isActive = false;

  /// Whether this ViewModel is currently active.
  ///
  /// Set to `true` when the associated view becomes active (visible),
  /// and `false` when it becomes inactive. This is managed automatically
  /// by [ViewState].
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

  /// Creates a [MutableLiveData] and registers it in the ViewModel's scope.
  ///
  /// The created LiveData will be automatically disposed when the ViewModel
  /// is disposed. This is the recommended way to create observable state
  /// in your ViewModel.
  ///
  /// Example:
  /// ```dart
  /// class MyViewModel extends ViewModel {
  ///   final _name = mutable('John');
  ///   LiveData<String> get name => _name;
  /// }
  /// ```
  MutableLiveData<T> mutable<T>(T value) => scope.mutable(value);

  /// Registers an existing [LiveData] in the ViewModel's scope.
  ///
  /// The registered LiveData will be automatically disposed when the
  /// ViewModel is disposed. Use this when you create LiveData instances
  /// that aren't created with [mutable].
  ///
  /// Example:
  /// ```dart
  /// final custom = register(CustomLiveData());
  /// ```
  T register<T extends LiveData>(T value) => scope.add(value);

  /// Called when the associated view becomes active (visible).
  ///
  /// Override this method to perform actions when the view is shown,
  /// such as starting streams, subscribing to updates, etc.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void onActive() {
  ///   _subscription = repository.stream.listen(_onData);
  /// }
  /// ```
  void onActive() {}

  /// Called when the associated view becomes inactive (hidden).
  ///
  /// Override this method to perform cleanup when the view is hidden,
  /// such as pausing streams, canceling subscriptions, etc.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void onInactive() {
  ///   _subscription?.cancel();
  /// }
  /// ```
  void onInactive() {}

  void dispose() {
    scope.dispose();
  }

  /// Waits until the ViewModel becomes active.
  ///
  /// This is useful for operations that should only execute when the
  /// view is visible. The Future completes immediately if already active.
  ///
  /// Example:
  /// ```dart
  /// Future<void> loadData() async {
  ///   await ensureActive();
  ///   // Now we know the view is active
  ///   fetchDataFromServer();
  /// }
  /// ```
  Future ensureActive() async {
    while (!_isActive) {
      await _isActiveCompleter.future;
    }
  }
}
