import 'package:flutter/material.dart';
import 'package:mvvm_kit/mvvm_kit.dart';
import 'counter_viewmodel.dart';

class CounterView extends ViewWidget<CounterViewModel> {
  CounterView({super.key}) : super(viewModel: CounterViewModel());

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends ViewState<CounterViewModel, CounterView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Watch(
              viewModel.counter,
              builder: (context, value) => Text(
                '$value',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 40),

            Watch(
              viewModel.isLoading,
              builder: (context, isLoading) {
                return SizedBox(
                  height: 40,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const SizedBox.shrink(),
                );
              },
            ),

            const SizedBox(height: 40),

            Watch(
              viewModel.isLoading,
              builder: (context, isLoading) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : viewModel.decrement,
                      icon: const Icon(Icons.remove),
                      label: const Text('-1'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : viewModel.increment,
                      icon: const Icon(Icons.add),
                      label: const Text('+1'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : viewModel.increment100Async,
                      icon: const Icon(Icons.schedule),
                      label: const Text('+100 Async'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
