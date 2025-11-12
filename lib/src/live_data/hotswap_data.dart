import 'package:mvvm_kit/mvvm_kit.dart';

/// A [LiveData] that can dynamically switch between different source LiveData.
///
/// [HotswapLiveData] observes a source LiveData and can switch to observe
/// a different source at runtime using [hotswap]. This is useful for scenarios
/// where the data source needs to change dynamically, such as switching between
/// different repositories or API endpoints.
///
/// Example:
/// ```dart
/// final repo1Data = MutableLiveData('Source 1');
/// final repo2Data = MutableLiveData('Source 2');
/// 
/// final hotswap = HotswapLiveData(repo1Data, scope);
/// print(hotswap.value); // 'Source 1'
/// 
/// hotswap.hotswap(repo2Data);
/// print(hotswap.value); // 'Source 2'
/// ```
///
/// See also:
/// * [LiveData.hotswappable], extension method to create HotswapLiveData
class HotswapLiveData<T> extends LiveData<T> {
  late LiveData<T> _base;

  @override
  T get value => _base.value;

  /// Creates a HotswapLiveData that initially observes [base].
  ///
  /// The [scope] parameter is optional and determines lifecycle management.
  HotswapLiveData(LiveData<T> base, DataScope? scope)
    : super(base.value, scope) {
    _base = base;
    changeDetector = base.changeDetector;
    _base.subscribe(_onBaseChanged);
  }

  /// Switches to observe a different LiveData source.
  ///
  /// Unsubscribes from the current source and subscribes to the new [base].
  /// If [disposeOld] is `true` (default), the old source is disposed.
  /// Does nothing if the new base is the same as the current one.
  ///
  /// Example:
  /// ```dart
  /// final data1 = MutableLiveData(1);
  /// final data2 = MutableLiveData(2);
  /// final hotswap = HotswapLiveData(data1, null);
  /// 
  /// hotswap.hotswap(data2); // Switches to data2, disposes data1
  /// hotswap.hotswap(data2); // Does nothing (already observing data2)
  /// ```
  void hotswap(LiveData<T> base, {bool disposeOld = true}) {
    if (_base == base) {
      return;
    }
    _base.unsubscribe(_onBaseChanged);
    if (disposeOld) {
      _base.dispose();
    }
    _base = base;
    changeDetector = base.changeDetector;
    _base.subscribe(_onBaseChanged);
    notifyIfChanged();
  }

  void _onBaseChanged(T value) {
    notifyIfChanged();
  }

  @override
  void dispose() {
    _base.unsubscribe(_onBaseChanged);
    super.dispose();
  }
}
