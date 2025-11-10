import 'dart:collection';
import 'package:flutter/foundation.dart';

import 'package:mvvm_kit/mvvm_kit.dart';

part '_mediator.dart';
part '_merged.dart';
part '_extensions.dart';
part '_dispose.dart';

class DataScope {
  final LinkedHashSet<ChangeNotifier> _items = LinkedHashSet();
  final LinkedHashSet<DataScope> _children = LinkedHashSet();
  final DataScope? parent;

  @visibleForTesting
  LinkedHashSet<ChangeNotifier> get items => _items;

  @visibleForTesting
  LinkedHashSet<DataScope> get children => _children;

  DataScope({this.parent}) {
    parent?._children.add(this);
  }

  T add<T extends ChangeNotifier>(T data) {
    _items.add(data);
    return data;
  }

  bool remove(ChangeNotifier data) => _items.remove(data);

  void clean(ChangeNotifier data) {
    if (remove(data)) {
      data.dispose();
    }
  }

  void cleanScope() {
    for (var child in _children.toList().reversed) {
      child.dispose();
    }

    for (var item in _items.toList().reversed) {
      clean(item);
    }

    parent?._children.remove(this);
  }

  void dispose() {
    cleanScope();
  }

  DataScope child() => DataScope(parent: this);
}
