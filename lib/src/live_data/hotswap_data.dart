import 'package:mvvm_kit/mvvm_kit.dart';

class HotswapLiveData<T> extends LiveData<T> {
  late LiveData<T> _base;

  @override
  T get value => _base.value;

  HotswapLiveData(LiveData<T> base, DataScope? scope)
    : super(base.value, scope) {
    _base = base;
    changeDetector = base.changeDetector;
    _base.subscribe(_onBaseChanged);
  }

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
