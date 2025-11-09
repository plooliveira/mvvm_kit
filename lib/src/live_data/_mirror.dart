part of './live_data.dart';

T _liveDataTransform<T>(LiveData<T> data) {
  return data.value;
}

T _valueNotifierTransform<T>(ValueNotifier<T> data) {
  return data.value;
}

class _NotifierData<T, B extends ChangeNotifier> extends LiveData<T> {
  final B base;
  final T Function(B) onTransform;

  @override
  T get value => _value;

  late T _value;

  _NotifierData(this.base, {required T Function(B) transform, DataScope? scope})
    : onTransform = transform,
      super(transform(base)) {
    _value = onTransform(base);
    base.addListener(_onBaseChanged);
    scope?.add(this);
  }

  @override
  void reload() {
    _onBaseChanged();
  }

  void _onBaseChanged() {
    _value = onTransform(base);
    notifyIfChanged();
  }

  @override
  void dispose() {
    base.removeListener(_onBaseChanged);
    super.dispose();
  }
}

class _LiveDataMirror<T> extends _NotifierData<T, LiveData<T>> {
  _LiveDataMirror(LiveData<T> base, {T Function(LiveData<T>)? transform})
    : super(
        base,
        transform: transform ?? _liveDataTransform,
        scope: base.scope,
      ) {
    changeDetector = base.changeDetector;
  }
}

class _TransformedLiveDataMirror<T, S, B extends LiveData<S>>
    extends _NotifierData<T, B> {
  _TransformedLiveDataMirror(
    super.base, {
    required super.transform,
    DataScope? scope,
  }) : super(scope: scope ?? base.scope);
}

class _ValueNotifierData<T> extends _NotifierData<T, ValueNotifier<T>> {
  _ValueNotifierData(
    super.base,
    DataScope? scope, {
    T Function(ValueNotifier<T>)? transform,
  }) : super(transform: transform ?? _valueNotifierTransform, scope: scope);
}

T? _hardCast<T, D>(D? value) => value == null ? null : value as T;

class _StreamData<T, D, S extends Stream<D>> extends LiveData<T?> {
  final S base;
  final T? Function(D?) onTransform;

  @override
  T? get value => _value;

  late T? _value;

  StreamSubscription<D>? _subscription;

  _StreamData(
    this.base,
    DataScope? scope, {
    T? Function(D?)? transform,
    D? current,
    T? value,
  }) : onTransform = transform ?? _hardCast,
       super(value ?? transform?.call(current), scope) {
    _value = value ?? onTransform(current);
    _subscription = base.listen(_onBaseChanged);
  }

  void _onBaseChanged(D value) {
    _value = onTransform(value);
    notifyIfChanged();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}

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
