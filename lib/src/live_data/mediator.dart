import 'package:mvvm_kit/src/live_data/live_data.dart';
import 'package:mvvm_kit/src/live_data/scope.dart';

class MediatorLiveData<T> extends LiveData<T> {
  final T Function() mediate;
  final List<LiveData> sources;

  late T _value;

  @override
  T get value => _value;

  MediatorLiveData(this.sources, this.mediate) : super() {
    _value = mediate();
    for (var source in sources) {
      source.subscribe(_mediate);
    }
  }

  void _mediate(dynamic _) {
    final next = mediate();
    if (changeDetector(next, _value)) {
      _value = next;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (var source in sources) {
      source.unsubscribe(_mediate);
    }
    super.dispose();
  }
}

extension MediatorDataScope on DataScope {
  MediatorLiveData<T> join<T>(List<LiveData> sources, T Function() mediate) =>
      add(MediatorLiveData(sources, mediate));
}
