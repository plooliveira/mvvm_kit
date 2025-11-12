import 'dart:collection';
import 'package:flutter/foundation.dart';

import 'package:mvvm_kit/mvvm_kit.dart';

part '_mediator.dart';
part '_merged.dart';
part '_extensions.dart';
part '_dispose.dart';

/// Manages the lifecycle of [ChangeNotifier] instances, particularly [LiveData].
///
/// [DataScope] provides automatic disposal of registered notifiers when the
/// scope is disposed. It supports hierarchical scopes through parent-child
/// relationships, ensuring proper cleanup of resources.
///
/// Commonly used within [ViewModel] to manage all LiveData instances, but
/// can also be used standalone for managing any [ChangeNotifier] lifecycle.
///
/// Example:
/// ```dart
/// final scope = DataScope();
/// final data1 = scope.add(MutableLiveData(0));
/// final data2 = scope.mutable('hello');
/// 
/// // Later, dispose all at once
/// scope.dispose(); // data1 and data2 are automatically disposed
/// ```
///
/// See also:
/// * [ViewModel], which uses DataScope internally
/// * [LiveData], the primary type managed by DataScope
class DataScope {
  final LinkedHashSet<ChangeNotifier> _items = LinkedHashSet();
  final LinkedHashSet<DataScope> _children = LinkedHashSet();
  
  /// The parent scope, if this is a child scope.
  final DataScope? parent;

  @visibleForTesting
  LinkedHashSet<ChangeNotifier> get items => _items;

  @visibleForTesting
  LinkedHashSet<DataScope> get children => _children;

  /// Creates a new DataScope, optionally with a parent scope.
  ///
  /// When a parent is provided, this scope is automatically registered as
  /// a child and will be disposed when the parent is disposed.
  DataScope({this.parent}) {
    parent?._children.add(this);
  }

  /// Adds a [ChangeNotifier] to this scope and returns it.
  ///
  /// The notifier will be automatically disposed when this scope is disposed.
  ///
  /// Example:
  /// ```dart
  /// final liveData = scope.add(MutableLiveData(42));
  /// ```
  T add<T extends ChangeNotifier>(T data) {
    _items.add(data);
    return data;
  }

  /// Removes a [ChangeNotifier] from this scope without disposing it.
  ///
  /// Returns `true` if the item was found and removed.
  bool remove(ChangeNotifier data) => _items.remove(data);

  /// Removes and disposes a [ChangeNotifier] from this scope.
  ///
  /// The notifier is only disposed if it was found in this scope.
  void clean(ChangeNotifier data) {
    if (remove(data)) {
      data.dispose();
    }
  }

  /// Cleans up all child scopes and items in this scope.
  ///
  /// Disposes children first (in reverse order), then items (in reverse order),
  /// and finally removes this scope from its parent.
  void cleanScope() {
    for (var child in _children.toList().reversed) {
      child.dispose();
    }

    for (var item in _items.toList().reversed) {
      clean(item);
    }

    parent?._children.remove(this);
  }

  /// Disposes this scope and all registered items and child scopes.
  ///
  /// After calling dispose, this scope should not be used anymore.
  void dispose() {
    cleanScope();
  }

  /// Creates a child scope with this scope as its parent.
  ///
  /// The child scope will be automatically disposed when this parent
  /// scope is disposed.
  ///
  /// Example:
  /// ```dart
  /// final parentScope = DataScope();
  /// final childScope = parentScope.child();
  /// parentScope.dispose(); // childScope is also disposed
  /// ```
  DataScope child() => DataScope(parent: this);
}
