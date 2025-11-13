import 'package:example_playground/data/models/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_kit/mvvm_kit.dart';
import 'todo_viewmodel.dart';

part 'widgets/_todo_item_widget.dart';
part 'widgets/_todo_filter_bar.dart';
part 'widgets/_todo_input_field.dart';

class TodoView extends ViewWidget<TodoViewModel> {
  const TodoView({super.key, required super.viewModel});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends ViewState<TodoViewModel, TodoView> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          _TodoInputField(
            controller: _textController,
            onSubmit: (text) {
              viewModel.addTodo(text);
              _textController.clear();
            },
          ),
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
                          filter == TodoFilter.all
                              ? 'No todos yet!\nAdd one above 👆'
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
                    return _TodoItemWidget(todo: todos[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
