import 'package:mvvm_kit/mvvm_kit.dart';

/// Base interface for repository data holders.
///
/// [RepositoryData] provides a common interface for accessing data from
/// repositories, whether mutable or immutable. It offers both direct value
/// access and observable LiveData.
///
/// See also:
/// * [LiveRepositoryData], for immutable repository data
/// * [MutableRepositoryData], for mutable repository data
abstract class RepositoryData<T> {
  /// The current value.
  T get value;

  /// Returns a LiveData that observes this repository data.
  LiveData<T> get live;

  /// Transforms the data into a different type.
  ///
  /// Returns a LiveData that applies [transform] to compute its value.
  LiveData<S> transform<S>(
    S Function(LiveData<T> data) transform,
    DataScope? scope,
  );
}

/// Repository data backed by an immutable LiveData source.
///
/// Wraps an existing LiveData to provide repository-style access patterns.
/// Use this when you have read-only data from a repository.
///
/// Example:
/// ```dart
/// final liveData = MutableLiveData(42);
/// final repo = LiveRepositoryData(liveData);
/// print(repo.value); // 42
/// final observed = repo.live; // Get observable LiveData
/// ```
class LiveRepositoryData<T> extends _SourceRepositoryData<T, LiveData<T>> {
  @override
  final LiveData<T> source;

  /// Creates a LiveRepositoryData wrapping the given [source].
  LiveRepositoryData(this.source);
}

/// Repository data backed by a MutableLiveData source.
///
/// Provides both read and write access to repository data.
/// Use this when you need to modify repository data.
///
/// Example:
/// ```dart
/// final repo = MutableRepositoryData(value: 0);
/// print(repo.value); // 0
/// repo.value = 42;
/// print(repo.value); // 42
/// ```
class MutableRepositoryData<T>
    extends _SourceRepositoryData<T, MutableLiveData<T>> {
  @override
  final MutableLiveData<T> source;

  /// Creates a MutableRepositoryData.
  ///
  /// Provide either [value] to create a new MutableLiveData, or [source]
  /// to wrap an existing one. Optionally set a custom [changeDetector].
  ///
  /// Example:
  /// ```dart
  /// // Create with initial value
  /// final repo1 = MutableRepositoryData(value: 0);
  ///
  /// // Wrap existing MutableLiveData
  /// final liveData = MutableLiveData(0);
  /// final repo2 = MutableRepositoryData(source: liveData);
  /// ```
  MutableRepositoryData({
    T? value,
    MutableLiveData<T>? source,
    bool Function(T, T)? changeDetector,
  }) : source = source ?? MutableLiveData(value as T) {
    if (changeDetector != null) {
      this.source.changeDetector = changeDetector;
    }
  }

  /// Sets a new value for the repository data.
  ///
  /// Delegates to the underlying MutableLiveData source.
  set value(T to) {
    source.value = to;
  }
}

abstract class _SourceRepositoryData<T, D extends LiveData<T>>
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
