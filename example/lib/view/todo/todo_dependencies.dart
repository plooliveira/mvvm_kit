import 'package:example_playground/core/routes/app_dependencies.dart';
import 'package:example_playground/data/repositories/todo_repository.dart';
import 'package:example_playground/objectbox.g.dart';
import 'package:example_playground/view/todo/add_todo/add_todo_viewmodel.dart';
import 'package:example_playground/view/todo/list_todos/todos_viewmodel.dart';
import 'package:get_it/get_it.dart';

class TodosDependencies extends AppDependencies {
  @override
  Future<void> setup() async {
    GetIt.I.registerFactory(() => TodoRepository(GetIt.I<Store>()));
    GetIt.I.registerFactory(() => TodosViewModel(GetIt.I<TodoRepository>()));
    GetIt.I.registerFactory(() => AddTodoViewModel(GetIt.I<TodoRepository>()));
  }
}
