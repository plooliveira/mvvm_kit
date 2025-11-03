import 'package:mvvm_kit/src/live_data/live_data.dart';
import 'package:mvvm_kit/src/live_data/scope.dart';

class _ScopeBridge<T> extends DataScope {
  final LiveData<T> _source;
  BridgedLiveData<T>? _target;

  _ScopeBridge(this._source) : super(parent: _source.scope) {
    _source.addListener(onSourceUpdated);
  }

  void onSourceUpdated() {
    _target?._updateValue(_source.value);
  }

  @override
  void cleanScope() {
    _source.removeListener(onSourceUpdated);
    _target = null;

    super.cleanScope();
  }
}

class BridgedLiveData<T> extends LiveData<T> {
  T _value;

  @override
  T get value => _value;

  BridgedLiveData(this._value, DataScope scope) : super(_value, scope);

  void _updateValue(T value) {
    _value = value;
    notifyIfChanged();
  }
}

extension BridgedData<T> on LiveData<T> {
  LiveData<T> bridge(DataScope to) {
    final child = _ScopeBridge(this);
    final mirror = BridgedLiveData(value, to);
    child._target = mirror;
    return mirror;
  }
}

extension BridgedScope on DataScope {
  LiveData<T> bridge<T>(LiveData<T> source) {
    final child = _ScopeBridge(source);
    final mirror = BridgedLiveData(source.value, this);
    child._target = mirror;
    return mirror;
  }
}
