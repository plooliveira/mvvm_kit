import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm_kit/mvvm_kit.dart';

import 'mocks.dart';

void main() {
  group('ViewWidget', () {
    late CounterViewModel counterViewModel;
    late UserViewModel userViewModel;

    setUp(() {
      counterViewModel = CounterViewModel();
      userViewModel = UserViewModel();
      SL.I.registerFactory<CounterViewModel>((_) => counterViewModel);
      SL.I.registerFactory<UserViewModel>((_) => userViewModel);
    });

    tearDown(() {
      SL.I.reset();
    });

    group('onInit callback', () {
      testWidgets(
        'should call onInit with context and viewModel on initialization',
        (tester) async {
          final tracker = CallbackTracker();

          await tester.pumpWidget(TestViewWidget(tracker: tracker));

          // onInit should be called exactly once
          expect(tracker.onInitCallCount, 1);
          expect(tracker.onUpdateCallCount, 0);

          // Should receive correct context and viewModel
          expect(tracker.lastContext, isNotNull);
          expect(tracker.lastViewModel, isA<CounterViewModel>());
          expect(tracker.lastViewModel, equals(counterViewModel));
        },
      );
    });

    group('onUpdate callback', () {
      testWidgets('should call onUpdate when widget is updated', (
        tester,
      ) async {
        final tracker = CallbackTracker();

        // Initial build
        await tester.pumpWidget(
          TestViewWidget(key: const Key('test'), tracker: tracker),
        );
        expect(tracker.onInitCallCount, 1);
        expect(tracker.onUpdateCallCount, 0);

        tracker.reset();

        // Update widget (rebuild with same key)
        await tester.pumpWidget(
          TestViewWidget(key: const Key('test'), tracker: tracker),
        );

        // onUpdate should be called
        expect(tracker.onInitCallCount, 0); // onInit is not called again
        expect(tracker.onUpdateCallCount, 1);
        expect(tracker.lastContext, isNotNull);
        expect(tracker.lastViewModel, equals(counterViewModel));
      });

      testWidgets('should call onUpdate for each widget update', (
        tester,
      ) async {
        final tracker = CallbackTracker();

        await tester.pumpWidget(
          TestViewWidget(key: const Key('test'), tracker: tracker),
        );
        tracker.reset();

        // First update
        await tester.pumpWidget(
          TestViewWidget(key: const Key('test'), tracker: tracker),
        );
        expect(tracker.onUpdateCallCount, 1);

        // Second update
        await tester.pumpWidget(
          TestViewWidget(key: const Key('test'), tracker: tracker),
        );
        expect(tracker.onUpdateCallCount, 2);

        // Third update
        await tester.pumpWidget(
          TestViewWidget(key: const Key('test'), tracker: tracker),
        );
        expect(tracker.onUpdateCallCount, 3);
      });
    });

    group('resolveViewModel override', () {
      testWidgets(
        'should use custom ViewModel from resolveViewModel override',
        (tester) async {
          final customViewModel = CounterViewModel();
          customViewModel.counter.value = 42;

          await tester.pumpWidget(
            CustomResolveViewWidget(customViewModel: customViewModel),
          );

          // Should use custom ViewModel, not the one from ServiceLocator
          expect(find.text('Counter: 42'), findsOneWidget);
          expect(customViewModel.isActive, isTrue);
          expect(
            counterViewModel.isActive,
            isFalse,
          ); // ServiceLocator VM was not used
        },
      );

      testWidgets(
        'should fallback to ServiceLocator when resolveViewModel returns null',
        (tester) async {
          counterViewModel.counter.value = 99;

          await tester.pumpWidget(
            const CustomResolveViewWidget(customViewModel: null),
          );

          // Should use ViewModel from ServiceLocator
          expect(find.text('Counter: 99'), findsOneWidget);
          expect(counterViewModel.isActive, isTrue);
        },
      );
    });

    group('error handling', () {
      testWidgets(
        'should throw error when ViewModel is not registered in ServiceLocator',
        (tester) async {
          SL.I.reset();
          // Don't register CounterViewModel

          // Should throw StateError
          await tester.pumpWidget(const TestViewWidget());
          expect(tester.takeException(), isA<StateError>());
        },
      );
    });

    group('Cascade State Composition', () {
      testWidgets(
        'should create separate ViewModel instances for parent and child',
        (tester) async {
          final parentViewModel = CounterViewModel();
          final childViewModel = CounterViewModel();

          SL.I.reset();
          var callCount = 0;
          SL.I.registerFactory<CounterViewModel>((_) {
            callCount++;
            return callCount == 1 ? parentViewModel : childViewModel;
          });

          parentViewModel.counter.value = 10;
          childViewModel.counter.value = 20;

          await tester.pumpWidget(const ParentViewWidget(sharedValue: 5));

          // Should create two different instances
          expect(find.text('Parent Counter: 10'), findsOneWidget);
          expect(find.text('Child Counter: 20'), findsOneWidget);
          expect(parentViewModel.isActive, isTrue);
          expect(childViewModel.isActive, isTrue);
        },
      );

      testWidgets(
        'should pass props to child and rebuild child when props change',
        (tester) async {
          // Initial build with sharedValue = 5
          await tester.pumpWidget(const ParentViewWidget(sharedValue: 5));
          expect(find.text('Parent Value: 5'), findsOneWidget);

          // Update props
          await tester.pumpWidget(const ParentViewWidget(sharedValue: 10));
          await tester.pump();

          // Child should rebuild with new value
          expect(find.text('Parent Value: 10'), findsOneWidget);
          expect(find.text('Parent Value: 5'), findsNothing);
        },
      );

      testWidgets('should NOT rebuild parent when child state changes', (
        tester,
      ) async {
        final parentViewModel = CounterViewModel();
        final childViewModel = CounterViewModel();

        SL.I.reset();
        var callCount = 0;
        SL.I.registerFactory<CounterViewModel>((_) {
          callCount++;
          return callCount == 1 ? parentViewModel : childViewModel;
        });

        parentViewModel.counter.value = 10;
        childViewModel.counter.value = 20;

        await tester.pumpWidget(const ParentViewWidget(sharedValue: 5));

        // Change child state
        childViewModel.counter.value = 99;
        await tester.pump();

        // Parent should NOT rebuild
        expect(find.text('Parent Counter: 10'), findsOneWidget);
        // Child should update
        expect(find.text('Child Counter: 99'), findsOneWidget);
      });
    });

    group('Props integration', () {
      testWidgets('should have access to widget props in onInit and onUpdate', (
        tester,
      ) async {
        final tracker = CallbackTracker();

        // Initial build with userId = 'user1'
        await tester.pumpWidget(
          UserProfileWidget(
            key: const Key('profile'),
            userId: 'user1',
            tracker: tracker,
          ),
        );

        expect(tracker.onInitCallCount, 1);
        expect(userViewModel.userId.value, 'user1');
        expect(find.text('UserId: user1'), findsOneWidget);

        tracker.reset();

        // Update userId to 'user2' (forces didUpdateWidget)
        await tester.pumpWidget(
          UserProfileWidget(
            key: const Key('profile'),
            userId: 'user2',
            tracker: tracker,
          ),
        );
        await tester.pump();

        // onUpdate should have access to new userId
        expect(tracker.onUpdateCallCount, 1);
        expect(userViewModel.userId.value, 'user2');
        expect(find.text('UserId: user2'), findsOneWidget);
      });

      testWidgets(
        'should allow ViewModel to react to prop changes via onUpdate',
        (tester) async {
          // Initial build
          await tester.pumpWidget(
            const UserProfileWidget(key: Key('profile'), userId: 'user1'),
          );

          expect(userViewModel.reloadCount, 1);
          expect(find.text('Data: User data for user1'), findsOneWidget);

          // Update with SAME userId
          await tester.pumpWidget(
            const UserProfileWidget(key: Key('profile'), userId: 'user1'),
          );
          await tester.pump();

          // ViewModel should NOT reload (same prop)
          expect(userViewModel.reloadCount, 1);

          // Update with NEW userId
          await tester.pumpWidget(
            const UserProfileWidget(key: Key('profile'), userId: 'user2'),
          );
          await tester.pump();

          // ViewModel SHOULD reload (prop changed)
          expect(userViewModel.reloadCount, 2);
          expect(find.text('Data: User data for user2'), findsOneWidget);
        },
      );
    });

    group('build method', () {
      testWidgets('should pass correct viewModel to build method', (
        tester,
      ) async {
        counterViewModel.counter.value = 123;

        await tester.pumpWidget(const TestViewWidget());

        // Build should receive correct ViewModel
        expect(find.text('Counter: 123'), findsOneWidget);
        expect(find.text('ViewModel Active: true'), findsOneWidget);
      });

      testWidgets('should rebuild when LiveData changes', (tester) async {
        await tester.pumpWidget(const TestViewWidget());

        expect(find.text('Counter: 0'), findsOneWidget);

        // Change LiveData
        counterViewModel.counter.value = 42;
        await tester.pump();

        // Should rebuild
        expect(find.text('Counter: 42'), findsOneWidget);
      });
    });

    group('edge cases', () {
      testWidgets('should handle rapid updates', (tester) async {
        final tracker = CallbackTracker();

        await tester.pumpWidget(
          UserProfileWidget(
            key: const Key('profile'),
            userId: 'user1',
            tracker: tracker,
          ),
        );
        tracker.reset();

        // Multiple rapid updates
        for (var i = 2; i <= 10; i++) {
          await tester.pumpWidget(
            UserProfileWidget(
              key: const Key('profile'),
              userId: 'user$i',
              tracker: tracker,
            ),
          );
        }
        await tester.pump();

        // All updates should be processed
        expect(tracker.onUpdateCallCount, 9);
        expect(userViewModel.userId.value, 'user10');
      });
    });

    group('lifecycle integration', () {
      testWidgets('should initialize ViewModel and set isActive to true', (
        tester,
      ) async {
        await tester.pumpWidget(const TestViewWidget());

        expect(counterViewModel.isActive, isTrue);
        expect(find.text('ViewModel Active: true'), findsOneWidget);
      });

      testWidgets('should dispose ViewModel when widget is disposed', (
        tester,
      ) async {
        // Use a custom ViewModel that tracks dispose
        final testViewModel = TrackableCounterViewModel();

        SL.I.reset();
        SL.I.registerFactory<CounterViewModel>((_) => testViewModel);

        await tester.pumpWidget(const TestViewWidget());
        expect(testViewModel.isActive, isTrue);
        expect(testViewModel.disposeCallCount, 0);

        // Dispose widget
        await tester.pumpWidget(Container());

        // Verify dispose was called exactly once
        expect(testViewModel.disposeCallCount, 1);
      });
    });
  });
}
