import 'package:example_playground/data/models/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm_kit/mvvm_kit.dart';
import 'todos_viewmodel.dart';
import '../add_todo/add_todo_bottom_sheet.dart';

part 'widgets/_todo_item_widget.dart';
part 'widgets/_todo_filter_bar.dart';

class TodosRoute extends GoRoute {
  TodosRoute()
    : super(
        path: '/todo',
        name: 'todo',
        builder: (context, state) => TodosView(),
      );
}

class TodosView extends ViewWidget<TodosViewModel> {
  const TodosView({super.key});

  // Override resolveViewModel() to plug a
  // different injection strategy. In this case, GetIt.
  // If the type is registered as a factory, each ViewState will get its own instance
  // (i.e. it is not a singleton). That is fine because the underlying data
  // source (ObjectBox) is shared and reactive — multiple ViewModel instances will
  // still observe the same data changes.
  @override
  TodosViewModel resolveViewModel(BuildContext context) =>
      GetIt.I<TodosViewModel>();

  @override
  Widget build(BuildContext context, TodosViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List Example'),
        actions: [
          Watch(
            viewModel.completedCount,
            builder: (context, count) {
              if (count == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: viewModel.clearCompleted,
                child: Text('Clear ($count)'),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Watch(
            viewModel.currentFilter,
            builder: (context, currentFilter) {
              return _TodoFilterBar(
                currentFilter,
                onFilterSelected: viewModel.setFilter,
              );
            },
          ),
          Expanded(
            child: Watch(
              viewModel.filteredTodos,
              builder: (context, todos) {
                if (todos.isEmpty) {
                  return Center(
                    child: Watch(
                      viewModel.currentFilter,
                      builder: (context, filter) {
                        return Text(
                          filter == TodosFilter.all
                              ? 'No todos yet!\nTap + to add one'
                              : 'No ${filter.name} todos',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    return _TodoItemWidget(
                      todo: todos[index],
                      toggleTodo: viewModel.toggleTodo,
                      deleteTodo: viewModel.deleteTodo,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => AddTodoBottomSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
