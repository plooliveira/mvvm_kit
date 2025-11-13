import 'package:mvvm_kit/mvvm_kit.dart';
import '../../data/repositories/todo_repository.dart';
import '../../data/database/objectbox_service.dart';

enum TodoFilter { all, active, completed }

class TodoViewModel extends ViewModel {
  late final TodoRepository _repository;

  TodoViewModel(ObjectBoxService db) {
    _repository = TodoRepository(db);
  }

  late final allTodos = _repository.todos.live;

  late final _currentFilter = mutable(TodoFilter.all);
  LiveData<TodoFilter> get currentFilter => _currentFilter;

  late final filteredTodos = scope.join([_currentFilter, allTodos], () {
    final filter = _currentFilter.value;
    final list = allTodos.value;

    switch (filter) {
      case TodoFilter.all:
        return list;
      case TodoFilter.active:
        return list.where((t) => !t.completed).toList();
      case TodoFilter.completed:
        return list.where((t) => t.completed).toList();
    }
  });

  late final activeCount = allTodos.transform(
    (todos) => todos.value.where((t) => !t.completed).length,
  );

  late final completedCount = allTodos.transform(
    (todos) => todos.value.where((t) => t.completed).length,
  );

  void addTodo(String title) {
    if (title.trim().isEmpty) return;
    _repository.add(title.trim());
  }

  void toggleTodo(int id) => _repository.toggle(id);

  void deleteTodo(int id) => _repository.delete(id);

  void setFilter(TodoFilter filter) => _currentFilter.value = filter;

  void clearCompleted() => _repository.deleteCompleted();

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
