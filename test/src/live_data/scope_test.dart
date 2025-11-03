import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier

import 'package:mvvm_kit/src/live_data/scope.dart';

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
      expect(scope.remove(mockItem1), isFalse); // Trying to remove again should return false
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
      expect(scope.items, isNot(contains(mockItem1))); // Verify it's removed from scope
      expect(scope.items.length, 1);
      expect(scope.items, contains(mockItem2)); // Other item should still be there
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
      final childScope = scope.child(); // This adds childScope to scope.children
      final childItem = MockChangeNotifier();
      childScope.add(childItem);

      expect(childItem.isDisposed, isFalse);
      expect(scope.children, contains(childScope));

      scope.dispose();

      expect(childItem.isDisposed, isTrue); // Child's item should be disposed
      expect(scope.children, isEmpty); // Child should be removed from parent
      expect(childScope.items, isEmpty); // Child's items should be cleared
    });

    test('dispose should call dispose on nested child scopes (grandchildren) and their items', () {
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
    },);

    test('dispose should remove the scope from its parent', () {
      final parentScope = DataScope();
      final childScope = parentScope.child();
      expect(parentScope.children, contains(childScope));

      childScope.dispose();

      expect(parentScope.children, isNot(contains(childScope)));
    });

    test('dispose should dispose items and children in reverse order of addition', () {
      final disposalOrder = <String>[];

      final item1 = OrderRecordingChangeNotifier('item1', disposalOrder);
      final item2 = OrderRecordingChangeNotifier('item2', disposalOrder);

      final childScope1 = scope.child(); // Added first
      final childScope2 = scope.child(); // Added second

      final child1Item = OrderRecordingChangeNotifier('child1Item', disposalOrder);
      final child2Item = OrderRecordingChangeNotifier('child2Item', disposalOrder);

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
    },);
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

    test('removing an item that is not in the scope should do nothing and return false', () {
      final nonExistentItem = MockChangeNotifier();
      expect(scope.items, isEmpty);
      expect(scope.remove(nonExistentItem), isFalse); // Should return false
      expect(scope.items, isEmpty); // Should still be empty
      expect(nonExistentItem.isDisposed, isFalse); // Should not dispose it
    });

    test('disposing a child scope should not dispose the parent scope', () {
      final parentScope = DataScope();
      final childScope = parentScope.child();
      final parentItem = MockChangeNotifier();
      parentScope.add(parentItem);

      expect(parentItem.isDisposed, isFalse);
      expect(parentScope.children, contains(childScope));

      childScope.dispose();

      expect(parentItem.isDisposed, isFalse); // Parent's item should NOT be disposed
      expect(parentScope.children, isNot(contains(childScope))); // Child should be removed
    });

    test("should add child to parent's children list upon creation", () {
      final parentScope = DataScope();
      final childScope = DataScope(parent: parentScope); // Create child with parent
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
}