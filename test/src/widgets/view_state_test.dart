import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvvm_kit/mvvm_kit.dart';

import 'mocks.dart';

void main() {
  group('ViewState', () {
    late CounterViewModel viewModel;

    setUp(() {
      viewModel = CounterViewModel();
      SL.I.registerFactory<CounterViewModel>((_) => viewModel);
    });

    tearDown(() {
      SL.I.reset();
    });

    testWidgets('should resolve ViewModel from SL and initialize it', (
      tester,
    ) async {
      await tester.pumpWidget(const CounterView());

      expect(find.text('ViewModel Active: true'), findsOneWidget);
      expect(viewModel.isActive, isTrue);
    });

    testWidgets('should dispose ViewModel when widget is disposed', (
      tester,
    ) async {
      final mockViewModel = MockCounterViewModel();
      when(() => mockViewModel.counter).thenReturn(MutableLiveData(0));
      when(() => mockViewModel.dispose()).thenReturn(null);
      when(() => mockViewModel.isActive).thenReturn(true);
      when(() => mockViewModel.isActive = true).thenReturn(true);
      when(() => mockViewModel.isActive = false).thenReturn(true);

      SL.I.reset();
      SL.I.registerFactory<CounterViewModel>((_) => mockViewModel);

      await tester.pumpWidget(const CounterView());

      // Dispose widget
      await tester.pumpWidget(Container());

      verify(() => mockViewModel.dispose()).called(1);
    });

    testWidgets('should update isActive on AppLifecycleState changes', (
      tester,
    ) async {
      await tester.pumpWidget(const CounterView());

      expect(viewModel.isActive, isTrue);
      expect(find.text('ViewModel Active: true'), findsOneWidget);

      // Simulate background
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(viewModel.isActive, isFalse);

      // Simulate foreground
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(viewModel.isActive, isTrue);

      // Simulate hidden
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump();
      expect(viewModel.isActive, isFalse);

      // Simulate back to foreground
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(viewModel.isActive, isTrue);

      // Simulate inactive
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(viewModel.isActive, isFalse);

      // Simulate detached (covers default case)
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.detached);
      await tester.pump();
      // Should maintain previous state (false) as default block does nothing
      expect(viewModel.isActive, isFalse);
    });

    testWidgets('should rebuild when ViewModel notifies listeners', (
      tester,
    ) async {
      await tester.pumpWidget(const CounterView());

      // Initial state
      expect(find.text('ViewModel Active: true'), findsOneWidget);

      // Trigger a notification from ViewModel
      viewModel.notifyListeners();
      await tester.pump();

      // Should still be active and widget should have rebuilt
      expect(find.text('ViewModel Active: true'), findsOneWidget);
    });

    testWidgets('should batch multiple notifications via scheduleMicrotask', (
      tester,
    ) async {
      int buildCount = 0;
      final trackingViewModel = TrackingViewModel();
      SL.I.reset();
      SL.I.registerFactory<TrackingViewModel>((_) => trackingViewModel);

      await tester.pumpWidget(const TrackingView());

      // Get initial build count
      final state = tester.state<TrackingViewState>(find.byType(TrackingView));
      buildCount = state.buildCount;

      // Trigger multiple notifications synchronously
      trackingViewModel.notifyListeners();
      trackingViewModel.notifyListeners();
      trackingViewModel.notifyListeners();

      // Pump to execute microtasks
      await tester.pump();

      // Should only rebuild once due to batching
      expect(state.buildCount, buildCount + 1);
    });

    testWidgets('should not call setState if widget is not mounted', (
      tester,
    ) async {
      // Use a custom ViewModel that we can control
      final customViewModel = CounterViewModel();
      SL.I.reset();
      SL.I.registerFactory<CounterViewModel>((_) => customViewModel);

      await tester.pumpWidget(const CounterView());

      // Schedule a notification during the disposal process
      // This tests the mounted check in _onNotifierChanged
      customViewModel.notifyListeners();

      // Dispose the widget - the scheduled microtask should check mounted
      await tester.pumpWidget(Container());

      // Pump to execute any pending microtasks
      // The _onNotifierChanged should not call setState because mounted is false
      await tester.pump();

      // If we got here without errors, the mounted check worked
      expect(true, isTrue);
    });
  });
}
