part of 'package:mvvm_kit/src/live_data/live_data.dart';

/// Extension methods for [LiveData] transformation and manipulation.
extension LiveDataExtensions<T> on LiveData<T> {
  /// Creates a mirror that observes this LiveData.
  ///
  /// Returns a new LiveData that automatically updates when this
  /// LiveData's value changes. Useful for exposing read-only views.
  ///
  /// Example:
  /// ```dart
  /// final original = MutableLiveData(42);
  /// final mirrored = original.mirror();
  /// original.value = 10; // mirrored.value becomes 10
  /// ```
  LiveData<T> mirror() => _LiveDataMirror(this);

  /// Transforms this LiveData into a different type.
  ///
  /// Creates a new LiveData that computes its value by applying the
  /// [transform] function whenever this LiveData changes.
  ///
  /// The returned LiveData shares the same scope as the source and will
  /// be automatically disposed when the source is disposed.
  ///
  /// Example:
  /// ```dart
  /// final counter = MutableLiveData(5);
  /// final doubled = counter.transform((data) => data.value * 2);
  /// // doubled.value is 10
  /// ```
  LiveData<S> transform<S>(S Function(LiveData<T> data) transform) =>
      _TransformedLiveDataMirror(this, transform: transform);

  /// Converts this LiveData into a HotswapLiveData.
  ///
  /// Returns a [HotswapLiveData] that initially observes this LiveData
  /// but can later switch to observe a different source.
  ///
  /// Example:
  /// ```dart
  /// final data1 = MutableLiveData(1);
  /// final hotswap = data1.hotswappable();
  /// 
  /// final data2 = MutableLiveData(2);
  /// hotswap.hotswap(data2); // Now observes data2
  /// ```
  HotswapLiveData<T> hotswappable([DataScope? scope]) =>
      HotswapLiveData(this, scope);
}

/// Extension methods for [LiveData] containing collections.
extension ListLiveData<D> on LiveData<Iterable<D>> {
  /// Whether the current collection is empty.
  bool get isEmpty => value.isEmpty;

  /// Whether the current collection is not empty.
  bool get isNotEmpty => value.isNotEmpty;

  /// The number of elements in the current collection.
  int get length => value.length;

  /// Maps each element to a new value.
  ///
  /// Convenience shorthand for `value.map(toElement)`.
  Iterable<T> map<T>(T Function(D value) toElement) => value.map(toElement);

  /// Applies a function to each element.
  ///
  /// Convenience shorthand for `value.forEach(action)`.
  void forEach(void Function(D element) action) => value.forEach(action);

  /// Expands each element into zero or more elements.
  ///
  /// Convenience shorthand for `value.expand(toElements)`.
  Iterable<T> expand<T>(Iterable<T> Function(D element) toElements) =>
      value.expand(toElements);

  /// Creates a LiveData that filters elements based on a condition.
  ///
  /// Returns a new LiveData that updates whenever this LiveData changes,
  /// containing only elements that satisfy the [check] function.
  ///
  /// The returned LiveData shares the same scope as the source and will
  /// be automatically disposed when the source is disposed.
  ///
  /// Example:
  /// ```dart
  /// final numbers = MutableLiveData([1, 2, 3, 4, 5]);
  /// final evens = numbers.filtered((n) => n % 2 == 0);
  /// // evens.value is [2, 4]
  /// ```
  LiveData<Iterable<D>> filtered(bool Function(D value) check) =>
      _AutoDisposeFilter(this, check);

  /// Creates a LiveData that filters out null elements.
  ///
  /// Returns a new LiveData containing only non-null elements.
  ///
  /// The returned LiveData shares the same scope as the source and will
  /// be automatically disposed when the source is disposed.
  ///
  /// Example:
  /// ```dart
  /// final items = MutableLiveData([1, null, 2, null, 3]);
  /// final nonNull = items.notNull();
  /// // nonNull.value is [1, 2, 3]
  /// ```
  LiveData<Iterable<D>> notNull() =>
      _AutoDisposeFilter<D>(this, (value) => value != null);
}
