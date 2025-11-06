import 'package:mvvm_kit/mvvm_kit.dart';

class MutableLiveData<T> extends LiveData<T> {
  T _value;

  @override
  T get value => _value;

  MutableLiveData(T super.value, [bool emitAll = false, super.scope])
    : _value = value {
    if (emitAll) {
      changeDetector = (T to, T from) => true;
    }
  }

  set value(T to) {
    if (changeDetector(to, _value)) {
      _value = to;
      notifyListeners();
    }
  }

  LiveData<T> get immutable => this;

  void update(Function(T value) block) {
    block(_value);
    notifyListeners();
  }
}
