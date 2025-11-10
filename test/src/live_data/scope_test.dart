import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';

import 'package:mvvm_kit/mvvm_kit.dart';

// A simple mock ChangeNotifier for testing purposes
class MockChangeNotifier extends ChangeNotifier {
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

// A mock that records disposal order
class OrderRecordingChangeNotifier extends MockChangeNotifier {
  final String name;
  final List<String> disposalOrder;

  OrderRecordingChangeNotifier(this.name, this.disposalOrder);

  @override
  void dispose() {
    disposalOrder.add(name);
    super.dispose();
  }
}

void main() {
  group('DataScope Basic Functionality', () {
    late DataScope scope;
    late MockChangeNotifier mockItem1;
    late MockChangeNotifier mockItem2;

    setUp(() {
      scope = DataScope();
      mockItem1 = MockChangeNotifier();
      mockItem2 = MockChangeNotifier();
    });

    test('should add items correctly', () {
      expect(scope.items, isEmpty);
      scope.add(mockItem1);
      expect(scope.items, contains(mockItem1));
      expect(scope.items.length, 1);
    });

    test('should remove items correctly', () {
      scope.add(mockItem1);
      expect(scope.items, contains(mockItem1));
      expect(scope.remove(mockItem1), isTrue);
      expect(scope.items, isEmpty);
      expect(
        scope.remove(mockItem1),
        isFalse,
      ); // Trying to remove again should return false
    });

    test('should not add duplicate items', () {
      scope.add(mockItem1);
      expect(scope.items.length, 1);
      scope.add(mockItem1); // Add the same item again
      expect(scope.items.length, 1); // Should still be 1
      expect(scope.items, contains(mockItem1));
    });

    test('should dispose a single item when clean is called', () {
      scope.add(mockItem1);
      scope.add(mockItem2);
      expect(scope.items.length, 2);
      expect(mockItem1.isDisposed, isFalse);

      scope.clean(mockItem1);

      expect(mockItem1.isDisposed, isTrue); // Verify dispose was called
      expect(
        scope.items,
        isNot(contains(mockItem1)),
      ); // Verify it's removed from scope
      expect(scope.items.length, 1);
      expect(
        scope.items,
        contains(mockItem2),
      ); // Other item should still be there
    });
  });

  group('DataScope Lifecycle and Disposal', () {
    late DataScope scope;
    late MockChangeNotifier mockItem1;
    late MockChangeNotifier mockItem2;

    setUp(() {
      scope = DataScope();
      mockItem1 = MockChangeNotifier();
      mockItem2 = MockChangeNotifier();
    });

    test('dispose should call dispose on all added items', () {
      scope.add(mockItem1);
      scope.add(mockItem2);
      expect(mockItem1.isDisposed, isFalse);
      expect(mockItem2.isDisposed, isFalse);

      scope.dispose();

      expect(mockItem1.isDisposed, isTrue);
      expect(mockItem2.isDisposed, isTrue);
      expect(scope.items, isEmpty);
    });

    test('dispose should call dispose on child scopes and their items', () {
      final childScope = scope
          .child(); // This adds childScope to scope.children
      final childItem = MockChangeNotifier();
      childScope.add(childItem);

      expect(childItem.isDisposed, isFalse);
      expect(scope.children, contains(childScope));

      scope.dispose();

      expect(childItem.isDisposed, isTrue); // Child's item should be disposed
      expect(scope.children, isEmpty); // Child should be removed from parent
      expect(childScope.items, isEmpty); // Child's items should be cleared
    });

    test(
      'dispose should call dispose on nested child scopes (grandchildren) and their items',
      () {
        final childScope = scope.child();
        final grandChildScope = childScope.child();
        final grandChildItem = MockChangeNotifier();
        grandChildScope.add(grandChildItem);

        expect(grandChildItem.isDisposed, isFalse);

        scope.dispose();

        expect(grandChildItem.isDisposed, isTrue);
        expect(grandChildScope.items, isEmpty);
        expect(childScope.children, isEmpty);
        expect(childScope.items, isEmpty);
        expect(scope.children, isEmpty);
      },
    );

    test('dispose should remove the scope from its parent', () {
      final parentScope = DataScope();
      final childScope = parentScope.child();
      expect(parentScope.children, contains(childScope));

      childScope.dispose();

      expect(parentScope.children, isNot(contains(childScope)));
    });

    test(
      'dispose should dispose items and children in reverse order of addition',
      () {
        final disposalOrder = <String>[];

        final item1 = OrderRecordingChangeNotifier('item1', disposalOrder);
        final item2 = OrderRecordingChangeNotifier('item2', disposalOrder);

        final childScope1 = scope.child(); // Added first
        final childScope2 = scope.child(); // Added second

        final child1Item = OrderRecordingChangeNotifier(
          'child1Item',
          disposalOrder,
        );
        final child2Item = OrderRecordingChangeNotifier(
          'child2Item',
          disposalOrder,
        );

        childScope1.add(child1Item);
        childScope2.add(child2Item);
        scope.add(item1);
        scope.add(item2);

        scope.dispose();

        // Expected order:
        // 1. childScope2.dispose() -> child2Item.dispose()
        // 2. childScope1.dispose() -> child1Item.dispose()
        // 3. item2.dispose()
        // 4. item1.dispose()
        expect(disposalOrder, ['child2Item', 'child1Item', 'item2', 'item1']);
      },
    );
  });

  group('DataScope Edge Cases', () {
    late DataScope scope;
    late MockChangeNotifier mockItem;

    setUp(() {
      scope = DataScope();
      mockItem = MockChangeNotifier();
    });

    test('disposing an already disposed scope should not cause errors', () {
      scope.add(mockItem);
      scope.dispose();
      expect(mockItem.isDisposed, isTrue);

      // Call dispose again
      expect(() => scope.dispose(), returnsNormally); // Should not throw
      expect(mockItem.isDisposed, isTrue); // Should still be disposed
    });

    test(
      'removing an item that is not in the scope should do nothing and return false',
      () {
        final nonExistentItem = MockChangeNotifier();
        expect(scope.items, isEmpty);
        expect(scope.remove(nonExistentItem), isFalse); // Should return false
        expect(scope.items, isEmpty); // Should still be empty
        expect(nonExistentItem.isDisposed, isFalse); // Should not dispose it
      },
    );

    test('disposing a child scope should not dispose the parent scope', () {
      final parentScope = DataScope();
      final childScope = parentScope.child();
      final parentItem = MockChangeNotifier();
      parentScope.add(parentItem);

      expect(parentItem.isDisposed, isFalse);
      expect(parentScope.children, contains(childScope));

      childScope.dispose();

      expect(
        parentItem.isDisposed,
        isFalse,
      ); // Parent's item should NOT be disposed
      expect(
        parentScope.children,
        isNot(contains(childScope)),
      ); // Child should be removed
      parentScope.dispose();
    });

    test("should add child to parent's children list upon creation", () {
      final parentScope = DataScope();
      final childScope = DataScope(
        parent: parentScope,
      ); // Create child with parent
      expect(parentScope.children, contains(childScope));
      expect(parentScope.children.length, 1);
    });

    test('calling clean on an item not in the scope should do nothing', () {
      final nonExistentItem = MockChangeNotifier();
      scope.add(mockItem); // Add one item to the scope
      expect(scope.items.length, 1);
      expect(nonExistentItem.isDisposed, isFalse);

      scope.clean(nonExistentItem); // Clean a non-existent item

      expect(scope.items.length, 1);
      expect(scope.items, contains(mockItem));
      expect(nonExistentItem.isDisposed, isFalse);
    });
  });

  group('MutableDataScope Extension', () {
    late DataScope scope;
    late MutableLiveData<int> source;

    setUp(() {
      scope = DataScope();
      source = MutableLiveData(10);
    });

    test('mutable should create a MutableLiveData with initial value', () {
      final liveData = scope.mutable<int>(42);

      expect(liveData, isA<MutableLiveData<int>>());
      expect(liveData.value, 42);
      expect(scope.items, contains(liveData));
    });

    test('mutable should add the created LiveData to the scope', () {
      final initialCount = scope.items.length;
      final liveData = scope.mutable<String>('test');

      expect(scope.items.length, initialCount + 1);
      expect(scope.items, contains(liveData));
    });

    test('mutable should create different types correctly', () {
      final intData = scope.mutable<int>(1);
      final stringData = scope.mutable<String>('hello');
      final boolData = scope.mutable<bool>(true);

      expect(intData.value, 1);
      expect(stringData.value, 'hello');
      expect(boolData.value, true);
      expect(scope.items.length, 3);
    });

    test(
      'bridgeFrom should create a MutableLiveData with the initial value',
      () {
        final mirror = scope.bridgeFrom(source);
        expect(mirror.value, 10);
        expect(scope.items, contains(mirror));
      },
    );

    test('bridgeFrom should update the mirror when the source changes', () {
      final mirror = scope.bridgeFrom(source);
      expect(mirror.value, 10);

      source.value = 20;
      expect(mirror.value, 20);
    });

    test(
      'disposing the scope should dispose the mirror and remove the listener',
      () {
        final mirror = scope.bridgeFrom(source);
        expect(mirror.isDisposed, isFalse);
        expect(source.hasListeners, isTrue);

        scope.dispose();

        expect(mirror.isDisposed, isTrue);
        expect(source.hasListeners, isFalse);
      },
    );
  });

  group('DataScopeExtensions - join (Mediator)', () {
    late DataScope scope;

    setUp(() {
      scope = DataScope();
    });

    test('join should create LiveData that mediates multiple sources', () {
      final source1 = MutableLiveData<int>(10);
      final source2 = MutableLiveData<int>(20);

      final mediated = scope.join<int>(
        [source1, source2],
        () => source1.value + source2.value,
      );

      expect(mediated.value, 30);
      expect(scope.items, contains(mediated));
    });

    test('join should update when any source changes', () {
      final source1 = MutableLiveData<int>(10);
      final source2 = MutableLiveData<int>(20);

      final mediated = scope.join<int>(
        [source1, source2],
        () => source1.value + source2.value,
      );

      expect(mediated.value, 30);

      source1.value = 15;
      expect(mediated.value, 35);

      source2.value = 25;
      expect(mediated.value, 40);
    });

    test('join should notify listeners when mediated value changes', () {
      final source1 = MutableLiveData<int>(10);
      final source2 = MutableLiveData<int>(20);

      final mediated = scope.join<int>(
        [source1, source2],
        () => source1.value + source2.value,
      );

      int? receivedValue;
      int callCount = 0;
      mediated.subscribe((value) {
        receivedValue = value;
        callCount++;
      });

      expect(callCount, 1);
      expect(receivedValue, 30);

      source1.value = 100;
      expect(callCount, 2);
      expect(receivedValue, 120);
    });

    test('join should dispose and unsubscribe from sources', () {
      final source1 = MutableLiveData<int>(10);
      final source2 = MutableLiveData<int>(20);

      final mediated = scope.join<int>(
        [source1, source2],
        () => source1.value + source2.value,
      );

      expect(mediated.isDisposed, isFalse);

      scope.dispose();

      expect(mediated.isDisposed, isTrue);
      // Should have unsubscribed from sources (can be verified by updating sources)
      final oldValue = mediated.value;
      source1.value = 999;
      // Value shouldn't change after dispose
      expect(mediated.value, oldValue);
    });
  });

  group('DataScopeExtensions - merge', () {
    late DataScope scope;

    setUp(() {
      scope = DataScope();
    });

    test('merge should create LiveData that transforms multiple sources', () {
      final source1 = MutableLiveData<int>(10);
      final source2 = MutableLiveData<int>(20);

      final merged = scope.merge<String>(
        [source1, source2],
        () => '${source1.value}:${source2.value}',
      );

      expect(merged.value, '10:20');
      expect(scope.items, contains(merged));
    });

    test('merge should update when any source changes', () {
      final source1 = MutableLiveData<int>(10);
      final source2 = MutableLiveData<int>(20);

      final merged = scope.merge<String>(
        [source1, source2],
        () => '${source1.value}:${source2.value}',
      );

      expect(merged.value, '10:20');

      source1.value = 30;
      expect(merged.value, '30:20');

      source2.value = 40;
      expect(merged.value, '30:40');
    });

    test('merge should notify listeners when transformed value changes', () {
      final source1 = MutableLiveData<int>(10);
      final source2 = MutableLiveData<int>(20);

      final merged = scope.merge<String>(
        [source1, source2],
        () => '${source1.value}:${source2.value}',
      );

      String? receivedValue;
      int callCount = 0;
      merged.subscribe((value) {
        receivedValue = value;
        callCount++;
      });

      expect(callCount, 1);
      expect(receivedValue, '10:20');

      source1.value = 100;
      expect(callCount, 2);
      expect(receivedValue, '100:20');
    });

    test('merge should dispose when scope is disposed', () {
      final source1 = MutableLiveData<int>(10);
      final source2 = MutableLiveData<int>(20);

      final merged = scope.merge<String>(
        [source1, source2],
        () => '${source1.value}:${source2.value}',
      );

      expect(merged.isDisposed, isFalse);

      scope.dispose();

      expect(merged.isDisposed, isTrue);
    });

    test('merge should work with different types of ChangeNotifiers', () {
      final liveData = MutableLiveData<int>(10);
      final notifier = MockChangeNotifier();

      final merged = scope.merge<String>(
        [liveData, notifier],
        () => 'value:${liveData.value}',
      );

      expect(merged.value, 'value:10');

      liveData.value = 20;
      expect(merged.value, 'value:20');

      // Notify the MockChangeNotifier
      notifier.notifyListeners();
      expect(merged.value, 'value:20'); // Still same because transform didn't change
    });
  });
}
