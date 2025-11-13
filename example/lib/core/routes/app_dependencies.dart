import 'package:example_playground/view/global_dependencies.dart';
import 'package:example_playground/view/todo/todo_dependencies.dart';

abstract class AppDependencies {
  Future<void> setup();
}

Future<void> setupDependencies() async {
  await GlobalDependencies().setup();
  await TodosDependencies().setup();
}
