import 'package:mvvm_kit/mvvm_kit.dart';
import '../../../data/repositories/todo_repository.dart';

class AddTodoViewModel extends ViewModel {
  late final TodoRepository _repository;

  AddTodoViewModel(TodoRepository repository) : _repository = repository;

  void addTodo(String title) {
    if (title.trim().isEmpty) return;
    _repository.add(title.trim());
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
