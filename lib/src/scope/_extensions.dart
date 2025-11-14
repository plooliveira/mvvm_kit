part of 'scope.dart';

/// Extension methods for creating [MutableLiveData] within a [DataScope].
extension MutableDataScope on DataScope {
  /// Creates and registers a [MutableLiveData] with an initial value.
  ///
  /// This is a convenience method that creates a MutableLiveData and
  /// automatically adds it to this scope for lifecycle management.
  ///
  /// Example:
  /// ```dart
  /// final scope = DataScope();
  /// final counter = scope.mutable(0);
  /// final name = scope.mutable('John');
  /// ```
  MutableLiveData<T> mutable<T>(T start) {
    return add(MutableLiveData(start));
  }

  /// Creates a MutableLiveData that mirrors a source LiveData.
  ///
  /// Creates a MutableLiveData that starts with the source's value and
  /// automatically updates whenever the source changes. Changes to the
  /// returned MutableLiveData do NOT affect the source (unidirectional).
  /// The bridge is automatically cleaned up when this scope is disposed.
  ///
  /// Example:
  /// ```dart
  /// final source = MutableLiveData(42);
  /// final mirror = scope.bridgeFrom(source);
  /// source.value = 10; // mirror.value becomes 10
  /// mirror.value = 20; // source.value remains 10
  /// ```
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

/// Extension methods for combining multiple [LiveData] or [ChangeNotifier] sources.
extension DataScopeExtensions on DataScope {
  /// Combines multiple LiveData sources using a mediator function.
  ///
  /// Creates a LiveData that updates whenever any of the [sources] change.
  /// The [mediate] function is called to compute the new value.
  ///
  /// Example:
  /// ```dart
  /// final firstName = MutableLiveData('John');
  /// final lastName = MutableLiveData('Doe');
  ///
  /// final fullName = scope.join([firstName, lastName], () {
  ///   return '${firstName.value} ${lastName.value}';
  /// });
  /// ```
  LiveData<T> join<T>(List<LiveData> sources, T Function() mediate) =>
      add(_MediatorLiveData(sources, mediate));

  /// Merges multiple ChangeNotifier sources into a single LiveData.
  ///
  /// Similar to [join] but works with any [ChangeNotifier], not just LiveData.
  /// The [transform] function is called whenever any source notifies.
  ///
  /// Example:
  /// ```dart
  /// final notifier1 = ValueNotifier(1);
  /// final notifier2 = ValueNotifier(2);
  ///
  /// final sum = scope.merge([notifier1, notifier2], () {
  ///   return notifier1.value + notifier2.value;
  /// });
  /// ```
  LiveData<T> merge<T>(List<ChangeNotifier> sources, T Function() transform) {
    return _MergedLiveData<T>(
      sources: sources,
      transform: transform,
      scope: this,
    );
  }
}
