part of 'live_data.dart';

class _AutoDisposeFilter<D> extends LiveData<Iterable<D>> {
  final LiveData<Iterable<D>> base;
  final bool Function(D value) filter;

  @override
  Iterable<D> get value => base.value.where(filter);

  _AutoDisposeFilter(this.base, this.filter) : super([], base.scope) {
    base.addListener(_onBasedChanged);
  }

  void _onBasedChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    base.removeListener(_onBasedChanged);
    super.dispose();
  }
}
