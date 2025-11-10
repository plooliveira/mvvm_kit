import 'dart:async';

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

  group('LiveData Factory Methods', () {
    group('fromValueNotifier', () {
      test('should create LiveData from ValueNotifier', () {
        final notifier = ValueNotifier<int>(10);
        final liveData = LiveData.fromValueNotifier(notifier);

        expect(liveData.value, 10);
        expect(liveData.isDisposed, isFalse);
      });

      test('should update when ValueNotifier changes', () {
        final notifier = ValueNotifier<int>(10);
        final liveData = LiveData.fromValueNotifier(notifier);

        int? receivedValue;
        int callCount = 0;
        liveData.subscribe((value) {
          receivedValue = value;
          callCount++;
        });

        expect(receivedValue, 10);
        expect(callCount, 1);

        notifier.value = 20;
        expect(receivedValue, 20);
        expect(callCount, 2);

        notifier.value = 30;
        expect(receivedValue, 30);
        expect(callCount, 3);
      });

      test('should be disposed when registered in scope', () {
        final scope = DataScope();
        final notifier = ValueNotifier<int>(10);
        final liveData = LiveData.fromValueNotifier(notifier, scope);

        expect(liveData.isDisposed, isFalse);

        scope.dispose();

        expect(liveData.isDisposed, isTrue);
      });

      test('should remove listener from ValueNotifier when disposed', () {
        final notifier = ValueNotifier<int>(10);
        final liveData = LiveData.fromValueNotifier(notifier);

        expect(notifier.hasListeners, isTrue);

        liveData.dispose();

        expect(notifier.hasListeners, isFalse);
      });

      test('should work with different types', () {
        final stringNotifier = ValueNotifier<String>('hello');
        final stringData = LiveData.fromValueNotifier(stringNotifier);

        expect(stringData.value, 'hello');

        stringNotifier.value = 'world';
        expect(stringData.value, 'world');
      });
    });

    group('fromStream', () {
      test('should create LiveData from Stream with initial value', () {
        final controller = StreamController<int>();
        final liveData = LiveData.fromStream(controller.stream, 0);

        expect(liveData.value, 0);
        expect(liveData.isDisposed, isFalse);

        controller.close();
        liveData.dispose();
      });

      test('should update when Stream emits values', () async {
        final controller = StreamController<int>();
        final liveData = LiveData.fromStream(controller.stream, 0);

        int? receivedValue;
        int callCount = 0;
        liveData.subscribe((value) {
          receivedValue = value;
          callCount++;
        });

        expect(receivedValue, 0);
        expect(callCount, 1);

        controller.add(10);
        await Future.delayed(Duration(milliseconds: 10));
        expect(receivedValue, 10);
        expect(callCount, 2);

        controller.add(20);
        await Future.delayed(Duration(milliseconds: 10));
        expect(receivedValue, 20);
        expect(callCount, 3);

        await controller.close();
        liveData.dispose();
      });

      test('should be disposed when registered in scope', () async {
        final scope = DataScope();
        final controller = StreamController<int>();
        final liveData = LiveData.fromStream(controller.stream, 0, scope);

        expect(liveData.isDisposed, isFalse);

        scope.dispose();

        expect(liveData.isDisposed, isTrue);
        await controller.close();
      });

      test('should cancel stream subscription when disposed', () async {
        final controller = StreamController<int>();
        final liveData = LiveData.fromStream(controller.stream, 0);

        expect(controller.hasListener, isTrue);

        liveData.dispose();

        expect(controller.hasListener, isFalse);
        await controller.close();
      });

      test('should work with different types', () async {
        final controller = StreamController<String>();
        final liveData = LiveData.fromStream(controller.stream, 'initial');

        expect(liveData.value, 'initial');

        controller.add('hello');
        await Future.delayed(Duration(milliseconds: 10));
        expect(liveData.value, 'hello');

        await controller.close();
        liveData.dispose();
      });

      test('should handle rapid stream emissions', () async {
        final controller = StreamController<int>();
        final liveData = LiveData.fromStream(controller.stream, 0);

        int? lastValue;
        liveData.subscribe((value) {
          lastValue = value;
        });

        // Emit multiple values rapidly
        for (int i = 1; i <= 5; i++) {
          controller.add(i);
        }

        await Future.delayed(Duration(milliseconds: 50));
        expect(lastValue, 5);

        await controller.close();
        liveData.dispose();
      });
    });
  });

  group('HotswapLiveData', () {
    group('Creation and Initialization', () {
      test('should create HotswapLiveData from a base LiveData', () {
        final base = MutableLiveData<int>(10);
        final hotswap = base.hotswappable();

        expect(hotswap.value, 10);
        expect(hotswap.isDisposed, isFalse);

        hotswap.dispose();
        base.dispose();
      });
    });

    group('Basic Behavior', () {
      test('should update when base LiveData changes', () {
        final base = MutableLiveData<int>(10);
        final hotswap = base.hotswappable();

        int? receivedValue;
        int callCount = 0;
        hotswap.subscribe((value) {
          receivedValue = value;
          callCount++;
        });

        expect(receivedValue, 10);
        expect(callCount, 1);

        base.value = 20;
        expect(receivedValue, 20);
        expect(callCount, 2);

        base.value = 30;
        expect(receivedValue, 30);
        expect(callCount, 3);

        hotswap.dispose();
        base.dispose();
      });
    });

    group('Hotswap Functionality', () {
      test('should hotswap to new base LiveData and update value', () {
        final base1 = MutableLiveData<int>(10);
        final base2 = MutableLiveData<int>(20);
        final hotswap = base1.hotswappable();

        int? receivedValue;
        hotswap.subscribe((value) => receivedValue = value);

        expect(receivedValue, 10);

        hotswap.hotswap(base2);

        expect(hotswap.value, 20);
        expect(receivedValue, 20);

        hotswap.dispose();
        base2.dispose();
      });

      test('should keep subscribers active after hotswap', () {
        final base1 = MutableLiveData<int>(10);
        final base2 = MutableLiveData<int>(20);
        final hotswap = base1.hotswappable();

        int callCount = 0;
        int? lastValue;
        hotswap.subscribe((value) {
          callCount++;
          lastValue = value;
        });

        expect(callCount, 1);
        expect(lastValue, 10);

        hotswap.hotswap(base2);
        expect(callCount, 2);
        expect(lastValue, 20);

        base2.value = 30;
        expect(callCount, 3);
        expect(lastValue, 30);

        hotswap.dispose();
        base2.dispose();
      });

      test('should stop listening to old base after hotswap', () {
        final base1 = MutableLiveData<int>(10);
        final base2 = MutableLiveData<int>(20);
        final hotswap = base1.hotswappable();

        int callCount = 0;
        int? lastValue;
        hotswap.subscribe((value) {
          callCount++;
          lastValue = value;
        });

        expect(callCount, 1);

        // Use disposeOld=false to keep base1 alive
        hotswap.hotswap(base2, disposeOld: false);
        expect(callCount, 2);

        // Change old base - should NOT notify (unsubscribed but still alive)
        base1.value = 100;
        expect(callCount, 2);
        expect(lastValue, 20);

        // Change new base - should notify
        base2.value = 30;
        expect(callCount, 3);
        expect(lastValue, 30);

        hotswap.dispose();
        base1.dispose();
        base2.dispose();
      });

      test('should do nothing when hotswapping to same base', () {
        final base = MutableLiveData<int>(10);
        final hotswap = base.hotswappable();

        int callCount = 0;
        hotswap.subscribe((value) => callCount++);

        expect(callCount, 1);

        // Hotswap to same base
        hotswap.hotswap(base);

        // Should not notify again
        expect(callCount, 1);
        expect(base.isDisposed, isFalse);

        hotswap.dispose();
        base.dispose();
      });
    });

    group('disposeOld Parameter', () {
      test('should dispose old base when hotswap with disposeOld=true', () {
        final base1 = MutableLiveData<int>(10);
        final base2 = MutableLiveData<int>(20);
        final hotswap = base1.hotswappable();

        expect(base1.isDisposed, isFalse);

        hotswap.hotswap(base2, disposeOld: true);

        expect(base1.isDisposed, isTrue);
        expect(base2.isDisposed, isFalse);

        hotswap.dispose();
        base2.dispose();
      });

      test('should NOT dispose old base when hotswap with disposeOld=false',
          () {
        final base1 = MutableLiveData<int>(10);
        final base2 = MutableLiveData<int>(20);
        final hotswap = base1.hotswappable();

        expect(base1.isDisposed, isFalse);

        hotswap.hotswap(base2, disposeOld: false);

        expect(base1.isDisposed, isFalse);
        expect(base2.isDisposed, isFalse);

        hotswap.dispose();
        base1.dispose();
        base2.dispose();
      });
    });

    group('Scope Management', () {
      test('should be disposed when registered in scope', () {
        final scope = DataScope();
        final base1 = MutableLiveData<int>(10);
        final base2 = MutableLiveData<int>(20);
        final hotswap = base1.hotswappable(scope);

        expect(hotswap.isDisposed, isFalse);

        hotswap.hotswap(base2);

        scope.dispose();

        expect(hotswap.isDisposed, isTrue);
        // Base should NOT be disposed (not owned by hotswap)
        expect(base2.isDisposed, isFalse);

        base2.dispose();
      });
    });

    group('Cleanup and Dispose', () {
      test('should unsubscribe from current base when disposed', () {
        final base = MutableLiveData<int>(10);
        final hotswap = base.hotswappable();

        // Hotswap subscribes to base
        expect(base.subscribers.length, 1);

        hotswap.dispose();

        // Should unsubscribe
        expect(base.subscribers.length, 0);
        expect(base.isDisposed, isFalse);

        base.dispose();
      });
    });

    group('Change Detector', () {
      test('should inherit changeDetector from new base on hotswap', () {
        final base1 = MutableLiveData<int>(10);
        // Make base1 always notify
        base1.changeDetector = (a, b) => true;

        final base2 = MutableLiveData<int>(20);
        // base2 uses default changeDetector

        final hotswap = base1.hotswappable();

        int callCount = 0;
        hotswap.subscribe((value) => callCount++);

        expect(callCount, 1);

        // base1's changeDetector always notifies on same value
        base1.value = 10;
        expect(callCount, 2);

        // Hotswap to base2
        hotswap.hotswap(base2);
        expect(callCount, 3);

        // base2's changeDetector should NOT notify on same value
        base2.value = 20;
        expect(callCount, 3); // Should not increase

        base2.value = 30;
        expect(callCount, 4); // Should increase

        hotswap.dispose();
        base2.dispose();
      });
    });

    group('Advanced Scenarios', () {
      test('should handle multiple sequential hotswaps correctly', () {
        final base1 = MutableLiveData<int>(10);
        final base2 = MutableLiveData<int>(20);
        final base3 = MutableLiveData<int>(30);
        final base4 = MutableLiveData<int>(40);
        final hotswap = base1.hotswappable();

        expect(hotswap.value, 10);

        hotswap.hotswap(base2);
        expect(hotswap.value, 20);
        expect(base1.isDisposed, isTrue);

        hotswap.hotswap(base3);
        expect(hotswap.value, 30);
        expect(base2.isDisposed, isTrue);

        hotswap.hotswap(base4);
        expect(hotswap.value, 40);
        expect(base3.isDisposed, isTrue);

        expect(base4.isDisposed, isFalse);

        hotswap.dispose();
        base4.dispose();
      });

      test('should work with different base implementations of same type', () {
        final mutable1 = MutableLiveData<int>(10);
        final hotswap = mutable1.hotswappable();

        expect(hotswap.value, 10);

        final mutable2 = MutableLiveData<int>(20);
        hotswap.hotswap(mutable2);
        expect(hotswap.value, 20);

        final notifier = ValueNotifier<int>(30);
        final fromNotifier = LiveData.fromValueNotifier(notifier);
        hotswap.hotswap(fromNotifier);
        expect(hotswap.value, 30);

        hotswap.dispose();
        fromNotifier.dispose();
        notifier.dispose();
      });

      test('should notify subscribers immediately on hotswap if value changed',
          () {
        final base1 = MutableLiveData<int>(10);
        final base2 = MutableLiveData<int>(20);
        final hotswap = base1.hotswappable();

        int? receivedValue;
        int callCount = 0;
        hotswap.subscribe((value) {
          receivedValue = value;
          callCount++;
        });

        expect(receivedValue, 10);
        expect(callCount, 1);

        hotswap.hotswap(base2);

        // Should notify immediately with new value
        expect(receivedValue, 20);
        expect(callCount, 2);

        hotswap.dispose();
        base2.dispose();
      });

      test('should handle hotswap called during notification callback', () {
        final base1 = MutableLiveData<int>(10);
        final base2 = MutableLiveData<int>(20);
        final hotswap = base1.hotswappable();

        bool hotswapped = false;
        hotswap.subscribe((value) {
          if (value == 10 && !hotswapped) {
            hotswapped = true;
            // Hotswap during callback
            hotswap.hotswap(base2);
          }
        });

        // Should not throw error
        expect(hotswap.value, 20);
        expect(hotswapped, isTrue);

        hotswap.dispose();
        base2.dispose();
      });
    });
  });
}
