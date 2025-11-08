import 'package:flutter/foundation.dart';

import 'package:mvvm_kit/mvvm_kit.dart';

class MergedLiveData<T> extends LiveData<T> {
  final List<ChangeNotifier> _sources;
  final T Function() _transform;
  T _value;

  @override
  T get value => _value;

  MergedLiveData({
    required List<ChangeNotifier> sources,
    required T Function() transform,
    DataScope? scope,
  }) : _sources = sources.toList(),
       _transform = transform,
       _value = transform(),
       super(null, scope) {
    for (var source in _sources) {
      source.addListener(_onSourceChanged);
    }
  }

  void _onSourceChanged() {
    final to = _transform();
    if (changeDetector(to, _value)) {
      _value = to;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (var source in _sources) {
      source.removeListener(_onSourceChanged);
    }
    super.dispose();
  }
}

extension MergingDataScope on DataScope {
  LiveData<T> merge<T>(List<ChangeNotifier> sources, T Function() transform) {
    return MergedLiveData<T>(
      sources: sources,
      transform: transform,
      scope: this,
    );
  }
}
