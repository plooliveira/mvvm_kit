import 'package:example_playground/view/todo/list_todos/todos_view.dart';
import 'package:go_router/go_router.dart';
import 'package:example_playground/view/home/home_view.dart';
import 'package:example_playground/view/counter/counter_view.dart';
import 'package:example_playground/view/theme_switcher/theme_view.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      path: '/counter',
      name: 'counter',
      builder: (context, state) => CounterView(),
    ),
    GoRoute(
      path: '/theme',
      name: 'theme',
      builder: (context, state) => ThemeView(),
    ),
    GoRoute(
      path: '/todo',
      name: 'todo',
      builder: (context, state) => TodoView(),
    ),
  ],
);
