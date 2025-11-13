part of 'scope.dart';

class _DisposeCallback extends ChangeNotifier {
  final VoidCallback _onDispose;
  _DisposeCallback(this._onDispose);

  @override
  void dispose() {
    try {
      _onDispose();
    } finally {
      super.dispose();
    }
  }
}
