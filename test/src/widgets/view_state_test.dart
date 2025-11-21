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
  });
}
