import 'package:example_playground/data/database/objectbox_service.dart';
import 'package:example_playground/data/repositories/todo_repository.dart';
import 'package:mvvm_kit/mvvm_kit.dart';

enum TodosFilter { all, active, completed }

class TodosViewModel extends ViewModel {
  late final TodoRepository _repository;

  TodosViewModel([ObjectBoxService? db]) {
    _repository = TodoRepository(db);
  }

  late final allTodos = _repository.todos.live;

  late final _currentFilter = mutable(TodosFilter.all);
  LiveData<TodosFilter> get currentFilter => _currentFilter;

  late final filteredTodos = scope.join([_currentFilter, allTodos], () {
    final filter = _currentFilter.value;
    final list = allTodos.value;

    switch (filter) {
      case TodosFilter.all:
        return list;
      case TodosFilter.active:
        return list.where((t) => !t.completed).toList();
      case TodosFilter.completed:
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

  void setFilter(TodosFilter filter) => _currentFilter.value = filter;

  void clearCompleted() => _repository.deleteCompleted();

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
