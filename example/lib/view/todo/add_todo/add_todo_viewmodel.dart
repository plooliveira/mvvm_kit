import 'package:example_playground/data/database/objectbox_service.dart';
import 'package:mvvm_kit/mvvm_kit.dart';
import '../../../data/repositories/todo_repository.dart';

class AddTodoViewModel extends ViewModel {
  late final TodoRepository _repository;

  AddTodoViewModel([ObjectBoxService? db]) {
    _repository = TodoRepository(db);
  }

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
