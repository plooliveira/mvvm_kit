import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mvvm_kit/mvvm_kit.dart';

/// A [ViewWidget] is a simplified version of a [StatefulWidget] + [ViewState].
/// It is a generic class that takes a [ViewModel] as a type parameter.
/// By default, it uses the built-in service locator to resolve the [ViewModel].
/// You can register your [ViewModel] in the service locator before running the app:
///
/// ```dart
/// void setupLocator() {
///   SL.I.registerFactory(() => CounterViewModel());
/// }
/// ```
///
/// You can override the [resolveViewModel] method to inject a [ViewModel].
/// This is useful for testing.
///
/// ### Cascade State Composition (CSC)
///
/// ViewWidget enables Cascade State Composition where each widget maintains
/// its own isolated ViewModel while cascading state changes to children
/// through reactive constructor injection.
///
/// #### How it works:
/// - Parent manages its own state via ViewModel
/// - Parent injects data into children via constructor
/// - Children receive injected data and manage their own state
/// - State changes cascade down but never up
/// ```dart
/// // Each level can:
/// // 1. Modify its own state
/// // 2. Inject data into child (influencing child's UI)
///
/// Parent
///   ├─ Own State: ParentViewModel
///   └─ Injects into child: parentData
///        ↓
///      Child
///        ├─ Own State: ChildViewModel
///        ├─ Receives from parent: parentData
///        └─ Injects into child: childData
///             ↓
///           GrandChild
///             ├─ Own State: GrandChildViewModel
///             └─ Receives from parent: childData
/// ```
abstract class ViewWidget<T extends ViewModel> extends StatefulWidget {
  const ViewWidget({super.key});

  /// Override this method to provide a custom [ViewModel] instance.
  /// By default, it retrieves the [ViewModel] from the service locator.
  /// Override this method to provide a custom [ViewModel] instance using a different method. e.g. GetIt, Provider, Constructor injection etc.
  T? resolveViewModel() => null;

  /// Override this method to provide a [Widget] to be built.
  /// ```dart
  /// class UserProfile extends ViewWidget<UserProfileViewModel> {
  ///   final String userId;
  /// @override
  ///   void onInit(BuildContext context, UserProfileViewModel vm) {
  ///     vm.setUserId(userId);
  ///   }
  /// ...
  /// }
  /// ```
  Widget build(BuildContext context, T viewModel);

  /// Override this method to provide a custom [onInit] callback.
  void onInit(BuildContext context, T viewModel) {}

  /// Override this method to react to widget updates.
  ///
  /// Called whenever the widget configuration changes. Use this to pass
  /// updated props to the ViewModel. The ViewModel should contain the logic
  /// to determine if any action is needed.
  ///
  /// Example:
  /// ```dart
  /// class UserProfile extends ViewWidget<UserProfileViewModel> {
  ///   final String userId;
  ///
  ///   @override
  ///   void onUpdate(BuildContext context, UserProfileViewModel vm) {
  ///     vm.setUserId(userId); // ViewModel decides if reload is needed
  ///   }
  /// ...
  /// }
  /// ```
  void onUpdate(BuildContext context, T viewModel) {}

  @protected
  @nonVirtual
  @override
  ViewState<T, ViewWidget<T>> createState() =>
      _ViewWidgetAdapter<T, ViewWidget<T>>();
}

class _ViewWidgetAdapter<V extends ViewModel, W extends ViewWidget<V>>
    extends ViewState<V, W> {
  @override
  V resolveViewModel() {
    return widget.resolveViewModel() ?? super.resolveViewModel();
  }

  @override
  void initState() {
    super.initState();
    widget.onInit(context, viewModel);
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    widget.onUpdate(context, viewModel);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.build(context, viewModel);
  }
}
