import 'package:flutter/material.dart';

class Watch extends GroupWatch {
  Watch(ChangeNotifier notifier, {required super.builder, super.key})
    : super([notifier]);

  @override
  State createState() => _WatchState();
}

class GroupWatch extends StatefulWidget {
  final List<ChangeNotifier> notifiers;
  final Widget Function(BuildContext) builder;

  GroupWatch(this.notifiers, {required this.builder, Key? key})
    : super(key: key ?? ValueKey(notifiers));

  @override
  State createState() => _WatchState();
}

class _WatchState extends State<GroupWatch> {
  @override
  void initState() {
    super.initState();
    for (var notifier in widget.notifiers) {
      notifier.addListener(_onNotified);
    }
  }

  @override
  void didUpdateWidget(covariant GroupWatch oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (var notifier in oldWidget.notifiers) {
      notifier.removeListener(_onNotified);
    }
    for (var notifier in widget.notifiers) {
      notifier.addListener(_onNotified);
    }
  }

  @override
  void dispose() {
    for (var notifier in widget.notifiers) {
      notifier.removeListener(_onNotified);
    }
    super.dispose();
  }

  void _onNotified() => setState(() {});

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
