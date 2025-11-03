import 'package:flutter/material.dart';
import 'package:mvvm_kit/src/viewmodel.dart';

abstract class ViewWidget<T extends ViewModel> extends StatefulWidget {
  final T viewModel;
  const ViewWidget({required this.viewModel, super.key});
}

abstract class ViewState<T extends ViewModel, W extends ViewWidget<T>>
    extends _BaseState<W> {
  T get viewModel => widget.viewModel;

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
    debugPrint(
      'Disposed ViewModel: ${viewModel.runtimeType}, from View: ${widget.runtimeType}',
    );
  }

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
