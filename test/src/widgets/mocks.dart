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

// ViewModel que rastreia chamadas de dispose
class TrackableCounterViewModel extends CounterViewModel {
  int disposeCallCount = 0;

  @override
  void dispose() {
    disposeCallCount++;
    super.dispose();
  }
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

// ============================================
// ViewWidget Test Mocks
// ============================================

// ViewModel para testes de ViewWidget
class UserViewModel extends ViewModel {
  late final userId = mutable<String?>(null);
  late final userData = mutable<String>('No data');

  String? _lastUserId;
  int reloadCount = 0;

  void setUserId(String? id) {
    if (_lastUserId != id) {
      _lastUserId = id;
      userId.value = id;
      reloadCount++;
      userData.value = 'User data for $id';
    }
  }
}

// Classe para rastrear callbacks
class CallbackTracker {
  int onInitCallCount = 0;
  int onUpdateCallCount = 0;
  BuildContext? lastContext;
  ViewModel? lastViewModel;

  void reset() {
    onInitCallCount = 0;
    onUpdateCallCount = 0;
    lastContext = null;
    lastViewModel = null;
  }
}

// ViewWidget básico para testes
class TestViewWidget extends ViewWidget<CounterViewModel> {
  final CallbackTracker? tracker;

  const TestViewWidget({super.key, this.tracker});

  @override
  void onInit(BuildContext context, CounterViewModel viewModel) {
    tracker?.onInitCallCount++;
    tracker?.lastContext = context;
    tracker?.lastViewModel = viewModel;
  }

  @override
  void onUpdate(BuildContext context, CounterViewModel viewModel) {
    tracker?.onUpdateCallCount++;
    tracker?.lastContext = context;
    tracker?.lastViewModel = viewModel;
  }

  @override
  Widget build(BuildContext context, CounterViewModel viewModel) {
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

// ViewWidget simples sem MaterialApp para testes de múltiplas instâncias
class SimpleTestViewWidget extends ViewWidget<CounterViewModel> {
  const SimpleTestViewWidget({super.key});

  @override
  Widget build(BuildContext context, CounterViewModel viewModel) {
    return Watch(
      viewModel.counter,
      builder: (context, value) => Text('Counter: $value'),
    );
  }
}

// ViewWidget com props para testes de CSC
class UserProfileWidget extends ViewWidget<UserViewModel> {
  final String userId;
  final CallbackTracker? tracker;

  const UserProfileWidget({super.key, required this.userId, this.tracker});

  @override
  void onInit(BuildContext context, UserViewModel viewModel) {
    tracker?.onInitCallCount++;
    viewModel.setUserId(userId);
  }

  @override
  void onUpdate(BuildContext context, UserViewModel viewModel) {
    tracker?.onUpdateCallCount++;
    viewModel.setUserId(userId);
  }

  @override
  Widget build(BuildContext context, UserViewModel viewModel) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Text('UserId: $userId'),
            Watch(
              viewModel.userData,
              builder: (context, data) => Text('Data: $data'),
            ),
          ],
        ),
      ),
    );
  }
}

// ViewWidget com custom resolveViewModel
class CustomResolveViewWidget extends ViewWidget<CounterViewModel> {
  final CounterViewModel? customViewModel;

  const CustomResolveViewWidget({super.key, this.customViewModel});

  @override
  CounterViewModel? resolveViewModel() => customViewModel;

  @override
  Widget build(BuildContext context, CounterViewModel viewModel) {
    return MaterialApp(
      home: Scaffold(
        body: Watch(
          viewModel.counter,
          builder: (context, value) => Text('Counter: $value'),
        ),
      ),
    );
  }
}

// Parent ViewWidget para testes de CSC
class ParentViewWidget extends ViewWidget<CounterViewModel> {
  final int sharedValue;

  const ParentViewWidget({super.key, required this.sharedValue});

  @override
  Widget build(BuildContext context, CounterViewModel viewModel) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Text('Parent Counter: ${viewModel.counter.value}'),
            ChildViewWidget(parentValue: sharedValue),
          ],
        ),
      ),
    );
  }
}

// Child ViewWidget para testes de CSC
class ChildViewWidget extends ViewWidget<CounterViewModel> {
  final int parentValue;

  const ChildViewWidget({super.key, required this.parentValue});

  @override
  Widget build(BuildContext context, CounterViewModel viewModel) {
    return Column(
      children: [
        Text('Parent Value: $parentValue'),
        Watch(
          viewModel.counter,
          builder: (context, counter) => Text('Child Counter: $counter'),
        ),
      ],
    );
  }
}
