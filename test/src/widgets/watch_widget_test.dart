import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm_kit/mvvm_kit.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

void main() {
  group('Watch Widgets', () {
    setUp(() {
      final viewModel = CounterViewModel();
      SL.I.registerFactory((_) => viewModel);
    });

    tearDown(() {
      SL.I.unregister<CounterViewModel>();
    });

    testWidgets('Watch widget displays the initial value of a LiveData', (
      tester,
    ) async {
      await tester.pumpWidget(CounterView());

      expect(find.text('Counter: 0'), findsOneWidget);
    });

    testWidgets('Watch widget rebuilds when LiveData value changes', (
      tester,
    ) async {
      await tester.pumpWidget(CounterView());

      // Initial state
      expect(find.text('Counter: 0'), findsOneWidget);

      // Changes the value
      final viewModel = SL.I.get<CounterViewModel>();
      viewModel.increment();
      await tester.pump();

      // Verifies the update
      expect(find.text('Counter: 1'), findsOneWidget);
    });

    testWidgets('GroupWatch rebuilds when any of its notifiers change', (
      tester,
    ) async {
      final viewModel = ProfileViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupWatch(
              [viewModel.name, viewModel.age],
              builder: (context) {
                return Text(
                  '${viewModel.name.value} is ${viewModel.age.value}',
                );
              },
            ),
          ),
        ),
      );

      // Initial state
      expect(find.text('John is 30'), findsOneWidget);

      // Changes the first LiveData
      viewModel.name.value = 'Jane';
      await tester.pump();
      expect(find.text('Jane is 30'), findsOneWidget);

      // Changes the second LiveData
      viewModel.age.value = 31;
      await tester.pump();
      expect(find.text('Jane is 31'), findsOneWidget);
    });

    testWidgets('WatchMixin correctly removes listener on dispose', (
      tester,
    ) async {
      final mockNotifier = MockLiveData<int>();
      when(() => mockNotifier.value).thenReturn(0);
      when(() => mockNotifier.addListener(any())).thenAnswer((_) {});
      when(() => mockNotifier.removeListener(any())).thenAnswer((_) {});

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Watch(
              mockNotifier,
              builder: (context, value) => Text('$value'),
            ),
          ),
        ),
      );

      verify(() => mockNotifier.addListener(any())).called(1);

      // Removes the widget
      await tester.pumpWidget(const SizedBox.shrink());

      verify(() => mockNotifier.removeListener(any())).called(1);
    });
  });
}
