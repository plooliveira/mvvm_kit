import 'package:mvvm_kit/mvvm_kit.dart';

// Simple counter demonstrating MutableLiveData and executeAsync
class CounterViewModel extends ViewModel {
  // MutableLiveData created with mutable() is auto-disposed by the ViewModel's scope
  late final _counter = mutable(0);
  LiveData<int> get counter => _counter;

  void increment() => _counter.value++;

  void decrement() => _counter.value--;

  // executeAsync automatically manages isLoading state during async operations
  Future<void> increment100Async() async {
    await executeAsync(() async {
      await Future.delayed(const Duration(seconds: 2));
      _counter.value += 100;
    });
  }
}
