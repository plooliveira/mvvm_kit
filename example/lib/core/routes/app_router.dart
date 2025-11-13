import 'package:example_playground/view/todo/list_todos/todos_view.dart';
import 'package:go_router/go_router.dart';
import 'package:example_playground/view/home/home_view.dart';
import 'package:example_playground/view/counter/counter_view.dart';
import 'package:example_playground/view/theme_switcher/theme_view.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [HomeRoute(), CounterRoute(), ThemeRoute(), TodosRoute()],
);
