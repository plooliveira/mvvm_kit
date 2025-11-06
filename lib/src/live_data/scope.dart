import 'dart:collection';
import 'package:flutter/foundation.dart';

import 'package:mvvm_kit/mvvm_kit.dart';

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

extension MutableDataScope on DataScope {
  MutableLiveData<T> mutable<T>(T start) {
    return add(MutableLiveData(start));
  }

  MutableLiveData<T> bridgeFrom<T>(LiveData<T> source) {
    final mirror = add(MutableLiveData<T>(source.value));

    void listener() {
      mirror.value = source.value;
    }

    source.addListener(listener);

    // Callback que remove listener e garante dispose do mirror quando o scope for limpo.
    final cleanup = _DisposeCallback(() {
      source.removeListener(listener);
      // remove mirror da lista do scope e dispose se ainda estiver lá
      if (remove(mirror)) {
        mirror.dispose();
      }
    });

    add(cleanup);
    return mirror;
  }
}

class _DisposeCallback extends ChangeNotifier {
  final VoidCallback _onDispose;
  _DisposeCallback(this._onDispose);

  @override
  void dispose() {
    try {
      _onDispose();
    } finally {
      super.dispose();
    }
  }
}
