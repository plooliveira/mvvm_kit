import 'package:example_playground/view/counter/counter_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm_kit/mvvm_kit.dart';

class CounterCascadeRoute extends GoRoute {
  CounterCascadeRoute()
    : super(
        path: '/counter-cascade',
        name: 'counter-cascade',
        builder: (context, state) => ParentCounter(),
      );
}

class ParentCounter extends ViewWidget<CounterViewModel> {
  const ParentCounter({super.key});

  @override
  Widget build(BuildContext context, CounterViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(),
      body: Watch(
        viewModel.counter,
        builder: (context, counter) => ChildCounter(parentCounter: counter),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: _Fab(
          text: "Parent prop",
          width: 160,
          onPressed: viewModel.increment,
        ),
      ),
    );
  }
}

class ChildCounter extends ViewWidget<CounterViewModel> {
  const ChildCounter({super.key, required this.parentCounter});
  final int parentCounter;

  @override
  Widget build(BuildContext context, CounterViewModel viewModel) => Scaffold(
    body: Watch(
      viewModel.counter,
      builder: (context, counter) => Center(
        child: Text("""
Parent: $parentCounter
Child: $counter
      """),
      ),
    ),
    floatingActionButton: _Fab(text: "Child", onPressed: viewModel.increment),
  );
}

class _Fab extends StatelessWidget {
  const _Fab({required this.text, required this.onPressed, this.width});
  final String text;
  final VoidCallback onPressed;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 120,
      height: 50,
      child: FilledButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.add), Text(text)],
        ),
      ),
    );
  }
}
