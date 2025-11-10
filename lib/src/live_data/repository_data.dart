import 'package:mvvm_kit/mvvm_kit.dart';

abstract class RepositoryData<T> {
  T get value;

  LiveData<T> get live;

  LiveData<S> transform<S>(
    S Function(LiveData<T> data) transform,
    DataScope? scope,
  );
}

abstract class SourceRepositoryData<T, D extends LiveData<T>>
    extends RepositoryData<T> {
  @override
  T get value => source.value;

  D get source;

  @override
  LiveData<T> get live => source.mirror();

  @override
  LiveData<S> transform<S>(
    S Function(LiveData<T>) transform,
    DataScope? scope,
  ) => source.transform(transform);
}

class LiveRepositoryData<T> extends SourceRepositoryData<T, LiveData<T>> {
  @override
  final LiveData<T> source;

  LiveRepositoryData(this.source);
}

class MutableRepositoryData<T>
    extends SourceRepositoryData<T, MutableLiveData<T>> {
  @override
  final MutableLiveData<T> source;

  MutableRepositoryData({
    T? value,
    MutableLiveData<T>? source,
    bool Function(T, T)? changeDetector,
  }) : source = source ?? MutableLiveData(value as T) {
    if (changeDetector != null) {
      this.source.changeDetector = changeDetector;
    }
  }

  set value(T to) {
    source.value = to;
  }
}
