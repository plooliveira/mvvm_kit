import 'package:flutter/material.dart';
import 'package:mvvm_kit/src/live_data/live_data.dart';

class Watch<T> extends StatefulWidget {
  const Watch(this.notifier, {required this.builder, super.key});

  final LiveData<T> notifier;
  final Widget Function(BuildContext, T) builder;
  @override
  State createState() => _WatchState<T>();
}

class _WatchState<T> extends State<Watch<T>> with WatchMixin {
  @override
  List<LiveData<T>> get _notifiers => [widget.notifier];

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, widget.notifier.value);
}

class GroupWatch extends StatefulWidget {
  final List<LiveData> notifiers;
  final Widget Function(BuildContext) builder;

  GroupWatch(this.notifiers, {required this.builder, Key? key})
    : super(key: key ?? ValueKey(notifiers));

  @override
  State createState() => _GroupWatchState();
}

class _GroupWatchState extends State<GroupWatch> with WatchMixin {
  @override
  List<LiveData> get _notifiers => widget.notifiers;

  @override
  Widget build(BuildContext context) => widget.builder(context);
}

mixin WatchMixin<T extends StatefulWidget> on State<T> {
  List<LiveData> get _notifiers;

  @override
  void initState() {
    super.initState();
    for (final notifier in _notifiers) {
      notifier.addListener(_onNotifierChanged);
    }
  }

  @override
  void dispose() {
    for (final notifier in _notifiers) {
      notifier.removeListener(_onNotifierChanged);
    }
    super.dispose();
  }

  void _onNotifierChanged() {
    setState(() {});
  }
}
