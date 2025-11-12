import 'package:flutter_test/flutter_test.dart';
import '../../lib/mvvm_kit.dart';

// Test implementation of ViewModel
class TestViewModel extends ViewModel {
  int onActiveCallCount = 0;
  int onInactiveCallCount = 0;

  @override
  void onActive() {
    super.onActive();
    onActiveCallCount++;
  }

  @override
  void onInactive() {
    super.onInactive();
    onInactiveCallCount++;
  }
}

// Helper class to track disposal order
class TrackingLiveData extends MutableLiveData<int> {
  final List<String> disposalOrder;
  final String name;

  TrackingLiveData(super.value, this.name, this.disposalOrder);

  @override
  void dispose() {
    disposalOrder.add(name);
    super.dispose();
  }
}

void main() {
  group('ViewModel - Lifecycle Management', () {
    late TestViewModel viewModel;

    setUp(() {
      viewModel = TestViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('should start with isActive = false', () {
      expect(viewModel.isActive, false);
    });

    test('setting isActive to true should trigger onActive', () {
      expect(viewModel.onActiveCallCount, 0);

      viewModel.isActive = true;

      expect(viewModel.isActive, true);
      expect(viewModel.onActiveCallCount, 1);
      expect(viewModel.onInactiveCallCount, 0);
    });

    test('setting isActive to false should trigger onInactive', () {
      viewModel.isActive = true;
      expect(viewModel.onInactiveCallCount, 0);

      viewModel.isActive = false;

      expect(viewModel.isActive, false);
      expect(viewModel.onInactiveCallCount, 1);
    });

    test('setting same isActive value should not trigger callbacks', () {
      viewModel.isActive = true;
      final activeCount = viewModel.onActiveCallCount;

      viewModel.isActive = true;

      expect(viewModel.onActiveCallCount, activeCount);
    });

    test('ensureActive should wait until isActive becomes true', () async {
      expect(viewModel.isActive, false);

      bool completed = false;
      final future = viewModel.ensureActive().then((_) => completed = true);

      // Micro delay to allow event loop to process
      await Future.microtask(() {});
      expect(completed, false, reason: 'Should still be waiting');

      // Now activate it
      viewModel.isActive = true;

      await future;
      expect(completed, true);
    });

    test('ensureActive should return immediately if already active', () async {
      viewModel.isActive = true;

      final stopwatch = Stopwatch()..start();
      await viewModel.ensureActive();
      stopwatch.stop();

      // Should complete almost instantly (< 100ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('lifecycle transitions should work correctly', () {
      expect(viewModel.isActive, false);

      viewModel.isActive = true;
      expect(viewModel.onActiveCallCount, 1);
      expect(viewModel.onInactiveCallCount, 0);

      viewModel.isActive = false;
      expect(viewModel.onActiveCallCount, 1);
      expect(viewModel.onInactiveCallCount, 1);

      viewModel.isActive = true;
      expect(viewModel.onActiveCallCount, 2);
      expect(viewModel.onInactiveCallCount, 1);
    });
  });

  group('ViewModel - Data Management', () {
    late TestViewModel viewModel;

    setUp(() {
      viewModel = TestViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('mutable should create MutableLiveData with initial value', () {
      final counter = viewModel.mutable<int>(42);

      expect(counter, isA<MutableLiveData<int>>());
      expect(counter.value, 42);
    });

    test('mutable should add LiveData to dataScope', () {
      final initialCount = viewModel.scope.items.length;

      final counter = viewModel.mutable<int>(0);
      expect(viewModel.scope.items.contains(counter), true);
      expect(viewModel.scope.items.length, initialCount + 1);
    });

    test('mutable LiveData should be mutable', () {
      final counter = viewModel.mutable<int>(0);

      counter.value = 10;

      expect(counter.value, 10);
    });

    test('should allow creating multiple mutable LiveData', () {
      final initialCount = viewModel.scope.items.length;

      final counter1 = viewModel.mutable<int>(1);
      final counter2 = viewModel.mutable<int>(2);
      final name = viewModel.mutable<String>('test');

      expect(counter1.value, 1);
      expect(counter2.value, 2);
      expect(name.value, 'test');
      expect(viewModel.scope.items.length, initialCount + 3);
    });

    test('register should add existing LiveData to dataScope', () {
      final existingData = MutableLiveData<String>('hello');
      final initialCount = viewModel.scope.items.length;

      viewModel.register(existingData);

      expect(viewModel.scope.items.contains(existingData), true);
      expect(viewModel.scope.items.length, initialCount + 1);
    });

    test('register should return the same LiveData instance', () {
      final existingData = MutableLiveData<String>('hello');

      final returned = viewModel.register(existingData);

      expect(identical(returned, existingData), true);
      expect(viewModel.scope.items.contains(existingData), true);
    });

    test('register should work with transformations', () {
      final source = MutableLiveData<int>(10);
      final transformed = source.transform<int>((data) => data.value * 2);

      viewModel.register(transformed);

      expect(transformed.value, 20);
      expect(viewModel.scope.items.contains(transformed), true);
    });

    test('should allow multiple register calls', () {
      final initialCount = viewModel.scope.items.length;
      final data1 = MutableLiveData<int>(1);
      final data2 = MutableLiveData<int>(2);

      viewModel.register(data1);
      viewModel.register(data2);

      expect(viewModel.scope.items.contains(data1), true);
      expect(viewModel.scope.items.contains(data2), true);
      expect(viewModel.scope.items.length, initialCount + 2);
    });

    test('mutable and register can be combined', () {
      final initialCount = viewModel.scope.items.length;
      final mutableData = viewModel.mutable<int>(1);
      final existingData = MutableLiveData<int>(2);
      viewModel.register(existingData);

      expect(viewModel.scope.items.contains(mutableData), true);
      expect(viewModel.scope.items.contains(existingData), true);
      expect(viewModel.scope.items.length, initialCount + 2);
    });
  });

  group('ViewModel - Loading Management', () {
    late TestViewModel viewModel;

    setUp(() {
      viewModel = TestViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('isLoading should start as false', () {
      expect(viewModel.isLoading.value, false);
    });

    test('isLoading should be a LiveData<bool>', () {
      expect(viewModel.isLoading, isA<LiveData<bool>>());
    });

    test('beginLoading should set isLoading to true', () {
      expect(viewModel.isLoading.value, false);

      viewModel.beginLoading();

      expect(viewModel.isLoading.value, true);
    });

    test('completeLoading should set isLoading to false', () {
      viewModel.beginLoading();
      expect(viewModel.isLoading.value, true);

      viewModel.completeLoading();

      expect(viewModel.isLoading.value, false);
    });

    test('isLoading should notify listeners on change', () {
      int notifyCount = 0;
      void listener() => notifyCount++;

      viewModel.isLoading.addListener(listener);

      viewModel.beginLoading();
      expect(notifyCount, 1);

      viewModel.completeLoading();
      expect(notifyCount, 2);
      viewModel.isLoading.removeListener(listener);
    });

    test('isLoading should be managed by dataScope', () {
      expect(viewModel.scope.items.contains(viewModel.isLoading), true);
    });
  });

  group('ViewModel - Dispose & Resource Management', () {
    test('dispose should dispose all items in dataScope', () {
      final viewModel = TestViewModel();

      // Create various types of LiveData
      final counter1 = viewModel.mutable<int>(1);
      final counter2 = viewModel.mutable<int>(2);
      final data1 = MutableLiveData<int>(10);
      final data2 = MutableLiveData<String>('test');

      viewModel.register(data1);
      viewModel.register(data2);

      final isLoading = viewModel.isLoading;

      // Verify all are not disposed
      expect(counter1.isDisposed, false);
      expect(counter2.isDisposed, false);
      expect(data1.isDisposed, false);
      expect(data2.isDisposed, false);
      expect(isLoading.isDisposed, false);
      expect(viewModel.scope.items.isNotEmpty, true);

      viewModel.dispose();

      // Verify all items in dataScope were disposed
      expect(counter1.isDisposed, true);
      expect(counter2.isDisposed, true);
      expect(data1.isDisposed, true);
      expect(data2.isDisposed, true);
      expect(isLoading.isDisposed, true);
      expect(viewModel.scope.items.isEmpty, true);
    });

    test('DataScope disposes items in reverse order (LIFO)', () {
      final viewModel = TestViewModel();
      final disposalOrder = <String>[];

      // Create tracking LiveData instances
      final data1 = TrackingLiveData(1, 'data1', disposalOrder);
      final data2 = TrackingLiveData(2, 'data2', disposalOrder);
      final data3 = TrackingLiveData(3, 'data3', disposalOrder);

      // Register them to the ViewModel's dataScope
      viewModel.register(data1);
      viewModel.register(data2);
      viewModel.register(data3);

      viewModel.dispose();

      // Should dispose in reverse order: data3, data2, data1, isLoading
      // We only check the ones we registered
      expect(disposalOrder, ['data3', 'data2', 'data1']);
      expect(viewModel.scope.items.isEmpty, true);
    });

    test('multiple dispose calls should throw FlutterError', () {
      final viewModel = TestViewModel();

      viewModel.dispose();

      // ChangeNotifier throws when disposed twice
      expect(() => viewModel.dispose(), throwsFlutterError);
    });
  });

  group('ViewModel - Integration Tests', () {
    test('typical use case: create, modify, dispose', () {
      final viewModel = TestViewModel();

      // Create state
      final counter = viewModel.mutable<int>(0);
      expect(counter.value, 0);

      // Modify state
      counter.value = 10;
      expect(counter.value, 10);

      // Start loading
      viewModel.beginLoading();
      expect(viewModel.isLoading.value, true);

      // Finish loading
      viewModel.completeLoading();
      expect(viewModel.isLoading.value, false);

      // Dispose
      viewModel.dispose();
      expect(counter.isDisposed, true);
      expect(viewModel.isLoading.isDisposed, true);
    });

    test('lifecycle with data management', () {
      final viewModel = TestViewModel();
      final counter = viewModel.mutable<int>(0);

      expect(viewModel.isActive, false);

      viewModel.isActive = true;
      expect(viewModel.onActiveCallCount, 1);

      counter.value = 5;
      expect(counter.value, 5);

      viewModel.isActive = false;
      expect(viewModel.onInactiveCallCount, 1);

      viewModel.dispose();
      expect(counter.isDisposed, true);
    });

    test('ensureActive with data creation', () async {
      final viewModel = TestViewModel();

      // Start waiting for activation
      bool completed = false;
      final future = viewModel.ensureActive().then((_) => completed = true);

      // Micro delay to allow event loop to process
      await Future.microtask(() {});
      expect(completed, false, reason: 'Should be waiting for activation');

      // Activate and create data
      viewModel.isActive = true;
      await future;

      final counter = viewModel.mutable<int>(42);
      expect(counter.value, 42);

      viewModel.dispose();
    });
  });
}
