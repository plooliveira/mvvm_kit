import '../../objectbox.g.dart';

class ObjectBoxService {
  static ObjectBoxService? _instance;
  late final Store _store;

  ObjectBoxService._(this._store);

  static Future<ObjectBoxService> getInstance() async {
    if (_instance == null) {
      final store = await openStore();
      _instance = ObjectBoxService._(store);
    }
    return _instance!;
  }

  Store get store => _store;

  Box<T> box<T>() => _store.box<T>();

  void close() => _store.close();
}
