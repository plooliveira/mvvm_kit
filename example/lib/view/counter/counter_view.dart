import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm_kit/mvvm_kit.dart';
import 'counter_viewmodel.dart';

class CounterRoute extends GoRoute {
  CounterRoute()
    : super(
        path: '/counter',
        name: 'counter',
        builder: (context, state) => CounterView(),
      );
}

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends ViewState<CounterViewModel, CounterView> {
  // In this simple example we create the ViewModel directly, but that is not a good practice for real apps especially for testability.
  // The other example views show how to use service locators like Provider and GetIt.
  @override
  late final CounterViewModel viewModel = CounterViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Watch rebuilds only when counter value changes
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

            // Separate Watch for loading indicator
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

            // Watch disables buttons during async operations
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
