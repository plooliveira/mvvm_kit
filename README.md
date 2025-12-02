  <br/>
  <br/>
  <p align="center">
    <img src="mvvm_kit_logo.png" alt="mvvm_kit logo" width="500">
  </p>

<br/>

[![ ](https://img.shields.io/pub/v/mvvm_kit.svg)](https://pub.dev/packages/mvvm_kit) &nbsp; [![Build Status](https://github.com/plooliveira/mvvm_kit/actions/workflows/test.yaml/badge.svg)](https://github.com/plooliveira/mvvm_kit/actions)

⚡️ Granular reactivity <br/>
🧪 Highly testable <br/>
👀 Predictable <br/>
🛡️ Safe <br/>
🧩 Versatile <br/>
📈 Scalable <br/>
💜 Enjoyable <br/>

## Disclaimer
This package is still in early development. While it is functional, there may be breaking changes in future releases as we continue to improve and refine the API. So please use it with caution in production applications.

## Overview 

This package provides a simple and lightweight implementation of the MVVM (Model-View-ViewModel) pattern for Flutter applications. It is designed to be easy to use and to help you write clean, testable, and maintainable code.

The core of the package is the `LiveData` class, which is an observable data holder that can be observed by UI components. When the data changes, the UI is automatically updated.

The package also provides a `ViewModel` class, which is a base class for your view models. The `ViewModel` class manages the lifecycle of `LiveData` objects and provides a way to handle long-running actions.

## Installation

To use this package, add `mvvm_kit` as a dependency running `pub add mvvm_kit` or by adding it to your `pubspec.yaml`.


## Usage

### Simple Example

Here is a simple example of how to use the package to create a counter application.

**1. Create a `ViewModel`**

```dart
import 'package:mvvm_kit/mvvm_kit.dart';

class CounterViewModel extends ViewModel {
  final _counter = mutable(0);
  LiveData<int> get counter => _counter;

  void increment() => _counter.value++;
}
```

**2. Create a `View` using `ViewWidget`**

This widget is a simple way to create a view. It uses the cascade state composition pattern where each widget maintains its own isolated ViewModel while cascading state changes to children through reactive constructor injection. See more details on the [ViewWidget](https://pub.dev/documentation/mvvm_kit/latest/mvvm_kit/ViewWidget-class.html) class documentation.
 
```dart
class CounterView extends ViewWidget<CounterViewModel> {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context, CounterViewModel viewModel) => Scaffold(
    body: Watch(
      viewModel.counter,
      builder: (context, value) => Text('$value'),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: viewModel.increment,
      child: const Icon(Icons.add),
    ),
  );
}
```

**2. Create a `View` using `ViewState`**
To have full controll of the view lifecycle, you can use the `ViewState` class. See more details on the [ViewState](https://pub.dev/documentation/mvvm_kit/latest/mvvm_kit/ViewState-class.html) class documentation.

```dart
import 'package:flutter/material.dart';
import 'package:mvvm_kit/mvvm_kit.dart';

import 'counter_viewmodel.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends ViewState<CounterViewModel, CounterView> {
  // By default, ViewState uses a built-in service locator for dependency injection.
  // You can override resolveViewModel() to provide a different injection strategy. e.g. Constructor injection, GetIt, Provider, etc.
  // @override
  // CounterViewModel resolveViewModel() => GetIt.I();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
      ),
      body: Center(
        child: Watch(
          viewModel.counter,
          builder: (context, value) => Text('$value'),
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

Don't forget to register your `CounterViewModel` in the service locator before running the app:

```dart
import 'counter_viewmodel.dart';
import 'package:mvvm_kit/mvvm_kit.dart';

void setupLocator() {
  SL.I.registerFactory(() => CounterViewModel());
  // Or using other service locators like GetIt
  // GetIt.I.registerFactory<CounterViewModel>(() => CounterViewModel());
}

void main() {
  setupLocator();
  runApp(const MyApp());
}
```

### Listen to multiple LiveData

You can use `GroupWatch` to listen to multiple `LiveData` objects at once. You can also use the `onActive` and `onInactive` callbacks in your `ViewModel` to perform actions when the view becomes active or inactive.

```dart
import 'package:mvvm_kit/mvvm_kit.dart';

class PersonViewModel extends ViewModel {
  final _name = mutable('John Doe');
  final _age = mutable(30);
  
  LiveData<String> get name => _name;
  LiveData<int> get age => _age;

  @override
  void onActive() {
    // Perform actions when the view becomes active
  }
  
  @override
  void onInactive() {
    // Perform actions when the view becomes inactive
  }
}
```

```dart
import 'package:flutter/material.dart';
import 'package:mvvm_kit/mvvm_kit.dart';

import 'person_viewmodel.dart';

class PersonView extends StatefulWidget {
  const PersonView({super.key});

  @override
  State<PersonView> createState() => _PersonViewState();
}

class _PersonViewState extends ViewState<PersonViewModel, PersonView> {

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
            final name = viewModel.name.value;
            final age = viewModel.age.value;

            return Text(
              '$name is $age years old.',
              style: Theme.of(context).textTheme.headlineMedium,
            );
          },
        ),
      ),
    );
  }
}
```

## Minimalist built-in service locator (SL)
The package includes a minimalist built-in service locator called `SL` that you can use to register and retrieve your `ViewModel` instances or other dependencies.
There is no asynchronous support, no scopes, no modules, no tags support. You can register factories, singletons, or lazy singletons. This is useful for all kinds of applications that has a straightforward dependency graph.
You can register your dependencies like this:

```dart
import 'package:mvvm_kit/mvvm_kit.dart'; 

// As factory
SL.instance.registerFactory(() => CounterViewModel());
// As singleton (Use the shortcut .I for convenience)
SL.I.registerSingleton(CounterRepository());
// As lazy singleton
SL.I.registerLazySingleton(() => CounterService());
```

You can resolve dependencies with constructor injection like this:

```dart
SL.I.registerSingleton(CounterRepository());
SL.I.registerLazySingleton(() => CounterService());
SL.I.registerFactory((i) => CounterViewModel(
  repository: i(),
  service: i(),
));
```

And use abstract types or interfaces:

```dart
SL.I.registerSingleton<CounterRepository>(CounterRepositoryImpl());
```

To retrieve any registered type, use:

```dart
final counterViewModel = SL.I.get<CounterViewModel>();
```

or by type inference:

```dart
final CounterViewModel counterViewModel = SL.I.get();
```

Ps: The ViewState class uses this service locator by default to create ViewModel instances. You can override the `resolveViewModel()` method to use a different dependency injection strategy if needed.
```dart
  class _CounterViewState extends ViewState<CounterViewModel, CounterView> {
    @override
    CounterViewModel resolveViewModel() => widget.viewModel;
    // ...
  }
```

## Key Features

- **LiveData**: Observable data holders that notify observers when values change,
- **ViewModel**: Lifecycle-aware UI logic layer with automatic resource management
- **Watch/GroupWatch**: Widgets for observing LiveData changes
- **DataScope**: Container that automatically disposes LiveData instances when no longer needed, preventing memory leaks
- **Transformations**: `transform()`, `filtered()`, `mirror()` for data manipulation
- **HotswapLiveData**: Dynamically switch between data sources
- **RepositoryData**: Pattern for integrating data layers with caching and refreshing capabilities
- **Built-in Service Locator**: Minimalist service locator for dependency injection

## Documentation

For more detailed documentation, please visit the [MVVM Kit Library reference](https://pub.dev/documentation/mvvm_kit/latest/mvvm_kit/).