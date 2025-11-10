part of 'package:mvvm_kit/src/live_data/live_data.dart';

extension LiveDataExtensions<T> on LiveData<T> {
  LiveData<T> mirror() => _LiveDataMirror(this);

  LiveData<S> transform<S>(
    S Function(LiveData<T> data) transform,
    DataScope? scope,
  ) => _TransformedLiveDataMirror(this, transform: transform, scope: scope);

  HotswapLiveData<T> hotswappable([DataScope? scope]) =>
      HotswapLiveData(this, scope);
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
      _AutoDisposeFilter(this, check);

  LiveData<Iterable<D>> notNull() =>
      _AutoDisposeFilter<D>(this, (value) => value != null);
}
