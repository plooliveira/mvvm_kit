part of 'scope.dart';

class _MergedLiveData<T> extends LiveData<T> {
  final List<ChangeNotifier> _sources;
  final T Function() _transform;
  T _value;

  @override
  T get value => _value;

  _MergedLiveData({
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
