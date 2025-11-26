import 'package:example_playground/view/counter/counter_cascade_view.dart';
import 'package:example_playground/view/todo/list_todos/todos_view.dart';
import 'package:go_router/go_router.dart';
import 'package:example_playground/view/home/home_view.dart';
import 'package:example_playground/view/counter/counter_simple_view.dart';
import 'package:example_playground/view/theme_switcher/theme_view.dart';
import 'package:example_playground/view/form/product_form_view.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    HomeRoute(),
    CounterRoute(),
    ProductFormRoute(),
    ThemeRoute(),
    TodosRoute(),
    CounterCascadeRoute(),
  ],
);
