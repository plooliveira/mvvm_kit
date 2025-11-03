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
}