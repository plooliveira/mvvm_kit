import 'package:flutter/material.dart';
import 'package:mvvm_kit/mvvm_kit.dart';
import 'package:mocktail/mocktail.dart';

// Mock para o ViewModel
class MockCounterViewModel extends Mock implements CounterViewModel {}

// ViewModel de teste real
class CounterViewModel extends ViewModel {
  late final counter = mutable(0);

  void increment() => counter.value++;
}

// View de teste para usar com ViewState
class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends ViewState<CounterViewModel, CounterView> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Watch(
              viewModel.counter,
              builder: (context, value) => Text('Counter: $value'),
            ),
            Text('ViewModel Active: ${viewModel.isActive}'),
          ],
        ),
      ),
    );
  }
}

// Mock para LiveData
class MockLiveData<T> extends Mock implements LiveData<T> {}

// ViewModel para GroupWatch
class ProfileViewModel extends ViewModel {
  late final name = mutable('John');
  late final age = mutable(30);
}
