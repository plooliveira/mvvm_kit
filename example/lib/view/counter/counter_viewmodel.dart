import 'package:mvvm_kit/mvvm_kit.dart';

class CounterViewModel extends ViewModel {
  late final _counter = mutable(0);
  LiveData<int> get counter => _counter;

  void increment() => _counter.value++;

  void decrement() => _counter.value--;

  Future<void> increment100Async() async {
    await executeAsync(() async {
      await Future.delayed(const Duration(seconds: 2));
      _counter.value += 100;
    });
  }
}
