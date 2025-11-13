import 'dart:async';

import 'package:mvvm_kit/mvvm_kit.dart';
import 'package:objectbox/objectbox.dart';
import '../models/todo_item.dart';

abstract class TodoRepository {
  LiveRepositoryData<List<TodoItem>> get todos;

  void add(String title);
  void toggle(int id);
  void delete(int id);
  void deleteCompleted();
  void dispose();
}

class ObjectBoxTodoRepository implements TodoRepository {
  late final Box<TodoItem> _box;
  late final MutableRepositoryData<List<TodoItem>> _todosData;
  StreamSubscription<List<TodoItem>>? _subscription;

  ObjectBoxTodoRepository(Store db) {
    _box = db.box<TodoItem>();
    _todosData = MutableRepositoryData(value: []);
    _listenToDatabase();
  }

  @override
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

  @override
  void add(String title) {
    final todo = TodoItem(title: title);
    _box.put(todo);
  }

  @override
  void toggle(int id) {
    final todo = _box.get(id);
    if (todo != null) {
      todo.completed = !todo.completed;
      _box.put(todo);
    }
  }

  @override
  void delete(int id) {
    _box.remove(id);
  }

  @override
  void deleteCompleted() {
    final completed = _todosData.value.where((t) => t.completed).toList();
    final ids = completed.map((t) => t.id).toList();
    _box.removeMany(ids);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _todosData.dispose();
  }
}
