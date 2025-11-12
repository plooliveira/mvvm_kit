import 'package:flutter_test/flutter_test.dart';
import '../../../lib/mvvm_kit.dart';

void main() {
  group('LiveRepositoryData', () {
    test('should wrap LiveData source and delegate value access', () {
      final source = MutableLiveData(42);
      final repo = LiveRepositoryData(source);

      expect(repo.value, 42);
      expect(repo.source, same(source));

      source.value = 100;
      expect(repo.value, 100);

      source.dispose();
    });

    test('should delegate live getter to return mirror of source', () {
      final source = MutableLiveData(42);
      final repo = LiveRepositoryData(source);
      final live = repo.live;

      expect(live, isNot(same(source)));
      expect(live.value, 42);

      source.value = 100;
      expect(live.value, 100);

      live.dispose();
      source.dispose();
    });

    test('should delegate transform method to source', () {
      final source = MutableLiveData(10);
      final repo = LiveRepositoryData(source);
      final transformed = repo.transform((data) => data.value * 2, null);

      expect(transformed.value, 20);

      source.value = 15;
      expect(transformed.value, 30);

      transformed.dispose();
      source.dispose();
    });
  });

  group('MutableRepositoryData', () {
    test('should create internal source when initialized with value', () {
      final repo = MutableRepositoryData(value: 42);

      expect(repo.value, 42);
      expect(repo.source, isNotNull);
      expect(repo.source, isA<MutableLiveData<int>>());

      repo.source.dispose();
    });

    test('should wrap external source when provided', () {
      final source = MutableLiveData(42);
      final repo = MutableRepositoryData(source: source);

      expect(repo.value, 42);
      expect(repo.source, same(source));

      source.dispose();
    });

    test('should prioritize source parameter over value parameter', () {
      final source = MutableLiveData(100);
      final repo = MutableRepositoryData(value: 42, source: source);

      expect(repo.value, 100);
      expect(repo.source, same(source));

      source.dispose();
    });

    test('should delegate value setter to source', () {
      final repo = MutableRepositoryData(value: 10);

      repo.value = 20;
      expect(repo.value, 20);
      expect(repo.source.value, 20);

      repo.source.dispose();
    });

    test('should apply custom changeDetector to internal source', () {
      bool alwaysChanged(int a, int b) => true;
      final repo = MutableRepositoryData(
        value: 10,
        changeDetector: alwaysChanged,
      );

      expect(repo.source.changeDetector, equals(alwaysChanged));

      repo.source.dispose();
    });
  });

  group('RepositoryData polymorphism', () {
    test('should work with LiveRepositoryData through interface', () {
      final source = MutableLiveData(42);
      RepositoryData<int> repo = LiveRepositoryData(source);

      expect(repo.value, 42);
      expect(repo.live.value, 42);
      expect(repo.transform((data) => data.value * 2, null).value, 84);

      source.dispose();
    });

    test('should work with MutableRepositoryData through interface', () {
      RepositoryData<int> repo = MutableRepositoryData(value: 42);

      expect(repo.value, 42);
      expect(repo.live.value, 42);
      expect(repo.transform((data) => data.value * 2, null).value, 84);

      (repo as MutableRepositoryData).source.dispose();
    });
  });
}
