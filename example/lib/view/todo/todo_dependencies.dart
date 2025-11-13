import 'package:example_playground/data/repositories/todo_repository.dart';
import 'package:example_playground/data/database/objectbox.g.dart';
import 'package:example_playground/view/todo/add_todo/add_todo_viewmodel.dart';
import 'package:example_playground/view/todo/list_todos/todos_viewmodel.dart';
import 'package:get_it/get_it.dart';

abstract class AppDependencies {
  Future<void> setup();
}

class TodosDependencies extends AppDependencies {
  @override
  Future<void> setup() async {
    GetIt.I.registerSingletonAsync<Store>(() async => await openStore());
    await GetIt.I.isReady<Store>();
    GetIt.I.registerFactory<TodoRepository>(
      () => ObjectBoxTodoRepository(GetIt.I<Store>()),
    );
    GetIt.I.registerFactory(() => TodosViewModel(GetIt.I<TodoRepository>()));
    GetIt.I.registerFactory(() => AddTodoViewModel(GetIt.I<TodoRepository>()));
  }
}
