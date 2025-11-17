import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_kit/src/service_locator.dart';
import '../viewmodel.dart';

/// Base state for MVVM views.
///
/// [ViewState] manages the lifecycle connection between a [StatefulWidget] and
/// its [ViewModel]. It automatically:
/// * Sets the ViewModel as active/inactive based on widget lifecycle
/// * Responds to app lifecycle changes (background/foreground)
/// * Disposes the ViewModel when the widget is disposed
///
/// Example:
/// ```dart
/// class _CounterViewState extends ViewState<CounterViewModel, CounterView> {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: Watch(
///         viewModel.counter,
///         builder: (context, value) => Text('$value'),
///       ),
///     );
///   }
/// }
/// ```
///
/// See also:
/// * [ViewModel], which provides onActive/onInactive callbacks
abstract class ViewState<T extends ViewModel, W extends StatefulWidget>
    extends _BaseState<W> {
  /// Creates the ViewModel instance to be used by this ViewState.
  /// By default, it retrieves the ViewModel from the service locator.
  /// Override this method to provide a custom ViewModel instance using a different method. e.g. GetIt, Provider, Constructor injection etc.
  @protected
  T createViewModel() => simpleLocator.get<T>();

  /// The ViewModel instance associated with this ViewState.
  late final T viewModel = createViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.isActive = true;
  }

  @override
  void dispose() {
    _disposeViewModel();
    super.dispose();
  }

  void _disposeViewModel() {
    viewModel.dispose();
    if (kDebugMode) {
      debugPrint(
        'Disposed ViewModel: ${viewModel.runtimeType}, from View: ${widget.runtimeType}',
      );
    }
  }

  /// Synchronizes ViewModel.isActive with app lifecycle state. If you need to override, be sure to call super.didChangeAppLifecycleState.
  ///
  /// Sets to `true` when resumed, `false` when inactive/hidden/paused.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        viewModel.isActive = true;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        viewModel.isActive = false;
      default:
      // Nothing to do here
    }
  }
}

abstract class _BaseState<W extends StatefulWidget> extends State<W>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) => Placeholder();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
