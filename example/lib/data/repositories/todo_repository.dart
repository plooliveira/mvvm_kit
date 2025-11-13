import 'dart:async';
import 'package:mvvm_kit/mvvm_kit.dart';
import 'package:objectbox/objectbox.dart';
import '../models/todo_item.dart';
import '../database/objectbox_service.dart';

class TodoRepository {
  final ObjectBoxService _db;
  late final Box<TodoItem> _box;
  late final MutableRepositoryData<List<TodoItem>> _todosData;
  StreamSubscription<List<TodoItem>>? _subscription;

  TodoRepository(this._db) {
    _box = _db.box<TodoItem>();
    _todosData = MutableRepositoryData(value: []);
    _listenToDatabase();
  }

  LiveRepositoryData<List<TodoItem>> get todos =>
      LiveRepositoryData(_todosData.source);

  void _listenToDatabase() {
    final query = _box.query();

    _subscription = query
        .watch(triggerImmediately: true)
        .map((q) => q.find())
        .listen((todoList) {
      _todosData.value = todoList;
    });
  }

  void add(String title) {
    final todo = TodoItem(title: title);
    _box.put(todo);
  }

  void toggle(int id) {
    final todo = _box.get(id);
    if (todo != null) {
      todo.completed = !todo.completed;
      _box.put(todo);
    }
  }

  void delete(int id) {
    _box.remove(id);
  }

  void deleteCompleted() {
    final completed = _todosData.value.where((t) => t.completed).toList();
    final ids = completed.map((t) => t.id).toList();
    _box.removeMany(ids);
  }

  void dispose() {
    _subscription?.cancel();
    _todosData.dispose();
  }
}
