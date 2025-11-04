# MVVM Kit

An implementation of the MVVM pattern using LiveData for Flutter.

## Overview

This package provides a simple and lightweight implementation of the MVVM (Model-View-ViewModel) pattern for Flutter applications. It is designed to be easy to use and to help you write clean, testable, and maintainable code.

The core of the package is the `LiveData` class, which is an observable data holder that can be observed by UI components. When the data changes, the UI is automatically updated.

The package also provides a `ViewModel` class, which is a base class for your view models. The `ViewModel` class manages the lifecycle of `LiveData` objects and provides a way to handle long-running actions.

## Installation

To use this package, add `mvvm_kit` as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  mvvm_kit: ^0.1.0
```

## Usage

### Simple Example

Here is a simple example of how to use the package to create a counter application.

**1. Create a `ViewModel`**

```dart
import 'package:mvvm_kit/live_viewmodel.dart';

class CounterViewModel extends ViewModel {
  final _counter = observable(0);
  LiveData<int> get counter => _counter;


  void increment() {
    _counter.value++;
  }
}
```

**2. Create a `View`**

```dart
import 'package:flutter/material.dart';
import 'package:mvvm_kit/live_viewmodel.dart';
import 'counter_viewmodel.dart';

class CounterPage extends ViewWidget<CounterViewModel> {
  CounterPage({super.key}) : super(viewModel: CounterViewModel());

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends ViewState<CounterViewModel, CounterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
      ),
      body: Center(
        child: Watch(
          viewModel.counter,
          builder: (context) {
            return Text(
              '${viewModel.counter.value}',
              style: Theme.of(context).textTheme.headlineMedium,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Listen to multiple LiveData

You can use `GroupWatch` to listen to multiple `LiveData` objects at once. You can also use the `onActive` and `onInactive` callbacks in your `ViewModel` to perform actions when the view becomes active or inactive.

```dart
import 'package:mvvm_kit/live_viewmodel.dart';

class GroupViewModel extends ViewModel {
  final name = observable('John Doe');
  final age = observable(30);
}
```

```dart
import 'package:flutter/material.dart';
import 'package:mvvm_kit/live_viewmodel.dart';
import 'advanced_viewmodel.dart';

class AdvancedPage extends ViewWidget<GroupViewModel> {
  AdvancedPage({super.key}) : super(viewModel: GroupViewModel());

  @override
  State<AdvancedPage> createState() => _AdvancedPageState();
}

class _AdvancedPageState extends ViewState<GroupViewModel, AdvancedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Watch Example'),
      ),
      body: Center(
        child: GroupWatch(
          [viewModel.name, viewModel.age],
          builder: (context) {
            return Text(
              '${viewModel.name.value} is ${viewModel.age.value} years old.',
              style: Theme.of(context).textTheme.headlineMedium,
            );
          },
        ),
      ),
    );
  }
}
```

