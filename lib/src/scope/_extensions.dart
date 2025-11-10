part of 'scope.dart';

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

    final cleanup = _DisposeCallback(() {
      source.removeListener(listener);
      if (remove(mirror)) {
        mirror.dispose();
      }
    });

    add(cleanup);
    return mirror;
  }
}

extension DataScopeExtensions on DataScope {
  LiveData<T> join<T>(List<LiveData> sources, T Function() mediate) =>
      add(_MediatorLiveData(sources, mediate));

  LiveData<T> merge<T>(List<ChangeNotifier> sources, T Function() transform) {
    return _MergedLiveData<T>(
      sources: sources,
      transform: transform,
      scope: this,
    );
  }
}
