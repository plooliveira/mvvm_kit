import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';

import 'package:mvvm_kit/mvvm_kit.dart';

// Mocks for testing
class MockChangeNotifier extends ChangeNotifier {
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

class MockDataScope extends DataScope {
  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }
}

// A custom LiveData to test the initial null scenario
class NullableInitialLiveData<T> extends LiveData<T?> {
  T? _value;
  @override
  T? get value => _value;

  NullableInitialLiveData() : super(null); // Explicitly pass null to super

  void updateValue(T newValue) {
    _value = newValue;
    notifyIfChanged();
  }
}

void main() {
  group('LiveData Core Functionality', () {
    test(
      'subscribe should add a callback and immediately call it with the current value',
      () {
        final liveData = MutableLiveData(10);
        int? receivedValue;
        int callCount = 0;

        liveData.subscribe((value) {
          receivedValue = value;
          callCount++;
        });

        expect(receivedValue, 10); // Immediately called
        expect(callCount, 1);
        expect(liveData.subscribers.length, 1);
      },
    );

    test('subscribe should not add the same callback instance twice', () {
      final liveData = MutableLiveData(10);
      void callback(int value) {}

      liveData.subscribe(callback);
      liveData.subscribe(callback);

      expect(liveData.subscribers.length, 1);
    });

    test('unsubscribe should remove a callback', () {
      final liveData = MutableLiveData(10);
      int callCount = 0;
      int callback(int value) => callCount++;

      liveData.subscribe(callback);
      expect(callCount, 1); // Initial call

      liveData.value = 20;
      expect(callCount, 2); // Notified on change

      liveData.unsubscribe(callback);
      liveData.value = 30;
      expect(callCount, 2); // Should not be called after unsubscribe
    });

    test('notifyListeners should notify all subscribers', () {
      final liveData = MutableLiveData(10);
      int callCount1 = 0;
      int callCount2 = 0;

      liveData.subscribe((value) => callCount1++);
      liveData.subscribe((value) => callCount2++);

      expect(callCount1, 1);
      expect(callCount2, 1);

      liveData.reload(); // Force notify

      expect(callCount1, 2);
      expect(callCount2, 2);
    });

    test('notifyListeners should be safe from concurrent modification', () {
      final liveData = MutableLiveData(10);
      void callback(int value) {}

      liveData.subscribe((value) {
        liveData.unsubscribe(callback); // Unsubscribe another while iterating
      });
      liveData.subscribe(callback);

      // Should not throw ConcurrentModificationError thanks to .toList()
      expect(() => liveData.reload(), returnsNormally);
    });

    test('notifyIfChanged should NOT notify if value is same as initial', () {
      final liveData = MutableLiveData(10);
      int callCount = 0;
      liveData.subscribe((value) => callCount++);
      expect(callCount, 1); // Initial call

      liveData.notifyIfChanged(); // Value is 10, _lastNotifyCheck is 10

      expect(callCount, 1); // Should not be called again
    });

    test('notifyIfChanged should notify when value changes from null', () {
      final liveData =
          NullableInitialLiveData<int>(); // _lastNotifyCheck is null
      int? receivedValue;
      int callCount = 0;
      liveData.subscribe((value) {
        receivedValue = value;
        callCount++;
      });

      expect(callCount, 1); // Called with initial null
      expect(receivedValue, isNull);

      liveData.updateValue(10);

      expect(callCount, 2); // Should be called again
      expect(receivedValue, 10);
    });
  });

  group('MutableLiveData Functionality', () {
    test('setting a new value should notify listeners', () {
      final liveData = MutableLiveData(10);
      int? receivedValue;
      int callCount = 0;
      liveData.subscribe((value) {
        receivedValue = value;
        callCount++;
      });

      expect(callCount, 1); // Initial call

      liveData.value = 20;

      expect(receivedValue, 20);
      expect(callCount, 2);
    });

    test('setting the same value should not notify listeners by default', () {
      final liveData = MutableLiveData(10);
      int callCount = 0;
      liveData.subscribe((value) => callCount++);

      expect(callCount, 1); // Initial call

      liveData.value = 10; // Same value

      expect(callCount, 1); // Should not be called again
    });

    test(
      'when emitAll is true, setting the same value should always notify listeners',
      () {
        final liveData = MutableLiveData(10, true);
        int callCount = 0;
        liveData.subscribe((value) => callCount++);

        expect(callCount, 1); // Initial call

        liveData.value = 10; // Same value

        expect(callCount, 2); // Should be called again because emitAll is true
      },
    );

    test('editValue should always notify listeners', () {
      final liveData = MutableLiveData([1, 2, 3]);
      int callCount = 0;
      liveData.subscribe((value) => callCount++);

      expect(callCount, 1); // Initial call

      liveData.update((list) {
        list.add(4);
      });

      expect(callCount, 2); // Should be notified
      expect(liveData.value, [1, 2, 3, 4]);
    });
  });

  group('_defaultChangeDetector Behavior (tested via MutableLiveData)', () {
    test('should notify for different primitive values', () {
      final liveData = MutableLiveData<int>(10);
      int callCount = 0;
      liveData.subscribe((_) => callCount++);
      liveData.value = 20;
      expect(callCount, 2);
    });

    test('should not notify for same primitive values', () {
      final liveData = MutableLiveData<int>(10);
      int callCount = 0;
      liveData.subscribe((_) => callCount++);
      liveData.value = 10;
      expect(callCount, 1);
    });

    // List tests
    test('should notify for lists of different sizes', () {
      final liveData = MutableLiveData([1, 2]);
      int callCount = 0;
      liveData.subscribe((_) => callCount++);
      liveData.value = [1, 2, 3];
      expect(callCount, 2);
    });

    test('should notify for lists with same size but different content', () {
      final liveData = MutableLiveData([1, 2, 3]);
      int callCount = 0;
      liveData.subscribe((_) => callCount++);
      liveData.value = [1, 0, 3]; // Changed content
      expect(callCount, 2);
    });

    test('should not notify for lists with same size and content', () {
      final liveData = MutableLiveData([1, 2, 3]);
      int callCount = 0;
      liveData.subscribe((_) => callCount++);
      liveData.value = [1, 2, 3]; // Same content
      expect(callCount, 1);
    });

    // Map tests
    test('should notify for maps of different sizes', () {
      final liveData = MutableLiveData({'a': 1});
      int callCount = 0;
      liveData.subscribe((_) => callCount++);
      liveData.value = {'a': 1, 'b': 2};
      expect(callCount, 2);
    });

    test('should notify for maps with different keys', () {
      final liveData = MutableLiveData({'a': 1, 'b': 2});
      int callCount = 0;
      liveData.subscribe((_) => callCount++);
      liveData.value = {'a': 1, 'c': 2}; // Different key
      expect(callCount, 2);
    });

    test('should notify for maps with different values', () {
      final liveData = MutableLiveData({'a': 1, 'b': 2});
      int callCount = 0;
      liveData.subscribe((_) => callCount++);
      liveData.value = {'a': 1, 'b': 3}; // Different value
      expect(callCount, 2);
    });

    test('should not notify for maps with same keys and values', () {
      final liveData = MutableLiveData({'a': 1, 'b': 2});
      int callCount = 0;
      liveData.subscribe((_) => callCount++);
      liveData.value = {'a': 1, 'b': 2}; // Same map
      expect(callCount, 1);
    });
  });

  group('LiveData Extensions', () {
    group('ListLiveData', () {
      test('proxy properties should reflect the underlying list value', () {
        final liveData = MutableLiveData([1, 2, 3]);
        expect(liveData.isEmpty, isFalse);
        expect(liveData.isNotEmpty, isTrue);
        expect(liveData.length, 3);

        liveData.value = [];
        expect(liveData.isEmpty, isTrue);
        expect(liveData.isNotEmpty, isFalse);
        expect(liveData.length, 0);
      });

      test('proxy methods should work on the underlying list value', () {
        final liveData = MutableLiveData([1, 2, 3]);

        final mapped = liveData.map((i) => i * 2).toList();
        expect(mapped, [2, 4, 6]);

        int sum = 0;
        liveData.forEach(
          (dynamic i) => sum += i as int,
        ); // Workaround for type issue
        expect(sum, 6);
      });

      test('filtered should create a LiveData that filters items', () {
        final source = MutableLiveData([1, 2, 3, 4, 5]);
        final filtered = source.filtered((i) => i.isEven);

        List<int>? receivedValue;
        filtered.subscribe((value) {
          receivedValue = List<int>.from(value); // Workaround for type issue
        });

        // Check initial value
        expect(receivedValue, [2, 4]);

        // Update source and check if filtered LiveData updates
        source.value = [1, 2, 3, 4, 5, 6, 7, 8];
        expect(receivedValue, [2, 4, 6, 8]);
      });

      test('notNull should create a LiveData that filters out nulls', () {
        final source = MutableLiveData<List<int?>>([1, null, 3, null, 5]);
        final notNullFiltered = source.notNull();

        List<int?>? receivedValue;
        notNullFiltered.subscribe((value) {
          receivedValue = value.toList();
        });

        // Check initial value
        expect(receivedValue, [1, 3, 5]);

        // Update source and check if filtered LiveData updates
        source.value = [null, 2, 3, 4, null, 6];
        expect(receivedValue, [2, 3, 4, 6]);
      });
    });
  });

  group('LiveData Scope Management', () {
    test(
      'transformed LiveData without explicit scope should be disposed when source with scope is disposed',
      () {
        final scope = DataScope();
        final source = MutableLiveData(10, false, scope);
        final transformed = source.transform((data) => data.value * 2, null);

        expect(source.isDisposed, isFalse);
        expect(transformed.isDisposed, isFalse);
        expect(transformed.value, 20);

        source.dispose();

        expect(source.isDisposed, isTrue);
        expect(transformed.isDisposed, isTrue);
      },
    );
  });
}
